'use client'

import { useQuery } from '@tanstack/react-query'
import { collabApi } from '@/lib/api/collab'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { ContractView } from '@/components/collab/contract-view'
import { ContractForm } from '@/components/collab/contract-form'

export default function BrandContractPage() {
  const { id } = useParams<{ id: string }>()

  const { data, isLoading } = useQuery({
    queryKey: ['collab', id],
    queryFn: () => collabApi.getCollab(id),
  })

  if (isLoading) {
    return <div className="max-w-3xl mx-auto"><div className="border-2 border-ink bg-white p-8 animate-pulse" /></div>
  }

  if (!data?.collab) {
    return <div className="max-w-3xl mx-auto"><div className="border-2 border-ink bg-white p-8 text-center"><p className="font-nunito text-muted">Collab not found.</p></div></div>
  }

  const { collab } = data

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <Link href={`/dashboard/brand/collabs/${id}`} className="inline-flex items-center gap-2 border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[3px_3px_0_#FF2D78] transition-all">
        ← Back to Collab
      </Link>
      <h1 className="font-jakarta text-2xl font-extrabold text-ink">Contract</h1>
      <ContractView collab={collab} collabId={id} role="brand" accentColor="#FF2D78" />
      <ContractForm collabId={id} existing={collab.contract_terms || undefined} />
    </div>
  )
}
