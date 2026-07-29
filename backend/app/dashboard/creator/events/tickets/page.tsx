'use client'

import { useQuery } from '@tanstack/react-query'
import { creatorApi, type EventTicket } from '@/lib/api/creator'

export default function MyTicketsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'tickets'],
    queryFn: () => creatorApi.getTickets(),
  })

  const tickets = data?.tickets || []

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">My Tickets</h1>
        <p className="mt-1 font-nunito text-base text-muted">Events you&apos;ve accepted.</p>
      </div>

      {isLoading ? (
        <div className="border-2 border-ink bg-white p-6 animate-pulse space-y-4">
          {[1, 2].map((i) => (
            <div key={i} className="h-20 bg-gray-100 rounded" />
          ))}
        </div>
      ) : tickets.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">🎫</p>
          <p className="font-nunito text-muted">No tickets yet. Accept an event invite to get one.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {tickets.map((ticket: EventTicket) => (
            <div key={ticket.id} className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#C8FF00]">
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="font-jakarta text-lg font-bold text-ink">{ticket.event_title}</h3>
                  <p className="font-nunito text-sm text-muted mt-1">by {ticket.brand_name}</p>
                </div>
                <span className="rounded-full border-2 border-ink bg-neon px-2.5 py-0.5 font-space text-[9px] font-bold uppercase text-ink">
                  Ticket
                </span>
              </div>

              <div className="mt-3 flex items-center gap-4 font-nunito text-sm text-ink/70">
                <span>📍 {ticket.location}</span>
                <span>📅 {new Date(ticket.event_date).toLocaleDateString()}</span>
              </div>

              {ticket.qr_code_data && (
                <div className="mt-4 border-2 border-ink bg-white p-3 text-center">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">QR Code</p>
                  <p className="font-nunito text-sm font-bold text-ink mt-1 break-all">{ticket.qr_code_data}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
