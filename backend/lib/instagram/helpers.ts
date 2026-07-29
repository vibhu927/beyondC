import type { SupabaseClient } from '@supabase/supabase-js'

export async function checkInstagramNotClaimed(
  admin: SupabaseClient,
  username: string,
  currentUserId: string
): Promise<string | null> {
  const { data: existingCreator } = await admin
    .from('creator_profiles')
    .select('id')
    .eq('instagram_username', username)
    .eq('instagram_verified', true)
    .neq('id', currentUserId)
    .maybeSingle()

  if (existingCreator) {
    return 'This Instagram account is already linked to another Beyond C account.'
  }

  const { data: existingBrand } = await admin
    .from('brand_profiles')
    .select('id')
    .eq('instagram_username', username)
    .eq('instagram_verified', true)
    .neq('id', currentUserId)
    .maybeSingle()

  if (existingBrand) {
    return 'This Instagram account is already linked to another Beyond C account.'
  }

  return null
}
