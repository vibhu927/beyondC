'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi } from '@/lib/api/brand'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { useState } from 'react'

export default function EventInvitesPage() {
  const { id } = useParams<{ id: string }>()
  const router = useRouter()
  const queryClient = useQueryClient()
  const [creatorIds, setCreatorIds] = useState('')
  const [error, setError] = useState('')

  const { data: eventData } = useQuery({
    queryKey: ['brand', 'events'],
    queryFn: () => brandApi.getEvents(),
  })

  const event = eventData?.events?.find((e) => e.id === id)

  const inviteMutation = useMutation({
    mutationFn: (ids: string[]) => brandApi.inviteCreators(id, ids),
    onSuccess: (data) => {
      setCreatorIds('')
      queryClient.invalidateQueries({ queryKey: ['brand', 'events'] })
      setError(`Sent ${data.invites.sent} invites (${data.invites.skipped} skipped)`)
      setTimeout(() => setError(''), 4000)
    },
    onError: (e: Error) => setError(e.message),
  })

  const handleInvite = () => {
    const ids = creatorIds.split(',').map((s) => s.trim()).filter(Boolean)
    if (ids.length === 0) {
      setError('Please enter at least one creator ID')
      return
    }
    inviteMutation.mutate(ids)
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <Link href="/dashboard/brand/events" className="inline-flex items-center gap-2 border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[3px_3px_0_#FF2D78] transition-all">
        ← Back to Events
      </Link>

      <h1 className="font-jakarta text-3xl font-extrabold text-ink">Event Invites</h1>
      {event && <p className="font-nunito text-base text-muted">{event.title} — {event.accepted_count}/{event.total_slots} confirmed</p>}

      {error && <div className={`border-2 px-4 py-3 font-nunito text-sm font-semibold ${error.includes('invites') ? 'border-ink bg-neon text-ink' : 'border-[#EF4444] bg-[#FEE2E2] text-[#B91C1C]'}`}>{error}</div>}

      <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#FF2D78] space-y-4">
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Creator IDs (comma separated)</label>
          <textarea
            value={creatorIds}
            onChange={(e) => setCreatorIds(e.target.value)}
            placeholder="uuid-1, uuid-2, uuid-3"
            rows={3}
            className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none"
          />
        </div>
        <button
          onClick={handleInvite}
          disabled={inviteMutation.isPending}
          className="w-full border-2 border-ink bg-pink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-white shadow-[3px_3px_0_#0D0D0D] disabled:opacity-70"
        >
          {inviteMutation.isPending ? 'Sending...' : 'Send Invites →'}
        </button>
        <p className="font-nunito text-xs text-muted">You can find creator IDs from the Discover page.</p>
      </div>
    </div>
  )
}
