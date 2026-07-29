'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi } from '@/lib/api/brand'
import { collabApi } from '@/lib/api/collab'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { MilestoneView } from '@/components/collab/milestone-view'

export default function BrandMilestonesPage() {
  const { id } = useParams<{ id: string }>()
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['collab', id],
    queryFn: () => collabApi.getCollab(id),
  })

  const milestoneMutation = useMutation({
    mutationFn: (milestone: string) => brandApi.updateCollabMilestone(id, milestone),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['collab', id] }),
  })

  if (isLoading) return <div className="max-w-3xl mx-auto"><div className="border-2 border-ink bg-white p-8 animate-pulse" /></div>
  if (!data?.collab) return <div className="max-w-3xl mx-auto"><div className="border-2 border-ink bg-white p-8 text-center"><p className="font-nunito text-muted">Collab not found.</p></div></div>

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <Link href={`/dashboard/brand/collabs/${id}`} className="inline-flex items-center gap-2 border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[3px_3px_0_#FF2D78] transition-all">
        ← Back to Collab
      </Link>
      <h1 className="font-jakarta text-2xl font-extrabold text-ink">Milestones</h1>
      <MilestoneView collab={data.collab} collabId={id} role="brand" accentColor="#FF2D78" onMarkMilestone={(m) => milestoneMutation.mutate(m)} isMarking={milestoneMutation.isPending} />
    </div>
  )
}
