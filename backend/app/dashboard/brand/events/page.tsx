'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type BrandEvent } from '@/lib/api/brand'
import Link from 'next/link'

export default function BrandEventsPage() {
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['brand', 'events'],
    queryFn: () => brandApi.getEvents(),
  })

  const events = data?.events || []

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-jakarta text-3xl font-extrabold text-ink">My Events</h1>
          <p className="mt-1 font-nunito text-base text-muted">Manage your brand events.</p>
        </div>
        <Link href="/dashboard/brand/events/create" className="border-2 border-ink bg-pink px-5 py-3 font-space text-xs font-bold uppercase text-white hover:shadow-[4px_4px_0_#0D0D0D] transition-all">+ New Event</Link>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {[1, 2].map((i) => <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse"><div className="h-5 bg-gray-200 rounded w-1/2 mb-3" /></div>)}
        </div>
      ) : events.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">🎪</p>
          <p className="font-nunito text-muted">No events yet.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {events.map((event: BrandEvent) => (
            <div key={event.id} className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D]">
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="font-jakarta text-lg font-bold text-ink">{event.title}</h3>
                  <p className="font-nunito text-sm text-muted mt-1">{event.description}</p>
                </div>
                <span className={`shrink-0 rounded-full border-2 border-ink px-2.5 py-0.5 font-space text-[9px] font-bold uppercase ${
                  event.status === 'active' ? 'bg-neon text-ink' : 'bg-gray-200 text-muted'
                }`}>{event.status}</span>
              </div>
              <div className="mt-3 flex items-center gap-4 font-nunito text-xs text-ink/70">
                <span>📍 {event.location}</span>
                <span>📅 {new Date(event.event_date).toLocaleDateString()}</span>
                <span>🎫 {event.accepted_count}/{event.total_slots} confirmed</span>
              </div>
              <div className="mt-3 flex gap-2">
                <Link href={`/dashboard/brand/events/${event.id}/invites`} className="border-2 border-ink bg-pink px-3 py-1 font-space text-[9px] font-bold text-white">Manage Invites</Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
