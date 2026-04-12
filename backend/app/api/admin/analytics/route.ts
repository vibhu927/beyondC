import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { createServiceClient } from '@/lib/supabase/service'

export async function GET(request: NextRequest) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const service = createServiceClient()

  const [profiles, collabs, creators, campaigns] = await Promise.all([
    service.from('profiles').select('id,role,state,city,created_at'),
    service.from('collabs').select('id,brand_id,creator_id,agreed_amount,created_at,status'),
    service.from('creator_profiles').select('tier,niche'),
    service.from('campaigns').select('niche,target_state,created_at'),
  ])

  return apiSuccess({
    profiles: profiles.data ?? [],
    collabs: collabs.data ?? [],
    creators: creators.data ?? [],
    campaigns: campaigns.data ?? [],
  })
}
