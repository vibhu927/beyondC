import { NextResponse, type NextRequest } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Allow public routes
  const publicRoutes = ['/api/auth/signup', '/api/auth/login', '/api/auth/web-signup']
  if (publicRoutes.includes(pathname)) {
    return NextResponse.next()
  }

  // Check if route requires authentication
  if (pathname.startsWith('/api/')) {
    try {
      const supabase = createClient()
      
      // Get current user
      const { data: { user }, error } = await supabase.auth.getUser()
      
      if (error || !user) {
        return NextResponse.json(
          { error: 'Authentication required' },
          { status: 401 }
        )
      }

      // Get user profile to check role
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single()

      if (profileError || !profile) {
        return NextResponse.json(
          { error: 'Profile not found' },
          { status: 404 }
        )
      }

      // Check role-based access
      if (pathname.startsWith('/api/creator/')) {
        if (profile.role !== 'creator') {
          return NextResponse.json(
            { error: 'Creator access required' },
            { status: 403 }
          )
        }
      }

      if (pathname.startsWith('/api/brand/')) {
        if (profile.role !== 'brand') {
          return NextResponse.json(
            { error: 'Brand access required' },
            { status: 403 }
          )
        }
      }

      // Allow request to proceed
      return NextResponse.next()
    } catch (error) {
      return NextResponse.json(
        { error: 'Authentication error' },
        { status: 401 }
      )
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    '/api/:path*',
  ],
}
