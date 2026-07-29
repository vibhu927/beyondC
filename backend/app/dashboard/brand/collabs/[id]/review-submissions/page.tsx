'use client'

import { useParams } from 'next/navigation'
import Link from 'next/link'
import { ContentReviewForm } from '@/components/collab/content-review-form'

export default function BrandReviewSubmissionsPage() {
  const { id } = useParams<{ id: string }>()

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <Link href={`/dashboard/brand/collabs/${id}`} className="inline-flex items-center gap-2 border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[3px_3px_0_#FF2D78] transition-all">
        ← Back to Collab
      </Link>
      <h1 className="font-jakarta text-2xl font-extrabold text-ink">Review Submissions</h1>
      <ContentReviewForm collabId={id} />
    </div>
  )
}
