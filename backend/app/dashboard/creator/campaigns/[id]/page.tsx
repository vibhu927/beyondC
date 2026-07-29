'use client'

import Image from 'next/image'
import { useQuery } from '@tanstack/react-query'
import { creatorApi } from '@/lib/api/creator'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { useState } from 'react'

export default function CampaignDetailPage() {
  const { id } = useParams<{ id: string }>()
  const router = useRouter()
  const [bidAmount, setBidAmount] = useState('')
  const [bidMessage, setBidMessage] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [showBidForm, setShowBidForm] = useState(false)
  const [error, setError] = useState('')

  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'campaign', id],
    queryFn: async () => {
      const res = await creatorApi.getCampaigns()
      const campaign = res.campaigns.find((c) => c.id === id)
      if (!campaign) throw new Error('Campaign not found')
      return campaign
    },
  })

  const handlePlaceBid = async () => {
    if (!bidAmount || Number(bidAmount) <= 0) {
      setError('Please enter a valid bid amount')
      return
    }
    setSubmitting(true)
    setError('')
    try {
      await creatorApi.placeBid(id, Number(bidAmount) * 100, bidMessage || undefined)
      router.push('/dashboard/creator/bids')
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to place bid')
    } finally {
      setSubmitting(false)
    }
  }

  if (isLoading) {
    return (
      <div className="max-w-3xl mx-auto">
        <div className="border-2 border-ink bg-white p-8 animate-pulse">
          <div className="h-6 bg-gray-200 rounded w-2/3 mb-4" />
          <div className="h-4 bg-gray-200 rounded w-full mb-2" />
          <div className="h-4 bg-gray-200 rounded w-3/4" />
        </div>
      </div>
    )
  }

  if (!data) {
    return (
      <div className="max-w-3xl mx-auto">
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">🔍</p>
          <p className="font-nunito text-muted">Campaign not found.</p>
          <Link href="/dashboard/creator/campaigns" className="mt-4 inline-block border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon">
            ← Back to Campaigns
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <Link
        href="/dashboard/creator/campaigns"
        className="inline-flex items-center gap-2 border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[3px_3px_0_#C8FF00] transition-all"
      >
        ← Back to Campaigns
      </Link>

      <div className="border-2 border-ink bg-white shadow-[6px_6px_0_#C8FF00]">
        <div className="p-6 sm:p-8">
          <div className="flex items-start justify-between gap-4">
            <div className="flex-1">
              <h1 className="font-jakarta text-2xl font-extrabold text-ink sm:text-3xl">{data.title}</h1>
              <div className="mt-2 flex items-center gap-2">
                {data.brand_logo && (
                  <Image src={data.brand_logo} alt="" width={24} height={24} className="rounded-full border border-ink object-cover" />
                )}
                <p className="font-space text-xs font-bold uppercase tracking-[0.08em] text-muted">
                  by {data.brand_name}
                </p>
              </div>
            </div>
            <span className="shrink-0 rounded-full border-2 border-ink bg-neon px-3 py-1 font-space text-[10px] font-bold uppercase text-ink">
              {data.collab_type}
            </span>
          </div>

          <p className="mt-4 font-nunito text-base text-ink/80 leading-relaxed">{data.description}</p>

          <div className="mt-6 grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase tracking-[0.08em] text-muted">Budget</p>
              <p className="font-jakarta text-sm font-bold text-ink">
                ₹{((data.budget_min || 0)).toLocaleString()} - ₹{((data.budget_max || 0)).toLocaleString()}
              </p>
            </div>
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase tracking-[0.08em] text-muted">Bids</p>
              <p className="font-jakarta text-sm font-bold text-ink">{data.bid_count}</p>
            </div>
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase tracking-[0.08em] text-muted">Slots</p>
              <p className="font-jakarta text-sm font-bold text-ink">{data.slots_filled}/{data.slots_total}</p>
            </div>
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase tracking-[0.08em] text-muted">Deadline</p>
              <p className="font-jakarta text-sm font-bold text-ink">
                {new Date(data.deadline).toLocaleDateString()}
              </p>
            </div>
          </div>

          <div className="mt-6">
            <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-2">Deliverables</p>
            <div className="flex flex-wrap gap-2">
              {data.deliverables?.map((d: string) => (
                <span key={d} className="border-2 border-ink bg-white px-2.5 py-1 font-nunito text-xs font-semibold text-ink">
                  {d}
                </span>
              ))}
            </div>
          </div>

          {data.requirements && (
            <div className="mt-4">
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1">Requirements</p>
              <p className="font-nunito text-sm text-ink/80">{data.requirements}</p>
            </div>
          )}

          <div className="mt-4">
            <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-2">Niches</p>
            <div className="flex flex-wrap gap-1.5">
              {data.niche?.map((n: string) => (
                <span key={n} className="border border-ink bg-neon/30 px-2 py-0.5 font-space text-[9px] font-bold text-ink">
                  {n}
                </span>
              ))}
            </div>
          </div>
        </div>
      </div>

      {!showBidForm ? (
        <button
          onClick={() => setShowBidForm(true)}
          className="w-full border-2 border-ink bg-ink px-6 py-4 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon shadow-[4px_4px_0_#C8FF00] hover:shadow-[6px_6px_0_#C8FF00] transition-all"
        >
          Place a Bid →
        </button>
      ) : (
        <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#0D0D0D] space-y-4">
          <h2 className="font-jakarta text-xl font-extrabold text-ink">Place Your Bid</h2>

          {error && (
            <div className="border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
              {error}
            </div>
          )}

          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Your Bid Amount (₹)</label>
            <input
              type="number"
              value={bidAmount}
              onChange={(e) => setBidAmount(e.target.value)}
              placeholder="1000"
              className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-base text-ink outline-none focus:shadow-[3px_3px_0_#C8FF00]"
            />
          </div>

          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Message to Brand (optional)</label>
            <textarea
              value={bidMessage}
              onChange={(e) => setBidMessage(e.target.value)}
              placeholder="Why should the brand pick you?"
              rows={3}
              className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#C8FF00]"
            />
          </div>

          <div className="flex gap-3">
            <button
              onClick={handlePlaceBid}
              disabled={submitting}
              className="flex-1 border-2 border-ink bg-neon px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink shadow-[3px_3px_0_#0D0D0D] disabled:opacity-70"
            >
              {submitting ? 'Submitting...' : 'Submit Bid →'}
            </button>
            <button
              onClick={() => setShowBidForm(false)}
              className="border-2 border-ink bg-white px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink"
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
