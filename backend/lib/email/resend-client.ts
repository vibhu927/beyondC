import { Resend } from 'resend'

let resendClient: Resend | null = null

export function getResendClient() {
  if (resendClient) {
    return resendClient
  }

  const apiKey = process.env.RESEND_API_KEY?.trim()
  if (!apiKey) {
    throw new Error('RESEND_API_KEY is not set in environment variables')
  }

  resendClient = new Resend(apiKey)
  return resendClient
}

const fromName = process.env.RESEND_FROM_NAME || 'BeyondC'
const fromEmail = process.env.RESEND_FROM_EMAIL || 'noreply@beyondc.in'

export const emailConfig = {
  from: `${fromName} <${fromEmail}>`,
  appUrl: process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
}
