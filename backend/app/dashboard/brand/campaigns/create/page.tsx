'use client'

import { useMutation } from '@tanstack/react-query'
import { brandApi } from '@/lib/api/brand'
import { useRouter } from 'next/navigation'
import { useState } from 'react'
import { INDIAN_STATES, getCities } from '@/lib/constants/india-locations'

const nicheOptions = ['Fashion', 'Food', 'Travel', 'Tech', 'Beauty', 'Comedy', 'Fitness', 'Gaming', 'Lifestyle', 'Health', 'Education']
const collabTypeOptions = ['paid', 'barter', 'hybrid']

export default function CreateCampaignPage() {
  const router = useRouter()
  const [form, setForm] = useState({
    title: '', description: '', niche: [] as string[], collab_type: 'paid',
    budget_min: '', budget_max: '', deliverables: '', slots: '1',
    deadline: '', target_location: '', requirements: '', min_followers: '',
    state: '', city: '', is_pan_india: false,
  })
  const [error, setError] = useState('')

  const createMutation = useMutation({
    mutationFn: () => brandApi.createCampaign({
      title: form.title,
      description: form.description,
      niche: form.niche,
      collab_type: form.collab_type,
      budget_min: form.budget_min ? Number(form.budget_min) * 100 : undefined,
      budget_max: form.budget_max ? Number(form.budget_max) * 100 : undefined,
      deliverables: form.deliverables.split(',').map((d) => d.trim()).filter(Boolean),
      slots: Number(form.slots),
      deadline: new Date(form.deadline).toISOString(),
      target_location: form.is_pan_india ? 'Pan India' : `${form.city}, ${form.state}`,
      requirements: form.requirements || undefined,
      min_followers: form.min_followers ? Number(form.min_followers) : undefined,
    }),
    onSuccess: () => router.push('/dashboard/brand/campaigns'),
    onError: (e: Error) => setError(e.message),
  })

  const toggleNiche = (n: string) => {
    setForm((f) => ({
      ...f,
      niche: f.niche.includes(n) ? f.niche.filter((x) => x !== n) : [...f.niche, n],
    }))
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!form.title || !form.description || form.niche.length === 0 || !form.deadline) {
      setError('Please fill all required fields')
      return
    }
    createMutation.mutate()
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <h1 className="font-jakarta text-3xl font-extrabold text-ink">Create Campaign</h1>

      {error && <div className="border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">{error}</div>}

      <form onSubmit={handleSubmit} className="border-2 border-ink bg-white p-6 sm:p-8 shadow-[6px_6px_0_#FF2D78] space-y-5">
        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Campaign Title *</label>
          <input value={form.title} onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]" placeholder="e.g. Summer Collection Launch" />
        </div>

        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Description *</label>
          <textarea value={form.description} onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))} rows={3} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]" placeholder="Tell creators about your campaign..." />
        </div>

        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Niches *</label>
          <div className="flex flex-wrap gap-2">
            {nicheOptions.map((n) => (
              <button key={n} type="button" onClick={() => toggleNiche(n)} className={`border-2 border-ink px-3 py-1.5 font-space text-[10px] font-bold uppercase transition-all ${form.niche.includes(n) ? 'bg-pink text-white shadow-[2px_2px_0_#0D0D0D]' : 'bg-white text-ink/70 hover:shadow-[2px_2px_0_#FF2D78]'}`}>{n}</button>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Collab Type *</label>
            <select value={form.collab_type} onChange={(e) => setForm((f) => ({ ...f, collab_type: e.target.value }))} className="w-full border-2 border-ink bg-white px-3 py-3 font-nunito text-sm text-ink">
              {collabTypeOptions.map((t) => <option key={t} value={t}>{t}</option>)}
            </select>
          </div>
          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Slots *</label>
            <input type="number" value={form.slots} onChange={(e) => setForm((f) => ({ ...f, slots: e.target.value }))} min="1" className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]" />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Min Budget (₹)</label>
            <input type="number" value={form.budget_min} onChange={(e) => setForm((f) => ({ ...f, budget_min: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none" />
          </div>
          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Max Budget (₹)</label>
            <input type="number" value={form.budget_max} onChange={(e) => setForm((f) => ({ ...f, budget_max: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none" />
          </div>
        </div>

        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Deliverables *</label>
          <input value={form.deliverables} onChange={(e) => setForm((f) => ({ ...f, deliverables: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]" placeholder="Reel, Story, Post (comma separated)" />
        </div>

        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Requirements</label>
          <textarea value={form.requirements} onChange={(e) => setForm((f) => ({ ...f, requirements: e.target.value }))} rows={2} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none" placeholder="Any specific requirements for creators..." />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Deadline *</label>
            <input type="date" value={form.deadline} onChange={(e) => setForm((f) => ({ ...f, deadline: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]" />
          </div>
          <div>
            <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Min Followers</label>
            <input type="number" value={form.min_followers} onChange={(e) => setForm((f) => ({ ...f, min_followers: e.target.value }))} className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none" placeholder="1000" />
          </div>
        </div>

        <div>
          <label className="flex items-center gap-3 cursor-pointer">
            <input type="checkbox" checked={form.is_pan_india} onChange={(e) => setForm((f) => ({ ...f, is_pan_india: e.target.checked }))} className="h-4 w-4 border-2 border-ink accent-pink" />
            <span className="font-nunito text-sm font-semibold text-ink">Pan India (no location restriction)</span>
          </label>
        </div>

        {!form.is_pan_india && (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">State</label>
              <select value={form.state} onChange={(e) => setForm((f) => ({ ...f, state: e.target.value, city: '' }))} className="w-full border-2 border-ink bg-white px-3 py-3 font-nunito text-sm text-ink">
                <option value="">Select state</option>
                {INDIAN_STATES.map((s) => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>
            <div>
              <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">City</label>
              <select value={form.city} onChange={(e) => setForm((f) => ({ ...f, city: e.target.value }))} disabled={!form.state} className="w-full border-2 border-ink bg-white px-3 py-3 font-nunito text-sm text-ink">
                <option value="">Select city</option>
                {form.state && getCities(form.state).map((c) => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>
          </div>
        )}

        <button
          type="submit"
          disabled={createMutation.isPending}
          className="w-full border-2 border-ink bg-pink px-6 py-4 font-space text-sm font-bold uppercase tracking-[0.08em] text-white shadow-[4px_4px_0_#0D0D0D] hover:shadow-[6px_6px_0_#0D0D0D] transition-all disabled:opacity-70"
        >
          {createMutation.isPending ? 'Creating...' : 'Create Campaign →'}
        </button>
      </form>
    </div>
  )
}
