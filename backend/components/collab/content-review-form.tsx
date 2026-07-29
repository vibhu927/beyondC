'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { collabApi, type ContentSubmission } from '@/lib/api/collab'
import { useState } from 'react'

export function ContentReviewForm({ collabId }: { collabId: string }) {
  const queryClient = useQueryClient()
  const [feedback, setFeedback] = useState('')
  const [showReview, setShowReview] = useState<string | null>(null)

  const { data, isLoading } = useQuery({
    queryKey: ['collab-submissions', collabId],
    queryFn: () => collabApi.getSubmissions(collabId),
  })

  const reviewMutation = useMutation({
    mutationFn: ({ submissionId, status }: { submissionId: string; status: 'approved' | 'rejected' | 'revision_requested' }) =>
      collabApi.reviewContent(collabId, submissionId, status, feedback || undefined),
    onSuccess: () => {
      setFeedback('')
      setShowReview(null)
      queryClient.invalidateQueries({ queryKey: ['collab-submissions', collabId] })
    },
  })

  const submissions = data?.submissions || []

  if (isLoading) {
    return <div className="border-2 border-ink bg-white p-6 animate-pulse"><div className="h-4 bg-gray-200 rounded w-1/2" /></div>
  }

  if (submissions.length === 0) {
    return (
      <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#FF2D78] text-center">
        <p className="font-nunito text-muted text-sm">No submissions to review yet.</p>
      </div>
    )
  }

  const statusColor: Record<string, string> = {
    pending: 'bg-amber-100 text-amber-800 border-amber-300',
    approved: 'bg-green-100 text-green-800 border-green-300',
    rejected: 'bg-red-100 text-red-800 border-red-300',
    revision_requested: 'bg-blue-100 text-blue-800 border-blue-300',
  }

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#FF2D78]">
      <div className="border-b-2 border-ink bg-pink/10 px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-pink">Review Submissions</h3>
      </div>
      <div className="p-5 space-y-4">
        {submissions.map((sub: ContentSubmission) => (
          <div key={sub.id} className="border-2 border-ink bg-white">
            <div className="px-4 py-3">
              <div className="flex items-start justify-between">
                <div className="flex-1 min-w-0">
                  <a href={sub.content_url} target="_blank" rel="noopener noreferrer" className="font-jakarta text-sm font-bold text-ink underline truncate block">
                    {sub.content_type.toUpperCase()} — {sub.content_url}
                  </a>
                  {sub.caption && <p className="font-nunito text-xs text-ink/70 mt-1">{sub.caption}</p>}
                  {sub.notes && <p className="font-nunito text-[10px] text-muted mt-0.5 italic">Note: {sub.notes}</p>}
                </div>
                <span className={`ml-3 shrink-0 border px-2 py-0.5 font-space text-[9px] font-bold uppercase ${statusColor[sub.status] || ''}`}>
                  {sub.status.replace(/_/g, ' ')}
                </span>
              </div>
              <p className="font-nunito text-[10px] text-muted mt-1">Submitted {new Date(sub.created_at).toLocaleDateString()}</p>
            </div>

            {sub.status === 'pending' && showReview === sub.id && (
              <div className="border-t-2 border-ink px-4 py-3 space-y-3">
                <textarea
                  value={feedback}
                  onChange={(e) => setFeedback(e.target.value)}
                  placeholder="Feedback for the creator..."
                  rows={2}
                  className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none resize-none"
                />
                <div className="flex gap-2">
                  {(['approved', 'revision_requested', 'rejected'] as const).map((status) => (
                    <button
                      key={status}
                      onClick={() => reviewMutation.mutate({ submissionId: sub.id, status })}
                      disabled={reviewMutation.isPending}
                      className={`flex-1 border-2 border-ink px-3 py-2 font-space text-[10px] font-bold uppercase disabled:opacity-50 ${
                        status === 'approved' ? 'bg-green-500 text-white' : status === 'rejected' ? 'bg-red-500 text-white' : 'bg-blue-500 text-white'
                      }`}
                    >
                      {status.replace(/_/g, ' ')}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {sub.status === 'pending' && showReview !== sub.id && (
              <div className="border-t-2 border-ink px-4 py-2">
                <button onClick={() => setShowReview(sub.id)} className="border-2 border-ink bg-pink px-4 py-1.5 font-space text-[10px] font-bold uppercase text-white">
                  Review
                </button>
              </div>
            )}

            {sub.brand_feedback && (
              <div className="border-t-2 border-ink/30 bg-ink/5 px-4 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Your Feedback</p>
                <p className="font-nunito text-xs text-ink/80">{sub.brand_feedback}</p>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
