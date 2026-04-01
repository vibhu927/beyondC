import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const unread_only = searchParams.get('unread_only') === 'true'
    const page = Math.max(Number(searchParams.get('page') || '1') || 1, 1)
    const limitRaw = Number(searchParams.get('limit') || '10') || 10
    const limit = Math.min(Math.max(limitRaw, 1), 50)
    const from = (page - 1) * limit
    const to = from + limit - 1

    let query = supabase
      .from('notifications')
      .select('*', { count: 'exact' })
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .range(from, to)

    if (unread_only) {
      query = query.eq('read', false)
    }

    const { data: notifications, error, count } = await query

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const total = count ?? notifications?.length ?? 0
    const totalPages = total === 0 ? 1 : Math.ceil(total / limit)

    return NextResponse.json({
      notifications,
      pagination: {
        page,
        limit,
        total,
        totalPages,
      },
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
