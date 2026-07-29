'use client'

import { useMutation, useQueryClient } from '@tanstack/react-query'
import { collabApi } from '@/lib/api/collab'
import { useState } from 'react'

const contentTypes = ['image', 'video', 'link', 'document']

export function ContentSubmitForm({ collabId, onSubmitted }: { collabId: string; onSubmitted?: () => void }) {
  const queryClient = useQueryClient()
  const [form, setForm] = useState({ content_url: '', content_type: 'image', caption: '', notes: '' })
  const [success, setSuccess] = useState('')

  const mutation = useMutation({
    mutationFn: () =>
      collabApi.submitContent(collabId, {
        content_url: form.content_url,
        content_type: form.content_type,
        caption: form.caption || undefined,
        notes: form.notes || undefined,
      }),
    onSuccess: () => {
      setSuccess('Content submitted!')
      setForm({ content_url: '', content_type: 'image', caption: '', notes: '' })
      queryClient.invalidateQueries({ queryKey: ['collab', collabId] })
      setTimeout(() => setSuccess(''), 3000)
      onSubmitted?.()
    },
  })

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#C8FF00]">
      <div className="border-b-2 border-ink bg-neon/20 px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-ink">Submit Content</h3>
      </div>
      <div className="p-5 space-y-4">
        {success && <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">{success}</div>}

        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Content URL *</label>
          <input
            value={form.content_url}
            onChange={(e) => setForm((f) => ({ ...f, content_url: e.target.value }))}
            className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none"
            placeholder="https://drive.google.com/..."
          />
        </div>

        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Content Type *</label>
          <div className="flex flex-wrap gap-2">
            {contentTypes.map((t) => (
              <button
                key={t}
                type="button"
                onClick={() => setForm((f) => ({ ...f, content_type: t }))}
                className={`border-2 border-ink px-3 py-1.5 font-space text-[10px] font-bold uppercase transition-all ${
                  form.content_type === t ? 'bg-ink text-neon shadow-[2px_2px_0_#C8FF00]' : 'bg-white text-ink'
                }`}
              >
                {t}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Caption (optional)</label>
          <textarea
            value={form.caption}
            onChange={(e) => setForm((f) => ({ ...f, caption: e.target.value }))}
            rows={2}
            className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none resize-none"
            placeholder="Caption for your post"
          />
        </div>

        <div>
          <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Notes for Brand (optional)</label>
          <textarea
            value={form.notes}
            onChange={(e) => setForm((f) => ({ ...f, notes: e.target.value }))}
            rows={2}
            className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none resize-none"
            placeholder="Any notes for the brand"
          />
        </div>

        <button
          onClick={() => mutation.mutate()}
          disabled={mutation.isPending || !form.content_url}
          className="w-full border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase text-neon shadow-[3px_3px_0_#0D0D0D] disabled:opacity-50"
        >
          {mutation.isPending ? 'Submitting...' : 'Submit Content'}
        </button>
      </div>
    </div>
  )
}
