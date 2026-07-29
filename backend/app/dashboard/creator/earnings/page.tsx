'use client'

import { useQuery } from '@tanstack/react-query'
import { creatorApi } from '@/lib/api/creator'

export default function EarningsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'earnings'],
    queryFn: () => creatorApi.getEarnings(),
  })

  if (isLoading) {
    return (
      <div className="max-w-3xl mx-auto">
        <div className="border-2 border-ink bg-white p-8 animate-pulse space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="h-20 bg-gray-100 rounded" />
            <div className="h-20 bg-gray-100 rounded" />
          </div>
          <div className="h-20 bg-gray-100 rounded" />
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Earnings</h1>
        <p className="mt-1 font-nunito text-base text-muted">Your creator performance at a glance.</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="border-2 border-ink bg-ink p-5 shadow-[4px_4px_0_#C8FF00]">
          <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-neon/70">Total Earned</p>
          <p className="font-jakarta text-3xl font-extrabold text-neon mt-1">
            ₹{((data?.totalEarned || 0) / 100).toLocaleString()}
          </p>
        </div>
        <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#0D0D0D]">
          <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Collabs Completed</p>
          <p className="font-jakarta text-3xl font-extrabold text-ink mt-1">{data?.collabsCompleted || 0}</p>
        </div>
        <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#0D0D0D]">
          <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Avg Rating</p>
          <p className="font-jakarta text-3xl font-extrabold text-ink mt-1">
            {data?.avgRating ? `${data.avgRating.toFixed(1)}` : 'N/A'}
          </p>
          {data?.totalRatings ? (
            <p className="font-nunito text-xs text-muted mt-1">{data.totalRatings} ratings</p>
          ) : null}
        </div>
      </div>

      <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#C8FF00]">
        <h2 className="font-jakarta text-lg font-bold text-ink mb-4">Recent Collabs</h2>
        {!data?.recentCollabs?.length ? (
          <p className="font-nunito text-sm text-muted">No completed collabs yet.</p>
        ) : (
          <div className="space-y-3">
            {data.recentCollabs.map((collab) => (
              <div key={collab.id} className="border-2 border-ink bg-white px-4 py-3 flex items-center justify-between">
                <div>
                  <p className="font-nunito text-sm font-semibold text-ink">{collab.brand_name}</p>
                  <p className="font-nunito text-xs text-muted capitalize">{collab.collab_type}</p>
                </div>
                {collab.rating && (
                  <span className="font-jakarta text-sm font-bold text-ink">⭐ {collab.rating}</span>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
