'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { collabApi } from '@/lib/api/collab'

export function PaymentView({ collabId, role, collabAmount }: { collabId: string; role: string; collabAmount: number | null }) {
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['collab-payment-milestones', collabId],
    queryFn: () => collabApi.getPaymentMilestones(collabId),
  })

  const releaseMutation = useMutation({
    mutationFn: (milestoneId: string) => collabApi.releasePaymentMilestone(collabId, milestoneId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['collab-payment-milestones', collabId] }),
  })

  if (isLoading) {
    return <div className="border-2 border-ink bg-white p-6 animate-pulse"><div className="h-4 bg-gray-200 rounded w-1/2" /></div>
  }

  const milestones = data?.milestones || []

  if (milestones.length === 0) {
    return (
      <div className="border-2 border-ink bg-white p-6 shadow-[3px_3px_0_#0D0D0D] text-center">
        <p className="font-nunito text-muted text-sm">No payment milestones set up yet.</p>
      </div>
    )
  }

  const totalReleased = milestones.filter((m: { status: string }) => m.status === 'released').reduce((sum: number, m: { amount: number }) => sum + m.amount, 0)

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#0D0D0D]">
      <div className="border-b-2 border-ink bg-ink/5 px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-ink">Payment Milestones</h3>
      </div>
      <div className="p-5 space-y-4">
        <div className="grid grid-cols-3 gap-3">
          <div className="border-2 border-ink bg-white px-3 py-2 text-center">
            <p className="font-space text-[9px] font-bold uppercase text-muted">Total</p>
            <p className="font-jakarta text-lg font-extrabold text-ink">₹{((collabAmount || 0) / 100).toLocaleString()}</p>
          </div>
          <div className="border-2 border-ink bg-neon/20 px-3 py-2 text-center">
            <p className="font-space text-[9px] font-bold uppercase text-muted">Released</p>
            <p className="font-jakarta text-lg font-extrabold text-green-700">₹{(totalReleased / 100).toLocaleString()}</p>
          </div>
          <div className="border-2 border-ink bg-white px-3 py-2 text-center">
            <p className="font-space text-[9px] font-bold uppercase text-muted">Pending</p>
            <p className="font-jakarta text-lg font-extrabold text-ink">₹{(((collabAmount || 0) - totalReleased) / 100).toLocaleString()}</p>
          </div>
        </div>

        <div className="space-y-2">
          {milestones.map((m: { id: string; title: string; amount: number; status: string; due_date: string | null }) => (
            <div key={m.id} className="border-2 border-ink bg-white px-4 py-3 flex items-center justify-between">
              <div>
                <p className="font-nunito text-sm font-semibold text-ink">{m.title}</p>
                <p className="font-jakarta text-xs font-bold text-muted">₹{(m.amount / 100).toLocaleString()}</p>
                {m.due_date && <p className="font-nunito text-[10px] text-muted">Due: {new Date(m.due_date).toLocaleDateString()}</p>}
              </div>
              <div className="flex items-center gap-2">
                <span className={`font-space text-[9px] font-bold uppercase ${m.status === 'released' ? 'text-green-600' : 'text-amber-600'}`}>
                  {m.status === 'released' ? '✓ Released' : 'Pending'}
                </span>
                {m.status !== 'released' && role === 'brand' && (
                  <button
                    onClick={() => releaseMutation.mutate(m.id)}
                    disabled={releaseMutation.isPending}
                    className="border-2 border-ink bg-pink px-3 py-1 font-space text-[9px] font-bold uppercase text-white disabled:opacity-50"
                  >
                    Release
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
