'use client'

import { useMutation, useQueryClient } from '@tanstack/react-query'
import { collabApi } from '@/lib/api/collab'
import { useState } from 'react'

export function PaymentSetup({ collabId, agreedAmount }: { collabId: string; agreedAmount: number }) {
  const queryClient = useQueryClient()
  const [structure, setStructure] = useState<'full_upfront' | 'milestone_based'>('full_upfront')
  const [milestones, setMilestones] = useState([{ title: '', percentage: 0 }])
  const [success, setSuccess] = useState('')

  const mutation = useMutation({
    mutationFn: () => {
      if (structure === 'milestone_based') {
        const totalPct = milestones.reduce((s, m) => s + m.percentage, 0)
        if (totalPct !== 100) {
          throw new Error('Milestone percentages must sum to 100%')
        }
        return collabApi.setPaymentMilestones(
          collabId,
          structure,
          milestones.map((m) => ({
            title: m.title,
            amount: Math.round((agreedAmount * m.percentage) / 100),
          }))
        )
      }
      return collabApi.setPaymentMilestones(collabId, structure)
    },
    onSuccess: () => {
      setSuccess('Payment milestones saved!')
      queryClient.invalidateQueries({ queryKey: ['collab', collabId] })
      queryClient.invalidateQueries({ queryKey: ['collab-payment-milestones', collabId] })
      setTimeout(() => setSuccess(''), 3000)
    },
  })

  const addMilestone = () => setMilestones((prev) => [...prev, { title: '', percentage: 0 }])
  const updateMilestone = (i: number, field: 'title' | 'percentage', value: string | number) => {
    setMilestones((prev) => prev.map((m, idx) => (idx === i ? { ...m, [field]: value } : m)))
  }
  const removeMilestone = (i: number) => setMilestones((prev) => prev.filter((_, idx) => idx !== i))

  const totalPct = milestones.reduce((s, m) => s + m.percentage, 0)
  const isValid = structure === 'full_upfront' || (milestones.every((m) => m.title && m.percentage > 0) && totalPct === 100)

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#FF2D78]">
      <div className="border-b-2 border-ink bg-pink/10 px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-pink">Payment Setup</h3>
      </div>
      <div className="p-5 space-y-5">
        {success && <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">{success}</div>}

        <div>
          <label className="mb-2 block font-space text-[10px] font-bold uppercase text-muted">Payment Structure</label>
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => setStructure('full_upfront')}
              className={`border-2 border-ink px-4 py-4 text-left transition-all ${
                structure === 'full_upfront' ? 'bg-ink text-neon shadow-[3px_3px_0_#C8FF00]' : 'bg-white text-ink'
              }`}
            >
              <p className="font-jakarta text-sm font-bold">Full Upfront</p>
              <p className="font-nunito text-xs text-muted mt-1">Pay entire amount at once</p>
            </button>
            <button
              onClick={() => setStructure('milestone_based')}
              className={`border-2 border-ink px-4 py-4 text-left transition-all ${
                structure === 'milestone_based' ? 'bg-ink text-neon shadow-[3px_3px_0_#C8FF00]' : 'bg-white text-ink'
              }`}
            >
              <p className="font-jakarta text-sm font-bold">Milestone Based</p>
              <p className="font-nunito text-xs text-muted mt-1">Split into milestone payments</p>
            </button>
          </div>
        </div>

        <div className="border-2 border-ink bg-ink/5 px-4 py-3">
          <p className="font-space text-[10px] font-bold uppercase text-muted">Total Amount</p>
          <p className="font-jakarta text-2xl font-extrabold text-ink">₹{(agreedAmount / 100).toLocaleString()}</p>
        </div>

        {structure === 'milestone_based' && (
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <p className="font-space text-[10px] font-bold uppercase text-muted">Milestones</p>
              <button onClick={addMilestone} className="border-2 border-ink bg-ink px-3 py-1 font-space text-[9px] font-bold uppercase text-neon">
                + Add
              </button>
            </div>
            {milestones.map((m, i) => (
              <div key={i} className="border-2 border-ink bg-white p-3 flex items-center gap-3">
                <span className="font-jakarta text-sm font-bold text-muted shrink-0">{i + 1}.</span>
                <input
                  value={m.title}
                  onChange={(e) => updateMilestone(i, 'title', e.target.value)}
                  placeholder="Milestone name"
                  className="flex-1 border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none"
                />
                <div className="flex items-center gap-1 shrink-0">
                  <input
                    type="number"
                    value={m.percentage || ''}
                    onChange={(e) => updateMilestone(i, 'percentage', Math.min(100, Math.max(0, Number(e.target.value))))}
                    placeholder="%"
                    className="w-16 border-2 border-ink bg-white px-2 py-2 font-nunito text-sm text-ink outline-none text-center"
                  />
                  <span className="font-nunito text-xs text-muted">%</span>
                </div>
                <span className="font-jakarta text-xs font-bold text-ink shrink-0 w-16 text-right">
                  ₹{Math.round((agreedAmount * m.percentage) / 100).toLocaleString()}
                </span>
                {milestones.length > 1 && (
                  <button onClick={() => removeMilestone(i)} className="text-red-500 font-bold text-lg leading-none shrink-0">×</button>
                )}
              </div>
            ))}
            <div className="flex justify-between font-nunito text-sm">
              <span className={totalPct === 100 ? 'text-green-600 font-semibold' : 'text-red-500'}>
                Total: {totalPct}%
              </span>
              <span className="text-ink">{totalPct !== 100 ? 'Must sum to 100%' : '✓'}</span>
            </div>
          </div>
        )}

        <button
          onClick={() => mutation.mutate()}
          disabled={mutation.isPending || !isValid}
          className="w-full border-2 border-ink bg-pink px-6 py-3 font-space text-sm font-bold uppercase text-white shadow-[3px_3px_0_#0D0D0D] disabled:opacity-50"
        >
          {mutation.isPending ? 'Saving...' : structure === 'full_upfront' ? 'Set Full Upfront Payment' : 'Save Milestone Payments'}
        </button>
      </div>
    </div>
  )
}
