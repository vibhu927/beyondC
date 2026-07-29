'use client'

import { useMutation, useQueryClient } from '@tanstack/react-query'
import { collabApi, type CollabDetail } from '@/lib/api/collab'
import { useState } from 'react'

export function ContractForm({ collabId, existing, onSaved }: { collabId: string; existing?: CollabDetail['contract_terms']; onSaved?: () => void }) {
  const queryClient = useQueryClient()
  const [form, setForm] = useState({
    deliverables: existing?.deliverables || '',
    timeline: existing?.timeline || '',
    payment_terms: existing?.payment_terms || '',
    milestones: existing?.milestones?.join('\n') || '',
    special_conditions: existing?.special_conditions || '',
  })

  const mutation = useMutation({
    mutationFn: () =>
      collabApi.createContract(collabId, {
        deliverables: form.deliverables,
        timeline: form.timeline,
        payment_terms: form.payment_terms,
        milestones: form.milestones ? form.milestones.split('\n').filter(Boolean) : undefined,
        special_conditions: form.special_conditions || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['collab', collabId] })
      onSaved?.()
    },
  })

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#FF2D78]">
      <div className="border-b-2 border-ink bg-pink/10 px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-pink">{existing ? 'Edit' : 'Create'} Contract</h3>
      </div>
      <div className="p-5 space-y-4">
        <Field label="Deliverables" value={form.deliverables} onChange={(v) => setForm((f) => ({ ...f, deliverables: v }))} placeholder="What needs to be delivered?" />
        <Field label="Timeline" value={form.timeline} onChange={(v) => setForm((f) => ({ ...f, timeline: v }))} placeholder="Timeline and deadlines" />
        <Field label="Payment Terms" value={form.payment_terms} onChange={(v) => setForm((f) => ({ ...f, payment_terms: v }))} placeholder="Payment structure and schedule" />
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Milestones (one per line)</label>
          <textarea
            value={form.milestones}
            onChange={(e) => setForm((f) => ({ ...f, milestones: e.target.value }))}
            rows={3}
            className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none resize-none"
            placeholder="Brief review&#10;Draft submission&#10;Final approval&#10;Content posted"
          />
        </div>
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Special Conditions (optional)</label>
          <textarea
            value={form.special_conditions}
            onChange={(e) => setForm((f) => ({ ...f, special_conditions: e.target.value }))}
            rows={2}
            className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none resize-none"
            placeholder="Any special conditions or notes"
          />
        </div>
        <button
          onClick={() => mutation.mutate()}
          disabled={mutation.isPending || !form.deliverables || !form.timeline || !form.payment_terms}
          className="w-full border-2 border-ink bg-pink px-6 py-3 font-space text-sm font-bold uppercase text-white shadow-[3px_3px_0_#0D0D0D] disabled:opacity-50"
        >
          {mutation.isPending ? 'Saving...' : existing ? 'Update Contract' : 'Create Contract'}
        </button>
      </div>
    </div>
  )
}

function Field({ label, value, onChange, placeholder }: { label: string; value: string; onChange: (v: string) => void; placeholder: string }) {
  return (
    <div>
      <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">{label}</label>
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        rows={3}
        className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none resize-none"
        placeholder={placeholder}
      />
    </div>
  )
}
