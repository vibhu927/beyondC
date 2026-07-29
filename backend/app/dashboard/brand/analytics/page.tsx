'use client'

import { useQuery } from '@tanstack/react-query'
import { brandApi } from '@/lib/api/brand'

export default function AnalyticsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ['brand', 'analytics'],
    queryFn: () => brandApi.getAnalytics(),
  })

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Analytics</h1>
        <p className="mt-1 font-nunito text-base text-muted">Campaign and collaboration performance.</p>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse">
              <div className="h-4 bg-gray-200 rounded w-1/2 mb-3" />
              <div className="h-8 bg-gray-200 rounded w-3/4" />
            </div>
          ))}
        </div>
      ) : !data ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="font-nunito text-muted">No analytics data available yet.</p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#FF2D78]">
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Total Campaigns</p>
              <p className="font-jakarta text-3xl font-extrabold text-ink mt-1">{data.campaignStats.total}</p>
            </div>
            <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#0D0D0D]">
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Active Campaigns</p>
              <p className="font-jakarta text-3xl font-extrabold text-ink mt-1">{data.campaignStats.active}</p>
            </div>
            <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#C8FF00]">
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Completed</p>
              <p className="font-jakarta text-3xl font-extrabold text-ink mt-1">{data.campaignStats.completed}</p>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="border-2 border-ink bg-ink p-5 shadow-[4px_4px_0_#FF2D78]">
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-neon/70">Total Spent</p>
              <p className="font-jakarta text-3xl font-extrabold text-neon mt-1">₹{(data.campaignStats.totalSpent / 100).toLocaleString()}</p>
            </div>
            <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#0D0D0D]">
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Avg Rating</p>
              <p className="font-jakarta text-3xl font-extrabold text-ink mt-1">{data.campaignStats.avgRating ? `${data.campaignStats.avgRating.toFixed(1)}` : 'N/A'}</p>
            </div>
            <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#C8FF00]">
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Total Collabs</p>
              <p className="font-jakarta text-3xl font-extrabold text-ink mt-1">{data.collabStats.total}</p>
            </div>
          </div>

          <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#FF2D78]">
            <h2 className="font-jakarta text-lg font-bold text-ink mb-4">Collab Overview</h2>
            <div className="grid grid-cols-3 gap-4">
              <div className="text-center border-2 border-ink bg-neon/20 px-4 py-3">
                <p className="font-jakarta text-2xl font-extrabold text-ink">{data.collabStats.active}</p>
                <p className="font-space text-[9px] font-bold uppercase text-muted">Active</p>
              </div>
              <div className="text-center border-2 border-ink bg-white px-4 py-3">
                <p className="font-jakarta text-2xl font-extrabold text-ink">{data.collabStats.completed}</p>
                <p className="font-space text-[9px] font-bold uppercase text-muted">Completed</p>
              </div>
              <div className="text-center border-2 border-ink bg-white px-4 py-3">
                <p className="font-jakarta text-2xl font-extrabold text-ink">{data.submissionStats.pending}</p>
                <p className="font-space text-[9px] font-bold uppercase text-muted">Pending Review</p>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
