import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/'

  if (code) {
    const supabase = createClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)

    if (!error) {
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        const { data: profile } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single()

        if (profile?.role === 'creator') {
          return NextResponse.redirect(`${origin}/dashboard/creator`)
        } else if (profile?.role === 'brand') {
          return NextResponse.redirect(`${origin}/dashboard/brand`)
        } else if (profile?.role === 'agency') {
          return NextResponse.redirect(`${origin}/dashboard/agency`)
        }
      }
    }
  }

  return NextResponse.redirect(`${origin}/login?error=auth_callback_error`)
}
