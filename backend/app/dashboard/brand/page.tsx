'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type BrandCampaign, type BrandCollab } from '@/lib/api/brand'
import Link from 'next/link'
import { useFrontendSession } from '@/hooks/useFrontendSession'
import { useMemo, useState } from 'react'

const milestoneSteps = ['brief_shared', 'draft_submitted', 'draft_approved', 'content_posted']

function getMilestoneProgress(milestoneStatus: string | null): number {
  if (!milestoneStatus) return 0
  const idx = milestoneSteps.indexOf(milestoneStatus)
  return idx >= 0 ? ((idx + 1) / milestoneSteps.length) * 100 : 0
}

function StatCard({ label, value, icon, href }: { label: string; value: string | number; icon: string; href?: string }) {
  const content = (
    <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#FF2D78] hover:shadow-[6px_6px_0_#FF2D78] hover:-translate-y-0.5 transition-all h-full">
      <div className="flex items-start justify-between h-full">
        <div>
          <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">{label}</p>
          <p className="mt-1 font-jakarta text-2xl font-extrabold text-ink">{value}</p>
        </div>
        <span className="text-2xl shrink-0">{icon}</span>
      </div>
    </div>
  )
  if (href) return <Link href={href} className="block h-full">{content}</Link>
  return <div className="h-full">{content}</div>
}

function MilestoneRail({ status }: { status: string | null }) {
  const pct = getMilestoneProgress(status)
  return (
    <div className="flex items-center gap-1.5 mt-2">
      {milestoneSteps.map((s, i) => {
        const done = i <= milestoneSteps.indexOf(status || '')
        return (
          <div key={s} className="flex-1 h-2 border-2 border-ink">
            <div className={`h-full transition-all ${done ? 'bg-pink' : 'bg-white'}`} style={{ width: done ? '100%' : '0%' }} />
          </div>
        )
      })}
      <span className="font-space text-[9px] font-bold text-muted ml-1 shrink-0">{Math.round(pct)}%</span>
    </div>
  )
}

function getGreeting() {
  const h = new Date().getHours()
  if (h < 12) return 'Good morning'
  if (h < 17) return 'Good afternoon'
  return 'Good evening'
}

type RequestItem = {
  id: string
  creator_id: string
  creator_first_name: string
  creator_tier: string | null
  budget: number | null
  collab_type: string
  status: string
  message: string | null
  campaign_title: string | null
  created_at: string
}

export default function BrandHomePage() {
  const queryClient = useQueryClient()
  const { session } = useFrontendSession()
  const greeting = useMemo(() => getGreeting(), [])

  const { data: profile } = useQuery({
    queryKey: ['brand', 'profile'],
    queryFn: () => brandApi.getProfile(),
  })

  const { data: analytics } = useQuery({
    queryKey: ['brand', 'analytics'],
    queryFn: () => brandApi.getAnalytics(),
  })

  const { data: campaignsData } = useQuery({
    queryKey: ['brand', 'campaigns'],
    queryFn: () => brandApi.getCampaigns(),
  })

  const { data: collabsData } = useQuery({
    queryKey: ['brand', 'collabs'],
    queryFn: () => brandApi.getCollabs(),
  })

  const { data: credits } = useQuery({
    queryKey: ['brand', 'credits'],
    queryFn: () => brandApi.getCredits(),
  })

  const { data: requestsData } = useQuery({
    queryKey: ['brand', 'requests'],
    queryFn: () => brandApi.getRequests(),
  })

  const profileData = profile?.profile
  const analyticsData = analytics
  const campaigns = campaignsData?.campaigns || []
  const allCollabs = collabsData?.collabs || []
  const activeCollabs = allCollabs.filter((c: BrandCollab) => c.status === 'in_progress')
  const requests = requestsData?.requests as RequestItem[] | undefined
  const pendingRequests = (requests || []).filter((r) => r.status === 'pending')

  const cancelMutation = useMutation({
    mutationFn: (id: string) => brandApi.withdrawRequest(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brand', 'requests'] })
    },
  })

  return (
    <div className="max-w-6xl mx-auto space-y-6">

      {/* Welcome Header */}
      <div className="border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#FF2D78]">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="font-jakarta text-3xl font-extrabold text-ink sm:text-4xl">
              {greeting}, {profileData?.brand_name || session?.firstName || 'Brand'} 👋
            </h1>
            <p className="mt-1 font-nunito text-base text-muted">
              Here&apos;s your brand dashboard overview.
            </p>
          </div>
          <div className="flex items-center gap-3">
            {profileData?.is_brand_verified && (
              <span className="hidden sm:inline rounded-full border-2 border-ink bg-pink px-3 py-1 font-space text-[10px] font-bold uppercase text-white">
                Verified ✓
              </span>
            )}
            <Link
              href="/dashboard/brand/campaigns/create"
              className="border-2 border-ink bg-pink px-4 py-2 font-space text-xs font-bold uppercase text-white hover:shadow-[4px_4px_0_#0D0D0D] transition-all"
            >
              + New Campaign
            </Link>
          </div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        <StatCard label="Credits" value={credits ? `${credits.balance}` : '0'} icon="₿" href="/dashboard/brand/credits" />
        <StatCard label="Active Campaigns" value={analyticsData?.campaignStats.active || 0} icon="📢" href="/dashboard/brand/campaigns" />
        <StatCard label="Active Collabs" value={activeCollabs.length} icon="🔄" href="/dashboard/brand/collabs" />
        <StatCard label="Avg Rating" value={profileData?.avg_rating ? `${profileData.avg_rating.toFixed(1)} ⭐` : 'N/A'} icon="📊" />
        <StatCard label="Total Spent" value={analyticsData ? `₹${(analyticsData.campaignStats.totalSpent / 100).toLocaleString()}` : '₹0'} icon="💰" />
        <StatCard label="Submissions" value={analyticsData?.submissionStats.pending || 0} icon="📝" href="/dashboard/brand/collabs" />
      </div>

      {/* Active Collab Status Banner */}
      {activeCollabs.length > 0 && (
        <div className="border-2 border-ink bg-ink p-5 shadow-[5px_5px_0_#FF2D78]">
          <div className="flex items-center justify-between flex-wrap gap-3">
            <div className="flex items-center gap-4">
              <span className="text-2xl">🎯</span>
              <div>
                <p className="font-nunito text-sm font-bold text-pink">
                  {activeCollabs[0].creator_name}
                </p>
                <p className="font-nunito text-xs text-pink/70">
                  {activeCollabs[0].campaign_title || 'Direct Collaboration'} — {activeCollabs[0].collab_type}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <span className="rounded-full border-2 border-pink bg-ink px-3 py-0.5 font-space text-[10px] font-bold uppercase text-pink">
                {activeCollabs[0].milestone_status?.replace(/_/g, ' ') || 'Just Started'}
              </span>
              <Link
                href={`/dashboard/brand/collabs/${activeCollabs[0].id}`}
                className="border-2 border-pink bg-pink px-4 py-1.5 font-space text-[10px] font-bold uppercase text-white hover:shadow-[3px_3px_0_#0D0D0D] transition-all"
              >
                View
              </Link>
            </div>
          </div>
          <div className="mt-3">
            <MilestoneRail status={activeCollabs[0].milestone_status} />
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Active Campaigns */}
        <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#FF2D78]">
          <div className="border-b-2 border-ink px-5 py-3 flex items-center justify-between">
            <h2 className="font-jakarta text-base font-bold text-ink">
              Active Campaigns {campaigns.length > 2 && `(${campaigns.length})`}
            </h2>
            <Link href="/dashboard/brand/campaigns" className="font-space text-[9px] font-bold uppercase text-pink hover:underline">
              View All
            </Link>
          </div>
          <div className="p-4 space-y-3">
            {campaigns.length === 0 ? (
              <div className="text-center py-6">
                <p className="font-nunito text-sm text-muted">No active campaigns yet.</p>
                <Link href="/dashboard/brand/campaigns/create" className="mt-2 inline-block font-space text-xs font-bold text-pink underline">
                  Create your first campaign
                </Link>
              </div>
            ) : (
              campaigns.slice(0, 3).map((c: BrandCampaign) => (
                <Link key={c.id} href={`/dashboard/brand/campaigns/${c.id}`} className="block border-2 border-ink bg-white px-4 py-3 hover:shadow-[3px_3px_0_#FF2D78] transition-all">
                  <div className="flex items-center justify-between">
                    <p className="font-nunito text-sm font-semibold text-ink truncate mr-2">{c.title}</p>
                    <span className={`rounded-full px-2 py-0.5 font-space text-[9px] font-bold uppercase shrink-0 ${
                      c.status === 'active' ? 'bg-neon text-ink' : c.status === 'paused' ? 'bg-yellow-100 text-ink border border-ink' : c.status === 'completed' ? 'bg-blue-100 text-ink' : 'bg-gray-200 text-muted'
                    }`}>
                      {c.status}
                    </span>
                  </div>
                  <div className="flex flex-wrap gap-1 mt-1.5">
                    {c.niche.slice(0, 2).map((n) => (
                      <span key={n} className="border border-ink bg-ink/5 px-1.5 py-0.5 font-space text-[8px] font-bold text-ink">{n}</span>
                    ))}
                    {c.niche.length > 2 && <span className="font-space text-[8px] text-muted">+{c.niche.length - 2}</span>}
                  </div>
                  <div className="flex items-center justify-between mt-2">
                    {c.budget_min !== null && (
                      <p className="font-jakarta text-xs font-bold text-ink">
                        ₹{(c.budget_min / 100).toLocaleString()}{c.budget_max ? ` - ₹${(c.budget_max / 100).toLocaleString()}` : ''}
                      </p>
                    )}
                    <div className="flex items-center gap-2">
                      <span className="font-space text-[9px] text-muted">{c.bid_count} bids</span>
                      <span className="font-space text-[9px] text-muted">{c.slots_filled}/{c.slots} filled</span>
                    </div>
                  </div>
                </Link>
              ))
            )}
          </div>
        </div>

        {/* Active Collabs */}
        <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#FF2D78]">
          <div className="border-b-2 border-ink px-5 py-3 flex items-center justify-between">
            <h2 className="font-jakarta text-base font-bold text-ink">
              Active Collabs {activeCollabs.length > 2 && `(${activeCollabs.length})`}
            </h2>
            <Link href="/dashboard/brand/collabs" className="font-space text-[9px] font-bold uppercase text-pink hover:underline">
              View All
            </Link>
          </div>
          <div className="p-4 space-y-3">
            {activeCollabs.length === 0 ? (
              <div className="text-center py-6">
                <p className="font-nunito text-sm text-muted">No active collabs yet.</p>
                <Link href="/dashboard/brand/discover" className="mt-2 inline-block font-space text-xs font-bold text-pink underline">
                  Discover creators to collaborate with
                </Link>
              </div>
            ) : (
              activeCollabs.slice(0, 2).map((c: BrandCollab) => (
                <Link key={c.id} href={`/dashboard/brand/collabs/${c.id}`} className="block border-2 border-ink bg-white px-4 py-3 hover:shadow-[3px_3px_0_#FF2D78] transition-all">
                  <div className="flex items-center justify-between">
                    <p className="font-nunito text-sm font-semibold text-ink">{c.creator_name}</p>
                    <span className="rounded-full bg-pink/20 px-2 py-0.5 font-space text-[9px] font-bold uppercase text-pink">{c.collab_type}</span>
                  </div>
                  {c.campaign_title && <p className="font-nunito text-xs text-muted mt-0.5">{c.campaign_title}</p>}
                  <MilestoneRail status={c.milestone_status} />
                  {c.agreed_amount !== null && (
                    <p className="font-jakarta text-xs font-bold text-ink mt-1">₹{(c.agreed_amount / 100).toLocaleString()}</p>
                  )}
                </Link>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Pending Requests + Content Submissions — Side by Side */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Pending Requests */}
        {pendingRequests.length > 0 && (
          <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#FF2D78]">
            <div className="border-b-2 border-ink px-5 py-3 flex items-center justify-between">
              <h2 className="font-jakarta text-base font-bold text-ink">
                Pending Requests ({pendingRequests.length})
              </h2>
              <Link href="/dashboard/brand/requests" className="font-space text-[9px] font-bold uppercase text-pink hover:underline">
                View All
              </Link>
            </div>
            <div className="p-4 space-y-3">
              {pendingRequests.slice(0, 2).map((r: RequestItem) => (
                <div key={r.id} className="border-2 border-ink bg-white p-4 hover:shadow-[3px_3px_0_#FF2D78] transition-all">
                  <div className="flex items-start gap-2.5">
                    <div className="w-10 h-10 rounded-full border-2 border-ink bg-pink flex items-center justify-center font-jakarta text-sm font-bold text-white shrink-0">
                      {r.creator_first_name?.[0]?.toUpperCase() || 'C'}
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <p className="font-nunito text-sm font-semibold text-ink">{r.creator_first_name || 'Creator'}</p>
                        {r.creator_tier && (
                          <span className="rounded-full border border-ink bg-neon/40 px-1.5 py-0.5 font-space text-[7px] font-bold uppercase text-ink">
                            {r.creator_tier}
                          </span>
                        )}
                        <span className="rounded-full border border-ink bg-pink/10 px-1.5 py-0.5 font-space text-[7px] font-bold uppercase text-pink">
                          {r.collab_type}
                        </span>
                      </div>
                      {r.campaign_title && (
                        <p className="font-nunito text-[11px] text-muted mt-0.5">
                          <span className="font-semibold text-ink">Campaign:</span> {r.campaign_title}
                        </p>
                      )}
                      {r.budget !== null && r.budget > 0 && (
                        <p className="font-jakarta text-xs font-bold text-ink mt-0.5">₹{(r.budget / 100).toLocaleString()}</p>
                      )}
                      {r.message && (
                        <p className="font-nunito text-[10px] text-muted mt-1 line-clamp-2 bg-ink/5 p-1.5 border border-ink/10">
                          &ldquo;{r.message}&rdquo;
                        </p>
                      )}
                    </div>
                  </div>
                  <div className="mt-2 pt-2 border-t-2 border-ink/10 flex items-center justify-between">
                    <span className="font-nunito text-[9px] text-muted">
                      Sent {new Date(r.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })}
                    </span>
                    <button
                      onClick={() => cancelMutation.mutate(r.id)}
                      disabled={cancelMutation.isPending}
                      className="border-2 border-ink bg-white px-3 py-1 font-space text-[9px] font-bold uppercase text-muted hover:bg-red-50 hover:text-red-600 transition-all disabled:opacity-50"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Content Submissions */}
        {analyticsData && (
          <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#FF2D78]">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-jakarta text-base font-bold text-ink">Content Submissions</h2>
              <Link href="/dashboard/brand/collabs" className="font-space text-[9px] font-bold uppercase text-pink hover:underline">
                Review
              </Link>
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div className="border-2 border-ink bg-amber-50 p-4 text-center">
                <p className="font-jakarta text-2xl font-extrabold text-amber-700">{analyticsData.submissionStats.pending}</p>
                <p className="font-space text-[9px] font-bold uppercase text-amber-600 mt-1">Pending</p>
              </div>
              <div className="border-2 border-ink bg-green-50 p-4 text-center">
                <p className="font-jakarta text-2xl font-extrabold text-green-700">{analyticsData.submissionStats.approved}</p>
                <p className="font-space text-[9px] font-bold uppercase text-green-600 mt-1">Approved</p>
              </div>
              <div className="border-2 border-ink bg-red-50 p-4 text-center">
                <p className="font-jakarta text-2xl font-extrabold text-red-700">{analyticsData.submissionStats.rejected}</p>
                <p className="font-space text-[9px] font-bold uppercase text-red-600 mt-1">Rejected</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
