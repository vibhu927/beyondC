import sanitizeHtml from 'sanitize-html'
import { renderToStaticMarkup } from 'react-dom/server'

import { emailConfig, resend } from '@/lib/email/resend-client'
import { ForgotPasswordEmail } from '@/lib/email/templates/forgot-password'
import { PromotionalEmail } from '@/lib/email/templates/promotional'

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

export const emailService = {
  async sendForgotPassword({ to, firstName, resetLink }: SendForgotPasswordArgs) {
    return resend.emails.send({
      from: emailConfig.from,
      to,
      subject: 'Reset your BeyondC password 🔑',
      html: renderToStaticMarkup(ForgotPasswordEmail({ firstName, resetLink })),
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
      html: renderToStaticMarkup(
        PromotionalEmail({
          firstName,
          bodyHtml: cleanHtml,
          ctaText,
          ctaLink,
        })
      ),
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
}
