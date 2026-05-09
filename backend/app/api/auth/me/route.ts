import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get user profile
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()

    if (profileError) {
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 })
    }

    // Get role-specific profile
    let roleProfile = null
    if (profile.role === 'creator') {
      const { data, error } = await supabase
        .from('creator_profiles')
        .select('*')
        .eq('id', user.id)
        .single()
      
      if (!error) roleProfile = data
    } else if (profile.role === 'brand') {
      const { data, error } = await supabase
        .from('brand_profiles')
        .select('*')
        .eq('id', user.id)
        .single()
      
      if (!error) roleProfile = data
    }

    return NextResponse.json({
      user,
      profile,
      roleProfile,
    })
  } catch (error: any) {
    console.error('Get user error:', error)
    return NextResponse.json(
      { error: error.message || 'Failed to fetch user' },
      { status: 400 }
    )
  }
}
