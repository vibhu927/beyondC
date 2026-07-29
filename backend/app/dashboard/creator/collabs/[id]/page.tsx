'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { creatorApi } from '@/lib/api/creator'
import { collabApi, type ContentSubmission } from '@/lib/api/collab'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { useState } from 'react'
import { MilestoneView } from '@/components/collab/milestone-view'
import { ChatWindow } from '@/components/collab/chat'

export default function CreatorCollabDetailPage() {
  const { id } = useParams<{ id: string }>()
  const queryClient = useQueryClient()
  const [showChat, setShowChat] = useState(false)

  const milestoneMutation = useMutation({
    mutationFn: (milestone: string) => creatorApi.updateCollabMilestone(id, milestone),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['collab', id] }),
  })

  const { data, isLoading } = useQuery({
    queryKey: ['collab', id],
    queryFn: () => collabApi.getCollab(id),
  })

  const { data: submissionsData } = useQuery({
    queryKey: ['collab-submissions', id],
    queryFn: () => collabApi.getSubmissions(id),
  })

  if (isLoading) {
    return (
      <div className="max-w-3xl mx-auto">
        <div className="border-2 border-ink bg-white p-8 animate-pulse space-y-4">
          <div className="h-6 bg-gray-200 rounded w-1/2" />
          <div className="h-4 bg-gray-200 rounded w-3/4" />
          <div className="h-4 bg-gray-200 rounded w-2/3" />
        </div>
      </div>
    )
  }

  const collab = data?.collab

  if (!collab) {
    return (
      <div className="max-w-3xl mx-auto">
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="font-nunito text-muted">Collab not found.</p>
          <Link href="/dashboard/creator/collabs" className="mt-4 inline-block border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon">
            ← Back to Collabs
          </Link>
        </div>
      </div>
    )
  }

  const bothAccepted = collab.creator_contract_accepted && collab.brand_contract_accepted
  const submissions = submissionsData?.submissions || []
  const pendingSubmissions = submissions.filter((s: ContentSubmission) => s.status === 'pending')
  const latestSubmission = submissions[submissions.length - 1]

  return (
    <div className="max-w-3xl mx-auto space-y-5">
      <Link
        href="/dashboard/creator/collabs"
        className="inline-flex items-center gap-2 border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[3px_3px_0_#C8FF00] transition-all"
      >
        ← Back to Collabs
      </Link>

      <div className="border-2 border-ink bg-white shadow-[6px_6px_0_#C8FF00]">
        <div className="p-6 sm:p-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="font-jakarta text-2xl font-extrabold text-ink">{collab.brand_name}</h1>
              <p className="font-nunito text-sm text-muted mt-1">{collab.campaign_title || 'Direct Collaboration'}</p>
            </div>
            <span className={`rounded-full border-2 border-ink px-3 py-1 font-space text-[10px] font-bold uppercase ${
              collab.status === 'in_progress' ? 'bg-neon text-ink' : 'bg-blue-200 text-ink'
            }`}>
              {collab.status?.replace(/_/g, ' ')}
            </span>
          </div>

          <div className="mt-6 grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase text-muted">Amount</p>
              <p className="font-jakarta text-sm font-bold text-ink">₹{(collab.agreed_amount || 0).toLocaleString()}</p>
            </div>
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase text-muted">Type</p>
              <p className="font-jakarta text-sm font-bold text-ink capitalize">{collab.collab_type}</p>
            </div>
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase text-muted">Started</p>
              <p className="font-jakarta text-sm font-bold text-ink">{new Date(collab.created_at).toLocaleDateString()}</p>
            </div>
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase text-muted">Rating</p>
              <p className="font-jakarta text-sm font-bold text-ink">{collab.rating ? `${collab.rating} ⭐` : '—'}</p>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <Link href={`/dashboard/creator/collabs/${id}/contract`} className="border-2 border-ink bg-white px-4 py-3 font-space text-xs font-bold uppercase text-ink flex items-center justify-between hover:shadow-[3px_3px_0_#C8FF00] transition-all">
          <span>Contract</span>
          <span className={`font-nunito text-[10px] ${bothAccepted ? 'text-green-600' : collab.contract_terms ? 'text-amber-600' : 'text-muted'}`}>
            {bothAccepted ? '✓ Accepted' : collab.contract_terms ? 'Pending' : 'Not Created'}
          </span>
        </Link>
        <Link href={`/dashboard/creator/collabs/${id}/milestones`} className="border-2 border-ink bg-white px-4 py-3 font-space text-xs font-bold uppercase text-ink flex items-center justify-between hover:shadow-[3px_3px_0_#C8FF00] transition-all">
          <span>Milestones</span>
          <span className="font-nunito text-[10px] text-muted">{collab.milestone_status?.replace(/_/g, ' ') || 'Not Started'}</span>
        </Link>
        <Link href={`/dashboard/creator/collabs/${id}/submit-content`} className="border-2 border-ink bg-white px-4 py-3 font-space text-xs font-bold uppercase text-ink flex items-center justify-between hover:shadow-[3px_3px_0_#C8FF00] transition-all">
          <span>Submit Content</span>
          <span className="font-nunito text-[10px] text-muted">{submissions.length > 0 ? `${submissions.length} submitted` : ''}</span>
        </Link>
        <Link href={`/dashboard/creator/collabs/${id}/payment`} className="border-2 border-ink bg-white px-4 py-3 font-space text-xs font-bold uppercase text-ink flex items-center justify-between hover:shadow-[3px_3px_0_#C8FF00] transition-all">
          <span>Payment</span>
          <span className="font-nunito text-[10px] text-muted">{collab.payment_structure?.replace(/_/g, ' ') || 'Not Set'}</span>
        </Link>
      </div>

      <MilestoneView collab={collab} collabId={id} role="creator" onMarkMilestone={(m) => milestoneMutation.mutate(m)} isMarking={milestoneMutation.isPending} />

      {submissions.length > 0 && (
        <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#0D0D0D]">
          <div className="border-b-2 border-ink bg-ink/5 px-5 py-3">
            <h3 className="font-space text-xs font-bold uppercase text-ink">Recent Submissions</h3>
          </div>
          <div className="p-4 space-y-2">
            {submissions.slice(-3).reverse().map((sub: ContentSubmission) => (
              <div key={sub.id} className="border-2 border-ink bg-white px-4 py-2 flex items-center justify-between">
                <div className="flex-1 min-w-0">
                  <a href={sub.content_url} target="_blank" rel="noopener noreferrer" className="font-nunito text-sm font-semibold text-ink underline truncate block">
                    {sub.content_type.toUpperCase()} — {sub.content_url}
                  </a>
                  {sub.notes && <p className="font-nunito text-[10px] text-muted">{sub.notes}</p>}
                </div>
                <span className={`ml-2 shrink-0 border px-2 py-0.5 font-space text-[9px] font-bold uppercase ${
                  sub.status === 'approved' ? 'bg-green-100 text-green-800 border-green-300' :
                  sub.status === 'rejected' ? 'bg-red-100 text-red-800 border-red-300' :
                  sub.status === 'revision_requested' ? 'bg-blue-100 text-blue-800 border-blue-300' :
                  'bg-amber-100 text-amber-800 border-amber-300'
                }`}>
                  {sub.status.replace(/_/g, ' ')}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {collab.status === 'completed' && collab.rating === null && (
        <Link href={`/dashboard/creator/collabs/${id}/rate`} className="block border-2 border-ink bg-neon px-6 py-4 text-center font-space text-sm font-bold uppercase text-ink hover:shadow-[4px_4px_0_#0D0D0D] transition-all">
          Rate this Collab ⭐
        </Link>
      )}

      <button
        onClick={() => setShowChat(!showChat)}
        className="w-full border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon hover:shadow-[4px_4px_0_#C8FF00] transition-all"
      >
        {showChat ? 'Hide Chat' : 'Open Chat 💬'}
      </button>

      {showChat && <ChatWindow collabId={id} />}
    </div>
  )
}
