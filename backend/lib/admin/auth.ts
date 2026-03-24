import { NextRequest } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'

export type AdminProfile = {
  id: string
  full_name: string | null
  first_name: string | null
  email: string
  is_admin: boolean
  is_super_admin: boolean
  is_suspended: boolean
}

export type AdminContext = {
  userId: string
  profile: AdminProfile
}

export async function getCurrentAdminContext(): Promise<AdminContext | null> {
  const supabase = createClient()
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser()

  if (authError || !user) {
    return null
  }

  const service = createServiceClient()
  const { data: profile } = await service
    .from('profiles')
    .select('id,full_name,first_name,email,is_admin,is_super_admin,is_suspended')
    .eq('id', user.id)
    .single<AdminProfile>()

  if (!profile || !profile.is_admin || profile.is_suspended) {
    return null
  }

  return {
    userId: user.id,
    profile,
  }
}

export async function requireAdminApiContext(_request: NextRequest) {
  const supabase = createClient()
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser()

  if (authError || !user) {
    return { ok: false as const, status: 401, error: 'Authentication required' }
  }

  const service = createServiceClient()
  const { data: profile } = await service
    .from('profiles')
    .select('id,full_name,first_name,email,is_admin,is_super_admin,is_suspended')
    .eq('id', user.id)
    .single<AdminProfile>()

  if (!profile || !profile.is_admin || profile.is_suspended) {
    return { ok: false as const, status: 403, error: 'Admin access required' }
  }

  return {
    ok: true as const,
    context: {
      userId: user.id,
      profile,
    },
  }
}

export function isSuperAdminPath(pathname: string) {
  return pathname.startsWith('/admin/staff') || pathname.startsWith('/admin/settings')
}
