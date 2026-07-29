'use client'

import Image from 'next/image'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { creatorApi, type CollabRequest } from '@/lib/api/creator'
import { useState } from 'react'
import RequestInfoModal from '@/components/dashboard/request-info-modal'

export default function CreatorRequestsPage() {
  const queryClient = useQueryClient()
  const [actionMsg, setActionMsg] = useState('')
  const [infoRequest, setInfoRequest] = useState<CollabRequest | null>(null)

  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'requests'],
    queryFn: () => creatorApi.getRequests(),
  })

  const respondMutation = useMutation({
    mutationFn: ({ id, action }: { id: string; action: 'accept' | 'decline' }) =>
      creatorApi.respondToRequest(id, action),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['creator', 'requests'] })
      setActionMsg('Request updated successfully!')
      setTimeout(() => setActionMsg(''), 3000)
    },
    onError: (e: Error) => {
      setActionMsg(e.message)
      setTimeout(() => setActionMsg(''), 3000)
    },
  })

  const requests = data?.requests || []

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Incoming Requests</h1>
        <p className="mt-1 font-nunito text-base text-muted">Brands reaching out for collaborations.</p>
      </div>

      {actionMsg && (
        <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">
          {actionMsg}
        </div>
      )}

      {isLoading ? (
        <div className="border-2 border-ink bg-white p-6 animate-pulse space-y-4">
          {[1, 2].map((i) => (
            <div key={i} className="h-24 bg-gray-100 rounded" />
          ))}
        </div>
      ) : requests.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">📨</p>
          <p className="font-nunito text-muted">No incoming requests yet.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {requests.map((req: CollabRequest) => (
            <div key={req.id} className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D]">
              <div className="flex items-center gap-3 mb-3">
                <div className="relative w-12 h-12 rounded-full border-2 border-ink bg-ink flex items-center justify-center font-jakarta text-lg font-bold text-neon shrink-0 overflow-hidden">
                  {req.brand_logo ? (
                    <Image src={req.brand_logo} alt="" fill className="object-cover" />
                  ) : (
                    req.brand_name?.[0] || '?'
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-jakarta text-lg font-bold text-ink truncate">{req.brand_name}</h3>
                  <span className={`rounded-full border-2 border-ink px-2.5 py-0.5 font-space text-[9px] font-bold uppercase ${
                    req.status === 'pending' ? 'bg-yellow-200 text-ink' :
                    req.status === 'accepted' ? 'bg-neon text-ink' :
                    'bg-gray-200 text-muted'
                  }`}>
                    {req.status}
                  </span>
                </div>
                <span className="shrink-0 rounded-full border-2 border-ink bg-white px-2.5 py-0.5 font-space text-[9px] font-bold text-ink capitalize">
                  {req.collab_type}
                </span>
              </div>

              {req.message && (
                <p className="font-nunito text-sm text-ink/80 mb-3 italic">&ldquo;{req.message}&rdquo;</p>
              )}

              <div className="grid grid-cols-2 gap-3 mb-3">
                {req.budget !== null && req.budget > 0 && (
                  <div className="border border-ink bg-white px-3 py-1.5">
                    <p className="font-space text-[9px] font-bold uppercase text-muted">Budget</p>
                    <p className="font-nunito text-sm font-bold text-ink">₹{(req.budget / 100).toLocaleString()}</p>
                  </div>
                )}
                {req.deliverables && req.deliverables.length > 0 && (
                  <div className="border border-ink bg-white px-3 py-1.5">
                    <p className="font-space text-[9px] font-bold uppercase text-muted">Deliverables</p>
                    <div className="flex flex-wrap gap-1 mt-0.5">
                      {req.deliverables.map((d: string) => (
                        <span key={d} className="border border-ink bg-white px-1.5 py-0.5 font-space text-[8px] font-bold text-ink">
                          {d}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {req.status === 'pending' && (
                <div className="flex gap-3 mt-4">
                  <button
                    onClick={() => respondMutation.mutate({ id: req.id, action: 'accept' })}
                    disabled={respondMutation.isPending}
                    className="border-2 border-ink bg-neon px-5 py-2 font-space text-xs font-bold uppercase text-ink disabled:opacity-50"
                  >
                    Accept
                  </button>
                  <button
                    onClick={() => respondMutation.mutate({ id: req.id, action: 'decline' })}
                    disabled={respondMutation.isPending}
                    className="border-2 border-ink bg-white px-5 py-2 font-space text-xs font-bold uppercase text-ink disabled:opacity-50"
                  >
                    Decline
                  </button>
                  <button
                    onClick={() => setInfoRequest(req)}
                    className="border-2 border-ink bg-ink ml-auto px-4 py-2 font-space text-xs font-bold uppercase text-neon"
                  >
                    Info
                  </button>
                </div>
              )}

              {req.status !== 'pending' && (
                <div className="flex justify-end mt-4">
                  <button
                    onClick={() => setInfoRequest(req)}
                    className="border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold uppercase text-neon"
                  >
                    Info
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      <RequestInfoModal request={infoRequest} onClose={() => setInfoRequest(null)} />
    </div>
  )
}
