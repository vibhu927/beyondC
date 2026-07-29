'use client'

import { useQuery } from '@tanstack/react-query'
import { collabApi, type ContentSubmission } from '@/lib/api/collab'

export function ContentSubmissions({ collabId, role }: { collabId: string; role: 'creator' | 'brand' }) {
  const { data, isLoading } = useQuery({
    queryKey: ['collab-submissions', collabId],
    queryFn: () => collabApi.getSubmissions(collabId),
  })

  const submissions = data?.submissions || []

  if (isLoading) {
    return <div className="border-2 border-ink bg-white p-6 animate-pulse"><div className="h-4 bg-gray-200 rounded w-1/2" /></div>
  }

  if (submissions.length === 0) {
    return (
      <div className="border-2 border-ink bg-white p-6 shadow-[3px_3px_0_#0D0D0D] text-center">
        <p className="font-nunito text-muted text-sm">No content submissions yet.</p>
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
    <div className="space-y-3">
      {submissions.map((sub: ContentSubmission) => (
        <div key={sub.id} className="border-2 border-ink bg-white px-4 py-3">
          <div className="flex items-start justify-between">
            <div className="flex-1 min-w-0">
              <a href={sub.content_url} target="_blank" rel="noopener noreferrer" className="font-jakarta text-sm font-bold text-ink underline truncate block">
                {sub.content_type.toUpperCase()} — {sub.content_url}
              </a>
              {sub.caption && <p className="font-nunito text-xs text-ink/70 mt-1">{sub.caption}</p>}
              {sub.notes && <p className="font-nunito text-[10px] text-muted mt-0.5 italic">Note: {sub.notes}</p>}
            </div>
            <span className={`ml-3 shrink-0 border px-2 py-0.5 font-space text-[9px] font-bold uppercase ${statusColor[sub.status] || 'bg-gray-100 text-gray-700 border-gray-300'}`}>
              {sub.status.replace(/_/g, ' ')}
            </span>
          </div>
          {sub.brand_feedback && (
            <div className="mt-2 border-2 border-ink/30 bg-ink/5 px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase text-muted">Brand Feedback</p>
              <p className="font-nunito text-xs text-ink/80">{sub.brand_feedback}</p>
            </div>
          )}
          <p className="font-nunito text-[10px] text-muted mt-1">{new Date(sub.created_at).toLocaleDateString()}</p>
        </div>
      ))}
    </div>
  )
}
