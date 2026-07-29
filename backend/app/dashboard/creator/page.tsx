'use client'

import Image from 'next/image'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { creatorApi, type Collab, type Campaign, type CollabRequest } from '@/lib/api/creator'
import Link from 'next/link'
import { useFrontendSession } from '@/hooks/useFrontendSession'
import { useMemo, useState } from 'react'
import RequestInfoModal from '@/components/dashboard/request-info-modal'

const milestoneSteps = ['brief_shared', 'draft_submitted', 'draft_approved', 'content_posted']

function getMilestoneProgress(milestoneStatus: string | null): number {
  if (!milestoneStatus) return 0
  const idx = milestoneSteps.indexOf(milestoneStatus)
  return idx >= 0 ? ((idx + 1) / milestoneSteps.length) * 100 : 0
}

function StatCard({ label, value, icon, href }: { label: string; value: string | number; icon: string; href?: string }) {
  const content = (
    <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#C8FF00] hover:shadow-[6px_6px_0_#C8FF00] hover:-translate-y-0.5 transition-all h-full">
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
            <div className={`h-full transition-all ${done ? 'bg-neon' : 'bg-white'}`} style={{ width: done ? '100%' : '0%' }} />
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

export default function CreatorHomePage() {
  const queryClient = useQueryClient()
  const { session } = useFrontendSession()
  const greeting = useMemo(() => getGreeting(), [])
  const [infoRequest, setInfoRequest] = useState<CollabRequest | null>(null)

  const { data: profile } = useQuery({
    queryKey: ['creator', 'profile'],
    queryFn: () => creatorApi.getProfile(),
  })

  const { data: earnings } = useQuery({
    queryKey: ['creator', 'earnings'],
    queryFn: () => creatorApi.getEarnings(),
  })

  const { data: collabsData } = useQuery({
    queryKey: ['creator', 'collabs'],
    queryFn: () => creatorApi.getCollabs(),
  })

  const { data: campaignsData } = useQuery({
    queryKey: ['creator', 'campaigns', 'dashboard'],
    queryFn: () => creatorApi.getCampaigns({ limit: '8', page: '1' }),
  })

  const { data: requestsData } = useQuery({
    queryKey: ['creator', 'requests'],
    queryFn: () => creatorApi.getRequests(),
  })

  const { data: walletData } = useQuery({
    queryKey: ['creator', 'wallet'],
    queryFn: () => creatorApi.getWallet(),
  })

  const { data: bidsData } = useQuery({
    queryKey: ['creator', 'bids'],
    queryFn: () => creatorApi.getBids(),
  })

  const { data: agencyData } = useQuery({
    queryKey: ['creator', 'agency'],
    queryFn: () => creatorApi.getAgency(),
  })

  const acceptMutation = useMutation({
    mutationFn: (id: string) => creatorApi.respondToRequest(id, 'accept'),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['creator', 'requests'] }),
  })

  const declineMutation = useMutation({
    mutationFn: (id: string) => creatorApi.respondToRequest(id, 'decline'),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['creator', 'requests'] }),
  })

  const profileData = profile?.profile
  const collabs = collabsData?.collabs || []
  const activeCollabs = collabs.filter((c: Collab) => c.status === 'in_progress')
  const completedCollabs = collabs.filter((c: Collab) => c.status === 'completed')
  const campaigns = campaignsData?.campaigns?.slice(0, 4) || []
  const requests = requestsData?.requests || []
  const pendingRequests = requests.filter((r: CollabRequest) => r.status === 'pending')
  const bids = bidsData?.bids || []
  const agency = agencyData?.agency

  const bidCampaignIds = new Set(bids.map((b: { campaign_id: string }) => b.campaign_id))

  return (
    <div className="max-w-6xl mx-auto space-y-6">

      {/* Welcome Header */}
      <div className="border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#C8FF00]">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="font-jakarta text-3xl font-extrabold text-ink sm:text-4xl">
              {greeting}, {session?.firstName || 'Creator'} 👋
            </h1>
            <p className="mt-1 font-nunito text-base text-muted">
              Here&apos;s your creator dashboard overview.
            </p>
          </div>
          <div className="flex items-center gap-3">
            {profileData?.tier && (
              <span className="hidden sm:inline rounded-full border-2 border-ink bg-neon px-3 py-1 font-space text-[10px] font-bold uppercase text-ink">
                {profileData.tier}
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Instagram Connect Banner */}
      {profileData && !profileData.instagram_verified && (
        <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#0D0D0D] flex items-center justify-between flex-wrap gap-3">
          <div className="flex items-center gap-3">
            <span className="text-2xl">📷</span>
            <div>
              <p className="font-nunito text-sm font-bold text-ink">Connect your Instagram</p>
              <p className="font-nunito text-xs text-muted">Get discovered by brands looking for creators like you.</p>
            </div>
          </div>
          <Link
            href="/instagram-connect"
            className="border-2 border-ink bg-pink px-5 py-2 font-space text-xs font-bold uppercase text-white shadow-[3px_3px_0_#0D0D0D] hover:shadow-[4px_4px_0_#0D0D0D] hover:-translate-y-0.5 transition-all shrink-0"
          >
            Connect
          </Link>
        </div>
      )}

      {/* Stats Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        <StatCard label="Total Earned" value={earnings ? `₹${(earnings.totalEarned / 100).toLocaleString()}` : '₹0'} icon="💰" href="/dashboard/creator/earnings" />
        <StatCard label="Active Collabs" value={activeCollabs.length} icon="🔄" href="/dashboard/creator/collabs" />
        <StatCard label="Completed" value={earnings?.collabsCompleted || 0} icon="✅" href="/dashboard/creator/collabs" />
        <StatCard label="Avg Rating" value={earnings?.avgRating ? `${earnings.avgRating.toFixed(1)} ⭐` : 'N/A'} icon="📊" />
        <StatCard label="Wallet" value={walletData ? `₹${(walletData.balance / 100).toLocaleString()}` : '₹0'} icon="₿" href="/dashboard/creator/wallet" />
        <StatCard label="Requests" value={pendingRequests.length} icon="✉️" href="/dashboard/creator/requests" />
      </div>

      {/* Active Collab Status Banner */}
      {activeCollabs.length > 0 && (
        <div className="border-2 border-ink bg-ink p-5 shadow-[5px_5px_0_#C8FF00]">
          <div className="flex items-center justify-between flex-wrap gap-3">
            <div className="flex items-center gap-4">
              <span className="text-2xl">🎯</span>
              <div>
                <p className="font-nunito text-sm font-bold text-neon">
                  {activeCollabs[0].brand_name}
                </p>
                <p className="font-nunito text-xs text-neon/70">
                  {activeCollabs[0].campaign_title || 'Direct Collaboration'} — {activeCollabs[0].collab_type}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <span className="rounded-full border-2 border-neon bg-ink px-3 py-0.5 font-space text-[10px] font-bold uppercase text-neon">
                {activeCollabs[0].milestone_status?.replace(/_/g, ' ') || 'Just Started'}
              </span>
              <Link
                href={`/dashboard/creator/collabs/${activeCollabs[0].id}`}
                className="border-2 border-neon bg-neon px-4 py-1.5 font-space text-[10px] font-bold uppercase text-ink hover:shadow-[3px_3px_0_#0D0D0D] transition-all"
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
        {/* Active Collabs */}
        <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#C8FF00]">
          <div className="border-b-2 border-ink px-5 py-3 flex items-center justify-between">
            <h2 className="font-jakarta text-base font-bold text-ink">
              Active Collabs {activeCollabs.length > 2 && `(${activeCollabs.length})`}
            </h2>
            <Link href="/dashboard/creator/collabs" className="font-space text-[9px] font-bold uppercase text-pink hover:underline">
              View All
            </Link>
          </div>
          <div className="p-4 space-y-3">
            {activeCollabs.length === 0 ? (
              <div className="text-center py-6">
                <p className="font-nunito text-sm text-muted">No active collabs yet.</p>
                <Link href="/dashboard/creator/campaigns" className="mt-2 inline-block font-space text-xs font-bold text-pink underline">
                  Browse campaigns to get started
                </Link>
              </div>
            ) : (
              activeCollabs.slice(0, 2).map((c: Collab) => (
                <Link key={c.id} href={`/dashboard/creator/collabs/${c.id}`} className="block border-2 border-ink bg-white px-4 py-3 hover:shadow-[3px_3px_0_#C8FF00] transition-all">
                  <div className="flex items-center justify-between">
                    <p className="font-nunito text-sm font-semibold text-ink">{c.brand_name}</p>
                    <span className="rounded-full bg-neon px-2 py-0.5 font-space text-[9px] font-bold uppercase text-ink">{c.collab_type}</span>
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

        {/* Brand Requests */}
        <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#FF2D78]">
          <div className="border-b-2 border-ink px-5 py-3 flex items-center justify-between">
            <h2 className="font-jakarta text-base font-bold text-ink">
              Brand Requests {pendingRequests.length > 0 && `(${pendingRequests.length})`}
            </h2>
            <Link href="/dashboard/creator/requests" className="font-space text-[9px] font-bold uppercase text-pink hover:underline">
              View All
            </Link>
          </div>
          <div className="p-4 space-y-3">
            {pendingRequests.length === 0 ? (
              <div className="text-center py-6">
                <p className="font-nunito text-sm text-muted">No pending requests.</p>
              </div>
            ) : (
              pendingRequests.slice(0, 2).map((r: CollabRequest) => (
                <div key={r.id} className="border-2 border-ink bg-white px-4 py-3">
                  <div className="flex items-center gap-2 mb-2">
                    <div className="relative w-8 h-8 rounded-full border-2 border-ink bg-ink flex items-center justify-center font-jakarta text-xs font-bold text-neon shrink-0 overflow-hidden">
                      {r.brand_logo ? (
                        <Image src={r.brand_logo} alt="" fill className="object-cover" />
                      ) : (
                        r.brand_name?.[0] || '?'
                      )}
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="font-nunito text-sm font-semibold text-ink truncate">{r.brand_name}</p>
                      <span className="rounded-full border-2 border-ink bg-amber-100 px-2 py-0.5 font-space text-[9px] font-bold uppercase text-amber-800">
                        {r.collab_type}
                      </span>
                    </div>
                  </div>
                  {r.message && (
                    <p className="font-nunito text-xs text-muted mb-1.5 line-clamp-2">{r.message}</p>
                  )}
                  {r.deliverables && r.deliverables.length > 0 && (
                    <div className="flex flex-wrap gap-1 mb-1.5">
                      {r.deliverables.slice(0, 3).map((d: string) => (
                        <span key={d} className="border border-ink bg-white px-1.5 py-0.5 font-space text-[8px] font-bold text-ink">{d}</span>
                      ))}
                    </div>
                  )}
                  {r.budget !== null && r.budget > 0 && (
                    <p className="font-jakarta text-xs font-bold text-ink mb-1">₹{(r.budget / 100).toLocaleString()}</p>
                  )}
                  <div className="flex gap-2 mt-2">
                    <button
                      onClick={() => acceptMutation.mutate(r.id)}
                      disabled={acceptMutation.isPending}
                      className="flex-1 border-2 border-ink bg-neon px-3 py-1.5 font-space text-[10px] font-bold uppercase text-ink disabled:opacity-50"
                    >
                      Accept
                    </button>
                    <button
                      onClick={() => declineMutation.mutate(r.id)}
                      disabled={declineMutation.isPending}
                      className="flex-1 border-2 border-ink bg-white px-3 py-1.5 font-space text-[10px] font-bold uppercase text-muted disabled:opacity-50 hover:bg-red-50 transition-colors"
                    >
                      Decline
                    </button>
                    <button
                      onClick={() => setInfoRequest(r)}
                      className="border-2 border-ink bg-ink px-3 py-1.5 font-space text-[10px] font-bold uppercase text-neon"
                    >
                      Info
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Agency Section */}
      {agency && (
        <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#9B5DE5]">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <span className="text-2xl">🏢</span>
              <div>
                <p className="font-nunito text-sm font-bold text-ink">{agency.agency_name}</p>
                <p className="font-space text-[9px] font-bold uppercase text-muted">Your Agency</p>
              </div>
            </div>
            <span className="rounded-full border-2 border-ink bg-purple/20 px-3 py-0.5 font-space text-[10px] font-bold uppercase text-purple">
              {agency.status}
            </span>
          </div>
        </div>
      )}

      {/* New Campaigns */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-jakarta text-base font-bold text-ink">New Campaigns</h2>
          <Link href="/dashboard/creator/campaigns" className="font-space text-[9px] font-bold uppercase text-pink hover:underline">
            View All
          </Link>
        </div>
        <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-hide -mx-1 px-1">
          {campaigns.length === 0 ? (
            <p className="font-nunito text-sm text-muted py-4">No campaigns available right now.</p>
          ) : (
            campaigns.map((c: Campaign) => {
              const alreadyBid = bidCampaignIds.has(c.id)
              return (
                <Link
                  key={c.id}
                  href={`/dashboard/creator/campaigns/${c.id}`}
                  className="shrink-0 w-64 border-2 border-ink bg-white p-4 shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#C8FF00] hover:-translate-y-0.5 transition-all"
                >
                  <div className="flex items-center gap-2 mb-2">
                    <div className="w-8 h-8 rounded-full bg-ink flex items-center justify-center font-jakarta text-xs font-bold text-neon shrink-0">
                      {c.brand_name?.[0] || '?'}
                    </div>
                    <div className="min-w-0">
                      <p className="font-nunito text-sm font-bold text-ink truncate">{c.title}</p>
                      <p className="font-nunito text-[10px] text-muted">{c.brand_name}</p>
                    </div>
                  </div>
                  <div className="flex flex-wrap gap-1 mb-2">
                    {c.niche.slice(0, 2).map((n: string) => (
                      <span key={n} className="border border-ink bg-ink/5 px-1.5 py-0.5 font-space text-[8px] font-bold text-ink">{n}</span>
                    ))}
                  </div>
                  {c.budget_min !== null && (
                    <p className="font-jakarta text-xs font-bold text-ink mb-1">
                      ₹{(c.budget_min / 100).toLocaleString()}{c.budget_max ? ` - ₹${(c.budget_max / 100).toLocaleString()}` : ''}
                    </p>
                  )}
                  <div className="flex items-center justify-between mt-2 pt-2 border-t-2 border-ink/20">
                    <span className="rounded-full border border-ink bg-white px-2 py-0.5 font-space text-[8px] font-bold uppercase text-muted">
                      {c.collab_type}
                    </span>
                    {alreadyBid ? (
                      <span className="font-space text-[8px] font-bold uppercase text-green-600">Bid Placed ✓</span>
                    ) : (
                      <span className="font-space text-[8px] font-bold uppercase text-pink">Bid Now</span>
                    )}
                  </div>
                </Link>
              )
            })
          )}
        </div>
      </div>

      <RequestInfoModal request={infoRequest} onClose={() => setInfoRequest(null)} />
    </div>
  )
}
