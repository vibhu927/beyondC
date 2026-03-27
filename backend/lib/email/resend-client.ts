import { Resend } from 'resend'

if (!process.env.RESEND_API_KEY) {
  throw new Error('RESEND_API_KEY is not set in environment variables')
}

export const resend = new Resend(process.env.RESEND_API_KEY)

const fromName = process.env.RESEND_FROM_NAME || 'BeyondC'
const fromEmail = process.env.RESEND_FROM_EMAIL || 'noreply@beyondc.in'

export const emailConfig = {
  from: `${fromName} <${fromEmail}>`,
  appUrl: process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
}
