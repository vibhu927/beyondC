import { NextResponse } from 'next/server'

export function apiSuccess<T>(data: T) {
  return NextResponse.json({ success: true, data })
}

export function apiError(message: string, status = 400) {
  return NextResponse.json({ error: message }, { status })
}
