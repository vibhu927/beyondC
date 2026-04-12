import { NextRequest, NextResponse } from 'next/server'

import { createServiceClient } from '@/lib/supabase/service'

export async function GET(request: NextRequest) {
  try {
    const audience = String(request.nextUrl.searchParams.get('audience') || '').trim().toLowerCase()
    if (audience !== 'creator' && audience !== 'brand') {
      return NextResponse.json({ error: 'Invalid audience' }, { status: 400 })
    }

    const service = createServiceClient()

    const { data, error } = await service
      .from('home_carousels')
      .select('id,audience,media_url,media_type,caption,sort_order,created_at')
      .eq('audience', audience)
      .eq('is_active', true)
      .order('sort_order', { ascending: true })
      .order('created_at', { ascending: false })
      .limit(10)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 })
    }

    return NextResponse.json({ items: data ?? [] })
  } catch (error: any) {
    return NextResponse.json({ error: error?.message || 'Failed to fetch carousel' }, { status: 500 })
  }
}
