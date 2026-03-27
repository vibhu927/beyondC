'use client'

import { FormEvent, useEffect, useMemo, useState } from 'react'

import { PermissionGate } from '@/components/admin/permission-gate'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Textarea } from '@/components/ui/textarea'

type HistoryRow = {
  id: string
  admin_id: string
  created_at: string
  details: Record<string, unknown> | null
}

type Props = {
  pushHistory: HistoryRow[]
  emailHistory: HistoryRow[]
}

type EmailTarget = 'all' | 'creators' | 'brands' | 'specific'

const emailTargetOptions: { value: EmailTarget; label: string }[] = [
  { value: 'all', label: 'All Users' },
  { value: 'creators', label: 'Creators Only' },
  { value: 'brands', label: 'Brands Only' },
  { value: 'specific', label: 'Specific Emails' },
]

export function NotificationsClient({ pushHistory, emailHistory }: Props) {
  const [pushTarget, setPushTarget] = useState('all_users')
  const [pushTitle, setPushTitle] = useState('')
  const [pushBody, setPushBody] = useState('')
  const [sendingPush, setSendingPush] = useState(false)
  const [pushMessage, setPushMessage] = useState('')

  const [target, setTarget] = useState<EmailTarget>('all')
  const [specificEmails, setSpecificEmails] = useState('')
  const [subject, setSubject] = useState('')
  const [bodyHtml, setBodyHtml] = useState('')
  const [ctaEnabled, setCtaEnabled] = useState(false)
  const [ctaText, setCtaText] = useState('')
  const [ctaLink, setCtaLink] = useState('')
  const [estimatedCount, setEstimatedCount] = useState<number | null>(null)
  const [countLoading, setCountLoading] = useState(false)
  const [sendingEmail, setSendingEmail] = useState(false)
  const [emailResult, setEmailResult] = useState<{ succeeded: number; failed: number } | null>(null)
  const [emailError, setEmailError] = useState('')

  const specificEmailsQuery = useMemo(() => {
    return specificEmails
      .split(',')
      .map((item) => item.trim().toLowerCase())
      .filter(Boolean)
      .join(',')
  }, [specificEmails])

  useEffect(() => {
    const timer = setTimeout(async () => {
      try {
        setCountLoading(true)
        const params = new URLSearchParams({ target })
        if (target === 'specific' && specificEmailsQuery) {
          params.set('specificEmails', specificEmailsQuery)
        }

        const response = await fetch(`/api/admin/emails/count?${params.toString()}`)
        const payload = await response.json()

        if (!response.ok) {
          setEstimatedCount(0)
          return
        }

        setEstimatedCount(Number(payload.count || payload.data?.count || 0))
      } catch {
        setEstimatedCount(0)
      } finally {
        setCountLoading(false)
      }
    }, 500)

    return () => clearTimeout(timer)
  }, [target, specificEmailsQuery])

  const handlePushSubmit = async (event: FormEvent) => {
    event.preventDefault()
    setSendingPush(true)
    setPushMessage('')

    try {
      const response = await fetch('/api/admin/notifications/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          target: pushTarget,
          title: pushTitle,
          body: pushBody,
        }),
      })

      const payload = await response.json()
      if (!response.ok) {
        setPushMessage(payload.error || 'Failed to send notification')
        return
      }

      setPushMessage(`✅ Sent push notification to ${payload.data?.recipients || 0} users.`)
      setPushTitle('')
      setPushBody('')
    } catch {
      setPushMessage('Failed to send notification')
    } finally {
      setSendingPush(false)
    }
  }

  const handleEmailSubmit = async (event: FormEvent) => {
    event.preventDefault()
    setSendingEmail(true)
    setEmailResult(null)
    setEmailError('')

    try {
      const response = await fetch('/api/admin/emails/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          target,
          specificEmails: target === 'specific' ? specificEmailsQuery.split(',').filter(Boolean) : undefined,
          subject,
          bodyHtml,
          ctaText: ctaEnabled ? ctaText : undefined,
          ctaLink: ctaEnabled ? ctaLink : undefined,
        }),
      })

      const payload = await response.json()
      if (!response.ok) {
        setEmailError(payload.error || 'Could not send promotional emails')
        return
      }

      const result = payload.data || payload
      setEmailResult({
        succeeded: Number(result.succeeded || 0),
        failed: Number(result.failed || 0),
      })
    } catch {
      setEmailError('Could not send promotional emails')
    } finally {
      setSendingEmail(false)
    }
  }

  return (
    <PermissionGate page="notifications" action="can_view">
      <div className="space-y-4">
        <Tabs defaultValue="push" className="w-full">
          <TabsList>
            <TabsTrigger value="push">🔔 Push</TabsTrigger>
            <TabsTrigger value="email">📧 Email</TabsTrigger>
          </TabsList>

          <TabsContent value="push" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Send Push Notification</CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handlePushSubmit} className="space-y-3">
                  <Input
                    value={pushTarget}
                    onChange={(event) => setPushTarget(event.target.value)}
                    placeholder="all_users / all_creators / all_brands / user_id"
                    required
                  />
                  <Input value={pushTitle} onChange={(event) => setPushTitle(event.target.value)} placeholder="Notification title" required />
                  <Textarea value={pushBody} onChange={(event) => setPushBody(event.target.value)} placeholder="Notification message" required />
                  <Button type="submit" disabled={sendingPush}>{sendingPush ? 'Sending...' : 'Send Push →'}</Button>
                </form>
                {pushMessage ? <p className="mt-3 text-sm text-zinc-700 dark:text-zinc-300">{pushMessage}</p> : null}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Push History</CardTitle>
              </CardHeader>
              <CardContent className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Target</TableHead>
                      <TableHead>Title</TableHead>
                      <TableHead>Sent By</TableHead>
                      <TableHead>Sent At</TableHead>
                      <TableHead>Recipients</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pushHistory.map((row) => (
                      <TableRow key={row.id}>
                        <TableCell>{String(row.details?.target || '-')}</TableCell>
                        <TableCell>{String(row.details?.title || '-')}</TableCell>
                        <TableCell>{row.admin_id}</TableCell>
                        <TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                        <TableCell>{String(row.details?.recipients_count || 0)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="email" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Send Promotional Email</CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleEmailSubmit} className="space-y-4">
                  <div>
                    <p className="mb-2 text-sm font-medium">Target Audience</p>
                    <div className="grid gap-2 sm:grid-cols-2">
                      {emailTargetOptions.map((option) => (
                        <label key={option.value} className="flex items-center gap-2 rounded-md border p-2 text-sm">
                          <input
                            type="radio"
                            name="email-target"
                            checked={target === option.value}
                            onChange={() => setTarget(option.value)}
                          />
                          {option.label}
                        </label>
                      ))}
                    </div>
                    {target === 'specific' ? (
                      <Input
                        className="mt-2"
                        value={specificEmails}
                        onChange={(event) => setSpecificEmails(event.target.value)}
                        placeholder="a@x.com, b@y.com"
                      />
                    ) : null}
                    <p className="mt-2 text-xs text-zinc-500">
                      {countLoading ? 'Calculating recipients...' : `~${estimatedCount ?? 0} recipients`}
                    </p>
                  </div>

                  <Input value={subject} onChange={(event) => setSubject(event.target.value)} placeholder="Subject line" required />

                  <div className="grid gap-3 lg:grid-cols-2">
                    <Textarea
                      value={bodyHtml}
                      onChange={(event) => setBodyHtml(event.target.value)}
                      placeholder="Write plain text or HTML"
                      required
                      className="min-h-[180px]"
                    />
                    <div className="min-h-[180px] rounded-md border bg-zinc-50 p-3 text-sm dark:bg-zinc-950">
                      <p className="mb-2 text-xs font-medium uppercase text-zinc-500">Live Preview</p>
                      <div dangerouslySetInnerHTML={{ __html: bodyHtml || '<p>Your email preview appears here.</p>' }} />
                    </div>
                  </div>

                  <div className="rounded-md border p-3">
                    <label className="mb-2 flex items-center gap-2 text-sm font-medium">
                      <input type="checkbox" checked={ctaEnabled} onChange={(event) => setCtaEnabled(event.target.checked)} />
                      Add optional CTA button
                    </label>
                    {ctaEnabled ? (
                      <div className="grid gap-2 sm:grid-cols-2">
                        <Input value={ctaText} onChange={(event) => setCtaText(event.target.value)} placeholder="CTA Button Text" />
                        <Input value={ctaLink} onChange={(event) => setCtaLink(event.target.value)} placeholder="https://..." />
                      </div>
                    ) : null}
                  </div>

                  <Button variant="default" className="bg-pink text-white hover:bg-pink/90" type="submit" disabled={sendingEmail}>
                    {sendingEmail ? 'Sending... please wait' : 'Send Email →'}
                  </Button>
                </form>

                {emailResult ? (
                  <div className="mt-3 rounded-md border border-green-300 bg-green-50 p-3 text-sm text-green-900">
                    ✅ Sent to {emailResult.succeeded} recipients. {emailResult.failed} failed.
                  </div>
                ) : null}

                {emailError ? (
                  <div className="mt-3 rounded-md border border-red-300 bg-red-50 p-3 text-sm text-red-900">{emailError}</div>
                ) : null}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Email History</CardTitle>
              </CardHeader>
              <CardContent className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Subject</TableHead>
                      <TableHead>Target</TableHead>
                      <TableHead>Recipients</TableHead>
                      <TableHead>Succeeded</TableHead>
                      <TableHead>Failed</TableHead>
                      <TableHead>Sent By</TableHead>
                      <TableHead>Date</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {emailHistory.map((row) => (
                      <TableRow key={row.id}>
                        <TableCell>{String(row.details?.subject || '-')}</TableCell>
                        <TableCell>
                          <Badge>{String(row.details?.target || '-')}</Badge>
                        </TableCell>
                        <TableCell>{String(row.details?.total || 0)}</TableCell>
                        <TableCell>{String(row.details?.succeeded || 0)}</TableCell>
                        <TableCell>{String(row.details?.failed || 0)}</TableCell>
                        <TableCell>{row.admin_id}</TableCell>
                        <TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </PermissionGate>
  )
}
