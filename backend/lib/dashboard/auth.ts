import { createClient } from '@/lib/supabase/server'

export type DashboardUser = {
  id: string
  firstName: string
  fullName: string
  email: string
  role: 'creator' | 'brand'
}

export async function getDashboardUser(): Promise<DashboardUser | null> {
  const supabase = createClient()
  const { data: { user }, error } = await supabase.auth.getUser()

  if (error || !user) return null

  const { data: profile } = await supabase
    .from('profiles')
    .select('first_name, full_name, email, role')
    .eq('id', user.id)
    .single()

  if (!profile || (profile.role !== 'creator' && profile.role !== 'brand')) return null

  return {
    id: user.id,
    firstName: profile.first_name || user.email?.split('@')[0] || 'User',
    fullName: profile.full_name || '',
    email: user.email || '',
    role: profile.role,
  }
}
