'use client'

import Image from 'next/image'
import type { CollabRequest } from '@/lib/api/creator'
import { useEffect } from 'react'

interface Props {
  request: CollabRequest | null
  onClose: () => void
}

export default function RequestInfoModal({ request, onClose }: Props) {
  useEffect(() => {
    if (!request) return
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [request, onClose])

  if (!request) return null

  return (
    <>
      <div className="fixed inset-0 z-40 bg-black/40" onClick={onClose} />
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div
          className="relative w-full max-w-lg border-2 border-ink bg-white shadow-[8px_8px_0_#0D0D0D]"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="border-b-2 border-ink px-5 py-4 flex items-center justify-between">
            <h2 className="font-jakarta text-lg font-extrabold text-ink">Request Details</h2>
            <button
              onClick={onClose}
              className="border-2 border-ink bg-white w-8 h-8 flex items-center justify-center font-jakarta text-sm font-bold text-ink hover:bg-pink hover:text-white transition-colors"
            >
              ✕
            </button>
          </div>

          <div className="p-5 space-y-4 max-h-[70vh] overflow-y-auto">
            {/* Brand header */}
            <div className="flex items-center gap-3">
              <div className="relative w-12 h-12 rounded-full border-2 border-ink bg-ink flex items-center justify-center font-jakarta text-lg font-bold text-neon shrink-0 overflow-hidden">
                {request.brand_logo ? (
                  <Image src={request.brand_logo} alt="" fill className="object-cover" />
                ) : (
                  request.brand_name?.[0] || '?'
                )}
              </div>
              <div className="min-w-0 flex-1">
                <p className="font-jakarta text-base font-bold text-ink truncate">{request.brand_name}</p>
                <div className="flex items-center gap-2 mt-0.5">
                  <span className="rounded-full border-2 border-ink bg-neon px-2 py-0.5 font-space text-[9px] font-bold uppercase text-ink">
                    {request.collab_type}
                  </span>
                  <span className={`rounded-full border-2 border-ink px-2 py-0.5 font-space text-[9px] font-bold uppercase ${
                    request.status === 'pending' ? 'bg-yellow-200 text-ink' :
                    request.status === 'accepted' ? 'bg-neon text-ink' :
                    'bg-gray-200 text-muted'
                  }`}>
                    {request.status}
                  </span>
                </div>
              </div>
            </div>

            {/* Message */}
            {request.message && (
              <div>
                <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1">Message</p>
                <p className="font-nunito text-sm text-ink/90 italic">&ldquo;{request.message}&rdquo;</p>
              </div>
            )}

            {/* Budget */}
            <div>
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1">Budget</p>
              <p className="font-jakarta text-xl font-extrabold text-ink">
                {request.budget !== null && request.budget > 0
                  ? `₹${(request.budget / 100).toLocaleString()}`
                  : 'Not specified'}
              </p>
            </div>

            {/* Deliverables */}
            {request.deliverables && request.deliverables.length > 0 && (
              <div>
                <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1.5">Deliverables</p>
                <div className="flex flex-wrap gap-1.5">
                  {request.deliverables.map((d: string) => (
                    <span key={d} className="border-2 border-ink bg-white px-2.5 py-1 font-space text-[10px] font-bold text-ink">
                      {d}
                    </span>
                  ))}
                </div>
              </div>
            )}

            {/* Date */}
            <div>
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1">Requested on</p>
              <p className="font-nunito text-sm text-ink">
                {new Date(request.created_at).toLocaleDateString('en-IN', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                })}
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
