import { NextRequest } from 'next/server'

import { apiError, apiSuccess } from '@/lib/admin/api'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { createServiceClient } from '@/lib/supabase/service'

export async function GET(request: NextRequest) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const target = request.nextUrl.searchParams.get('target') || 'all'
  const specificEmails = (request.nextUrl.searchParams.get('specificEmails') || '')
    .split(',')
    .map((value) => value.trim().toLowerCase())
    .filter(Boolean)

  const service = createServiceClient()

  let query = service
    .from('profiles')
    .select('id', { count: 'exact', head: true })
    .eq('is_onboarded', true)

  if (target === 'creators') {
    query = query.eq('role', 'creator')
  } else if (target === 'brands') {
    query = query.eq('role', 'brand')
  } else if (target === 'specific') {
    if (specificEmails.length === 0) {
      return apiSuccess({ count: 0 })
    }
    query = query.in('email', specificEmails)
  }

  const { count, error } = await query

  if (error) {
    return apiError(error.message, 500)
  }

  return apiSuccess({ count: count || 0 })
}
