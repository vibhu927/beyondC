import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const service = createServiceClient()

  const { data: brand, error: readError } = await service
    .from('brand_profiles')
    .select('is_brand_verified')
    .eq('id', params.id)
    .single()

  if (readError || !brand) return apiError('Brand not found', 404)

  const nextState = !brand.is_brand_verified
  const { data, error } = await service
    .from('brand_profiles')
    .update({ is_brand_verified: nextState })
    .eq('id', params.id)
    .select('id,is_brand_verified')
    .single()

  if (error) return apiError(error.message)

  await writeAdminLog({
    adminId: auth.context.userId,
    action: nextState ? 'verified_brand' : 'unverified_brand',
    targetType: 'user',
    targetId: params.id,
    details: {},
  })

  return apiSuccess(data)
}
