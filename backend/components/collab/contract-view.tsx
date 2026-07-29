'use client'

import { useMutation, useQueryClient } from '@tanstack/react-query'
import { collabApi, type CollabDetail } from '@/lib/api/collab'
import { useFrontendSession } from '@/hooks/useFrontendSession'

export function ContractView({
  collab,
  collabId,
  role,
  accentColor = '#C8FF00',
}: {
  collab: CollabDetail
  collabId: string
  role: 'creator' | 'brand'
  accentColor?: string
}) {
  const queryClient = useQueryClient()
  const { session } = useFrontendSession()

  const contract = collab.contract_terms
  const myAccepted = role === 'creator' ? collab.creator_contract_accepted : collab.brand_contract_accepted
  const otherAccepted = role === 'creator' ? collab.brand_contract_accepted : collab.creator_contract_accepted

  const acceptMutation = useMutation({
    mutationFn: () => collabApi.acceptContract(collabId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['collab', collabId] }),
  })

  if (!contract) {
    return role === 'brand' ? (
      <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#FF2D78] text-center">
        <p className="font-nunito text-muted mb-4">No contract created yet.</p>
        <p className="font-nunito text-xs text-muted">Use the Contract tab to create one.</p>
      </div>
    ) : (
      <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#0D0D0D] text-center">
        <p className="font-nunito text-muted">Awaiting contract from the brand.</p>
      </div>
    )
  }

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#0D0D0D]">
      <div className="border-b-2 border-ink bg-ink/5 px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-ink">Contract Terms</h3>
      </div>
      <div className="p-5 space-y-4">
        <Section label="Deliverables" value={contract.deliverables} />
        <Section label="Timeline" value={contract.timeline} />
        <Section label="Payment Terms" value={contract.payment_terms} />
        {contract.milestones && contract.milestones.length > 0 && (
          <div>
            <p className="font-space text-[10px] font-bold uppercase text-muted mb-1">Milestones</p>
            <ul className="list-disc list-inside font-nunito text-sm text-ink/80 space-y-0.5">
              {contract.milestones.map((m: string, i: number) => <li key={i}>{m}</li>)}
            </ul>
          </div>
        )}
        {contract.special_conditions && <Section label="Special Conditions" value={contract.special_conditions} />}

        <div className="border-t-2 border-ink pt-4 mt-6">
          <div className="flex items-center justify-between text-sm">
            <span className="font-nunito font-semibold text-ink">You</span>
            <span className={`font-space text-[10px] font-bold uppercase ${myAccepted ? 'text-green-600' : 'text-amber-600'}`}>
              {myAccepted ? '✓ Accepted' : 'Pending'}
            </span>
          </div>
          <div className="flex items-center justify-between text-sm mt-2">
            <span className="font-nunito font-semibold text-muted">{role === 'creator' ? 'Brand' : 'Creator'}</span>
            <span className={`font-space text-[10px] font-bold uppercase ${otherAccepted ? 'text-green-600' : 'text-amber-600'}`}>
              {otherAccepted ? '✓ Accepted' : 'Pending'}
            </span>
          </div>
        </div>

        {!myAccepted && collab.status !== 'completed' && (
          <button
            onClick={() => acceptMutation.mutate()}
            disabled={acceptMutation.isPending}
            className="w-full border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase text-neon shadow-[3px_3px_0_#0D0D0D] disabled:opacity-50 hover:shadow-[4px_4px_0_#C8FF00] transition-all"
          >
            {acceptMutation.isPending ? 'Accepting...' : 'Accept Contract'}
          </button>
        )}
      </div>
    </div>
  )
}

function Section({ label, value }: { label: string; value?: string | null }) {
  if (!value) return null
  return (
    <div>
      <p className="font-space text-[10px] font-bold uppercase text-muted mb-1">{label}</p>
      <p className="font-nunito text-sm text-ink/80 whitespace-pre-wrap">{value}</p>
    </div>
  )
}
