'use client'

import { useMutation } from '@tanstack/react-query'
import { brandApi } from '@/lib/api/brand'
import { useRouter } from 'next/navigation'
import { useState } from 'react'

const nicheOptions = ['Fashion', 'Food', 'Travel', 'Tech', 'Beauty', 'Comedy', 'Fitness', 'Gaming', 'Lifestyle', 'Health', 'Education']
const tierOptions = ['Nano', 'Micro', 'Mid', 'Macro']

export default function CreateEventPage() {
  const router = useRouter()
  const [form, setForm] = useState({
    title: '', description: '', event_date: '', location: '',
    total_slots: '10', target_niche: [] as string[], target_tier: [] as string[],
  })
  const [error, setError] = useState('')

  const createMutation = useMutation({
    mutationFn: () => brandApi.createEvent({
      title: form.title,
      description: form.description || undefined,
      event_date: new Date(form.event_date).toISOString(),
      location: form.location,
      total_slots: form.total_slots ? Number(form.total_slots) : undefined,
      target_niche: form.target_niche.length > 0 ? form.target_niche : undefined,
      target_tier: form.target_tier.length > 0 ? form.target_tier : undefined,
    }),
    onSuccess: () => router.push('/dashboard/brand/events'),
    onError: (e: Error) => setError(e.message),
  })

  const toggleArray = (field: 'target_niche' | 'target_tier', value: string) => {
    setForm((f) => ({
      ...f,
      [field]: f[field].includes(value) ? f[field].filter((x) => x !== value) : [...f[field], value],
    }))
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!form.title || !form.event_date || !form.location) {
      setError('Title, date, and location are required')
      return
    }
    createMutation.mutate()
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <h1 className="font-jakarta text-3xl font-extrabold text-ink">Create Event</h1>
      {error && <div className="border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">{error}</div>}

      <form onSubmit={handleSubmit} className="border-2 border-ink bg-white p-6 sm:p-8 shadow-[6px_6px_0_#FF2D78] space-y-5">
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Event Title *</label>
          <input value={form.title} onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]" placeholder="e.g. Product Launch Party" />
        </div>
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Description</label>
          <textarea value={form.description} onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))} rows={2} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none" />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Event Date *</label>
            <input type="datetime-local" value={form.event_date} onChange={(e) => setForm((f) => ({ ...f, event_date: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]" />
          </div>
          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Location *</label>
            <input value={form.location} onChange={(e) => setForm((f) => ({ ...f, location: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]" placeholder="Mumbai, India" />
          </div>
        </div>
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Total Slots</label>
          <input type="number" value={form.total_slots} onChange={(e) => setForm((f) => ({ ...f, total_slots: e.target.value }))} min="1" className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none" />
        </div>
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Target Niches</label>
          <div className="flex flex-wrap gap-2">
            {nicheOptions.map((n) => (
              <button key={n} type="button" onClick={() => toggleArray('target_niche', n)} className={`border-2 border-ink px-3 py-1.5 font-space text-[10px] font-bold uppercase transition-all ${form.target_niche.includes(n) ? 'bg-pink text-white shadow-[2px_2px_0_#0D0D0D]' : 'bg-white text-ink/70 hover:shadow-[2px_2px_0_#FF2D78]'}`}>{n}</button>
            ))}
          </div>
        </div>
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Target Tiers</label>
          <div className="flex flex-wrap gap-2">
            {tierOptions.map((t) => (
              <button key={t} type="button" onClick={() => toggleArray('target_tier', t)} className={`border-2 border-ink px-3 py-1.5 font-space text-[10px] font-bold uppercase transition-all ${form.target_tier.includes(t) ? 'bg-pink text-white shadow-[2px_2px_0_#0D0D0D]' : 'bg-white text-ink/70 hover:shadow-[2px_2px_0_#FF2D78]'}`}>{t}</button>
            ))}
          </div>
        </div>
        <button type="submit" disabled={createMutation.isPending} className="w-full border-2 border-ink bg-pink px-6 py-4 font-space text-sm font-bold uppercase tracking-[0.08em] text-white shadow-[4px_4px_0_#0D0D0D] hover:shadow-[6px_6px_0_#0D0D0D] transition-all disabled:opacity-70">
          {createMutation.isPending ? 'Creating...' : 'Create Event →'}
        </button>
      </form>
    </div>
  )
}
