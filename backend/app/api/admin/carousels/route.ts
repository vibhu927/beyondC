import { NextRequest, NextResponse } from 'next/server'

import { apiError, apiSuccess } from '@/lib/admin/api'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'

function audienceFrom(input: unknown) {
  const value = String(input || '').trim().toLowerCase()
  return value === 'creator' || value === 'brand' ? value : null
}

function storagePathFromPublicUrl(url: string) {
  const marker = '/storage/v1/object/public/avatars/'
  const idx = url.indexOf(marker)
  if (idx === -1) return null
  return url.substring(idx + marker.length)
}

function shouldRedirectToAdminPage(request: NextRequest) {
  const accept = request.headers.get('accept') || ''
  const destination = request.headers.get('sec-fetch-dest') || ''
  return accept.includes('text/html') || destination === 'document'
}

function redirectToAdminPage(request: NextRequest, params?: Record<string, string>) {
  const url = new URL('/admin/carousels', request.url)
  if (params) {
    for (const [key, value] of Object.entries(params)) {
      url.searchParams.set(key, value)
    }
  }
  return NextResponse.redirect(url, { status: 303 })
}

function formAwareError(request: NextRequest, message: string, status = 400) {
  if (shouldRedirectToAdminPage(request)) {
    return redirectToAdminPage(request, { status: 'error', message })
  }
  return apiError(message, status)
}

function formAwareSuccess(request: NextRequest, payload: Record<string, unknown>) {
  if (shouldRedirectToAdminPage(request)) {
    return redirectToAdminPage(request, {
      status: 'success',
      message: String(payload.message || 'Saved successfully'),
    })
  }
  return apiSuccess(payload)
}

export async function POST(request: NextRequest) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return formAwareError(request, auth.error, auth.status)

  const formData = await request.formData()
  const action = String(formData.get('action') || 'upload').trim().toLowerCase()
  const service = createServiceClient()

  if (action === 'delete') {
    const id = String(formData.get('id') || '').trim()
    if (!id) return formAwareError(request, 'id is required', 400)

    const { data: existing, error: fetchError } = await service
      .from('home_carousels')
      .select('id,media_url,audience')
      .eq('id', id)
      .maybeSingle()

    if (fetchError) return formAwareError(request, fetchError.message, 500)
    if (!existing) return formAwareError(request, 'Carousel media not found', 404)

    const storagePath = storagePathFromPublicUrl(String(existing.media_url || ''))
    if (storagePath) {
      await service.storage.from('avatars').remove([storagePath])
    }

    const { error: deleteError } = await service.from('home_carousels').delete().eq('id', id)
    if (deleteError) return formAwareError(request, deleteError.message, 500)

    await writeAdminLog({
      adminId: auth.context.userId,
      action: 'delete_home_carousel_media',
      targetType: 'home_carousels',
      targetId: id,
      details: { audience: existing.audience },
    })

    return formAwareSuccess(request, {
      success: true,
      message: 'Carousel media deleted',
    })
  }

  const audience = audienceFrom(formData.get('audience'))
  const caption = String(formData.get('caption') || '').trim()
  const file = formData.get('file')

  if (!audience) return formAwareError(request, 'audience must be brand or creator', 400)
  if (!(file instanceof File)) return formAwareError(request, 'file is required', 400)

  if (!file.type.startsWith('image/')) {
    return formAwareError(request, 'Only image files are allowed for home carousel', 400)
  }

  const bytes = Buffer.from(await file.arrayBuffer())
  const ext = (file.name.split('.').pop() || 'jpg').toLowerCase()
  const safeExt = ext.replace(/[^a-z0-9]/g, '') || 'jpg'
  const path = `home_carousels/${audience}/${Date.now()}-${Math.random().toString(36).slice(2)}.${safeExt}`

  const { error: uploadError } = await service.storage.from('avatars').upload(path, bytes, {
    contentType: file.type,
    upsert: false,
  })

  if (uploadError) return formAwareError(request, uploadError.message, 500)

  const mediaUrl = service.storage.from('avatars').getPublicUrl(path).data.publicUrl

  const { data: inserted, error: insertError } = await service
    .from('home_carousels')
    .insert({
      audience,
      media_url: mediaUrl,
      media_type: 'image',
      caption: caption || null,
      is_active: true,
      sort_order: 0,
    })
    .select('id')
    .single()

  if (insertError) return formAwareError(request, insertError.message, 500)

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'upload_home_carousel_media',
    targetType: 'home_carousels',
    targetId: inserted.id,
    details: { audience, fileName: file.name, mime: file.type },
  })

  return formAwareSuccess(request, {
    success: true,
    id: inserted.id,
    message: 'Carousel media uploaded',
  })
}
