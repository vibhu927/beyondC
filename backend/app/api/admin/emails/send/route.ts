import { NextRequest } from 'next/server'

import { apiError, apiSuccess } from '@/lib/admin/api'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { writeAdminLog } from '@/lib/admin/logs'
import { parseRequestBody } from '@/lib/admin/request'
import { emailService } from '@/lib/email/email-service'
import { createServiceClient } from '@/lib/supabase/service'

export async function POST(request: NextRequest) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const body = await parseRequestBody(request)

  const target = String(body.target || 'all')
  const specificEmails = Array.isArray(body.specificEmails)
    ? body.specificEmails.map((value: unknown) => String(value).trim().toLowerCase()).filter(Boolean)
    : String(body.specificEmails || '')
        .split(',')
        .map((value) => value.trim().toLowerCase())
        .filter(Boolean)

  const subject = String(body.subject || '').trim()
  const bodyHtml = String(body.bodyHtml || '').trim()
  const ctaText = String(body.ctaText || '').trim() || undefined
  const ctaLink = String(body.ctaLink || '').trim() || undefined

  if (!subject || !bodyHtml) {
    return apiError('subject and bodyHtml are required', 400)
  }

  const service = createServiceClient()

  let recipientsQuery = service
    .from('profiles')
    .select('email,first_name')
    .eq('is_onboarded', true)
    .not('email', 'is', null)

  if (target === 'creators') {
    recipientsQuery = recipientsQuery.eq('role', 'creator')
  } else if (target === 'brands') {
    recipientsQuery = recipientsQuery.eq('role', 'brand')
  } else if (target === 'specific') {
    if (specificEmails.length === 0) {
      return apiError('specificEmails is required when target=specific', 400)
    }
    recipientsQuery = recipientsQuery.in('email', specificEmails)
  }

  const { data: recipients, error: recipientsError } = await recipientsQuery

  if (recipientsError) {
    return apiError(recipientsError.message, 500)
  }

  if (!recipients || recipients.length === 0) {
    return apiError('No recipients found', 404)
  }

  const normalizedRecipients = recipients
    .map((recipient) => ({
      email: String(recipient.email || '').trim().toLowerCase(),
      firstName: String(recipient.first_name || 'there'),
    }))
    .filter((recipient) => recipient.email.length > 0)

  const result = await emailService.sendBulkPromotional({
    recipients: normalizedRecipients,
    subject,
    bodyHtml,
    ctaText,
    ctaLink,
  })

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'sent_promotional_email',
    targetType: 'email',
    details: {
      target,
      subject,
      succeeded: result.succeeded,
      failed: result.failed,
      total: result.total,
    },
  })

  return apiSuccess({ success: true, ...result })
}
