import { NextRequest, NextResponse } from 'next/server'
import { sendPushNotification } from '@/lib/notifications/push'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    await sendPushNotification({
      userId: body.userId,
      title: body.title,
      body: body.body,
      data: body.data,
    })

    return NextResponse.json({ ok: true })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
