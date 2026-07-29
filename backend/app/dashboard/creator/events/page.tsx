'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { creatorApi, type EventInvite } from '@/lib/api/creator'

export default function CreatorEventsPage() {
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'events'],
    queryFn: () => creatorApi.getEvents(),
  })

  const respondMutation = useMutation({
    mutationFn: ({ id, action }: { id: string; action: 'accept' | 'decline' }) =>
      creatorApi.respondToEvent(id, action),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['creator', 'events'] }),
  })

  const invites = data?.invites || []

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-jakarta text-3xl font-extrabold text-ink">Event Invites</h1>
          <p className="mt-1 font-nunito text-base text-muted">Brand events you&apos;re invited to.</p>
        </div>
        <a
          href="/dashboard/creator/events/tickets"
          className="border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon hover:shadow-[3px_3px_0_#C8FF00] transition-all"
        >
          My Tickets →
        </a>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {[1, 2].map((i) => (
            <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse">
              <div className="h-5 bg-gray-200 rounded w-1/2 mb-3" />
              <div className="h-3 bg-gray-200 rounded w-1/3" />
            </div>
          ))}
        </div>
      ) : invites.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">🎪</p>
          <p className="font-nunito text-muted">No event invites yet.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {invites.map((invite: EventInvite) => (
            <div key={invite.id} className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D]">
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="font-jakarta text-lg font-bold text-ink">{invite.event_title}</h3>
                  <p className="font-nunito text-sm text-muted">by {invite.brand_name}</p>
                </div>
                <span className={`shrink-0 rounded-full border-2 border-ink px-2.5 py-0.5 font-space text-[9px] font-bold uppercase ${
                  invite.status === 'pending' ? 'bg-yellow-200 text-ink' :
                  invite.status === 'accepted' ? 'bg-neon text-ink' :
                  'bg-gray-200 text-muted'
                }`}>
                  {invite.status}
                </span>
              </div>

              <div className="mt-3 flex items-center gap-4 font-nunito text-sm text-ink/70">
                <span>📍 {invite.location}</span>
                <span>📅 {new Date(invite.event_date).toLocaleDateString()}</span>
              </div>

              {invite.status === 'pending' && (
                <div className="mt-4 flex gap-3">
                  <button
                    onClick={() => respondMutation.mutate({ id: invite.id, action: 'accept' })}
                    disabled={respondMutation.isPending}
                    className="border-2 border-ink bg-neon px-5 py-2 font-space text-xs font-bold uppercase text-ink disabled:opacity-50"
                  >
                    Accept
                  </button>
                  <button
                    onClick={() => respondMutation.mutate({ id: invite.id, action: 'decline' })}
                    disabled={respondMutation.isPending}
                    className="border-2 border-ink bg-white px-5 py-2 font-space text-xs font-bold uppercase text-ink disabled:opacity-50"
                  >
                    Decline
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
