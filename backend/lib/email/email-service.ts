import sanitizeHtml from 'sanitize-html'
import nodemailer, { type Transporter } from 'nodemailer'

import { emailConfig, resend } from '@/lib/email/resend-client'
import { ForgotPasswordEmail } from '@/lib/email/templates/forgot-password'
import { PromotionalEmail } from '@/lib/email/templates/promotional'
import { buildWaitlistWelcomeHtml } from '@/lib/email/templates/waitlist-welcome'

type SendForgotPasswordArgs = {
  to: string
  firstName: string
  resetLink: string
}

type SendPromotionalArgs = {
  to: string
  firstName: string
  subject: string
  bodyHtml: string
  ctaText?: string
  ctaLink?: string
}

type SendBulkPromotionalArgs = {
  recipients: { email: string; firstName: string }[]
  subject: string
  bodyHtml: string
  ctaText?: string
  ctaLink?: string
}

type SendWaitlistWelcomeArgs = {
  to: string
  firstName: string
}

type ResendSendResult = {
  data?: { id?: string } | null
  error?: { message?: string; name?: string } | null
}

type EmailProvider = 'resend' | 'gmail_smtp'

let smtpTransporter: Transporter | null = null

function getEmailProvider(): EmailProvider {
  const provider = (process.env.EMAIL_PROVIDER || '').toLowerCase().trim()

  if (provider === 'gmail_smtp') {
    return 'gmail_smtp'
  }

  if (provider === 'resend') {
    return 'resend'
  }

  // Auto-pick Gmail when credentials are present, otherwise keep Resend default.
  const hasGmailCreds = Boolean(
    process.env.GMAIL_SMTP_USER?.trim() && process.env.GMAIL_SMTP_APP_PASSWORD?.trim()
  )
  return hasGmailCreds ? 'gmail_smtp' : 'resend'
}

function getSmtpTransporter() {
  if (smtpTransporter) {
    return smtpTransporter
  }

  const user = process.env.GMAIL_SMTP_USER?.trim()
  const pass = process.env.GMAIL_SMTP_APP_PASSWORD?.replace(/\s+/g, '')

  if (!user || !pass) {
    throw new Error('GMAIL_SMTP_USER or GMAIL_SMTP_APP_PASSWORD is missing')
  }

  smtpTransporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user,
      pass,
    },
  })

  return smtpTransporter
}

export const emailService = {
  async sendForgotPassword({ to, firstName, resetLink }: SendForgotPasswordArgs) {
    return resend.emails.send({
      from: emailConfig.from,
      to,
      subject: 'Reset your BeyondC password 🔑',
      react: ForgotPasswordEmail({ firstName, resetLink }),
    })
  },

  async sendPromotional({ to, firstName, subject, bodyHtml, ctaText, ctaLink }: SendPromotionalArgs) {
    const cleanHtml = sanitizeHtml(bodyHtml, {
      allowedTags: sanitizeHtml.defaults.allowedTags.concat(['h1', 'h2', 'img']),
      allowedAttributes: {
        ...sanitizeHtml.defaults.allowedAttributes,
        '*': ['style'],
      },
    })

    return resend.emails.send({
      from: emailConfig.from,
      to,
      subject,
      react: PromotionalEmail({
        firstName,
        bodyHtml: cleanHtml,
        ctaText,
        ctaLink,
      }),
    })
  },

  async sendBulkPromotional({ recipients, subject, bodyHtml, ctaText, ctaLink }: SendBulkPromotionalArgs) {
    const BATCH_SIZE = 50
    const results: PromiseSettledResult<unknown>[] = []

    for (let i = 0; i < recipients.length; i += BATCH_SIZE) {
      const batch = recipients.slice(i, i + BATCH_SIZE)
      const batchResults = await Promise.allSettled(
        batch.map((recipient) =>
          emailService.sendPromotional({
            to: recipient.email,
            firstName: recipient.firstName,
            subject,
            bodyHtml,
            ctaText,
            ctaLink,
          })
        )
      )

      results.push(...batchResults)

      if (i + BATCH_SIZE < recipients.length) {
        await new Promise((resolve) => setTimeout(resolve, 1000))
      }
    }

    return {
      succeeded: results.filter((r) => r.status === 'fulfilled').length,
      failed: results.filter((r) => r.status === 'rejected').length,
      total: recipients.length,
    }
  },

  async sendWaitlistWelcome({ to, firstName }: SendWaitlistWelcomeArgs) {
    if (getEmailProvider() === 'gmail_smtp') {
      const smtpUser = process.env.GMAIL_SMTP_USER?.trim()
      const smtpFromEmail = process.env.GMAIL_FROM_EMAIL?.trim() || smtpUser
      const smtpFromName = process.env.GMAIL_FROM_NAME || 'BeyondC'

      if (!smtpFromEmail) {
        throw new Error('GMAIL_FROM_EMAIL or GMAIL_SMTP_USER is required for gmail_smtp provider')
      }

      const transporter = getSmtpTransporter()
      const info = await transporter.sendMail({
        from: `${smtpFromName} <${smtpFromEmail}>`,
        to,
        subject: 'You are on the BeyondC waitlist',
        html: buildWaitlistWelcomeHtml({ firstName }),
      })

      if (!info.messageId) {
        throw new Error('Gmail SMTP did not return a message id for waitlist email')
      }

      return { data: { id: info.messageId } }
    }

    const waitlistFrom = process.env.RESEND_WAITLIST_FROM || 'BeyondC <onboarding@resend.dev>'

    const result = await resend.emails.send({
      from: waitlistFrom,
      to,
      subject: 'You are on the BeyondC waitlist',
      html: buildWaitlistWelcomeHtml({ firstName }),
    })

    const typedResult = result as ResendSendResult
    if (typedResult?.error) {
      const reason = typedResult.error.message || typedResult.error.name || 'Unknown Resend error'
      throw new Error(`Resend rejected waitlist email: ${reason}`)
    }

    if (!typedResult?.data?.id) {
      throw new Error('Resend did not return a message id for waitlist email')
    }

    return typedResult
  },
}
