'use client'

import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { ContentSubmitForm } from '@/components/collab/content-submit-form'

export default function SubmitContentPage() {
  const { id } = useParams<{ id: string }>()
  const router = useRouter()

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <Link href={`/dashboard/creator/collabs/${id}`} className="inline-flex items-center gap-2 border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[3px_3px_0_#C8FF00] transition-all">
        ← Back to Collab
      </Link>
      <h1 className="font-jakarta text-2xl font-extrabold text-ink">Submit Content</h1>
      <ContentSubmitForm collabId={id} onSubmitted={() => router.push(`/dashboard/creator/collabs/${id}`)} />
    </div>
  )
}
