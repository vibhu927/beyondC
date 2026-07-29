import { NextResponse, type NextRequest } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { createClient } from '@supabase/supabase-js'
import type { CookieOptions } from '@supabase/ssr'

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl
  const response = NextResponse.next()

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return request.cookies.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          response.cookies.set({ name, value, ...options })
        },
        remove(name: string, options: CookieOptions) {
          response.cookies.set({ name, value: '', ...options })
        },
      },
    }
  )

  const service = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  if (pathname === '/admin') {
    return NextResponse.redirect(new URL('/admin/dashboard', request.url))
  }

  if (pathname === '/dashboard') {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  const {
    data: { session },
  } = await supabase.auth.getSession()

  if (pathname === '/join/success' && !session) {
    return NextResponse.redirect(new URL('/join', request.url))
  }

  if (pathname.startsWith('/dashboard') && !session) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  if (pathname.startsWith('/admin') && !pathname.startsWith('/admin/login')) {
    if (!session) {
      return NextResponse.redirect(new URL('/admin/login', request.url))
    }

    const { data: profile } = await service
      .from('profiles')
      .select('is_admin,is_super_admin,is_suspended')
      .eq('id', session.user.id)
      .single()

    if (!profile?.is_admin || profile.is_suspended) {
      return NextResponse.redirect(new URL('/admin/login', request.url))
    }

    const requiresSuperAdmin =
      pathname.startsWith('/admin/staff') || pathname.startsWith('/admin/settings')

    if (requiresSuperAdmin && !profile.is_super_admin) {
      return NextResponse.redirect(new URL('/admin/unauthorized', request.url))
    }
  }

  return response
}

export const config = {
  matcher: [
    '/join/success',
    '/admin/:path*',
    '/admin',
    '/dashboard/:path*',
    '/dashboard',
    '/reset-password',
  ],
}
