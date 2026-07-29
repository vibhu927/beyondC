'use client'

import { useMutation, useQueryClient } from '@tanstack/react-query'
import { collabApi } from '@/lib/api/collab'
import { useState } from 'react'

export function RatingForm({ collabId, alreadyRated, partnerName, accentColor = '#C8FF00' }: { collabId: string; alreadyRated: boolean; partnerName: string; accentColor?: string }) {
  const queryClient = useQueryClient()
  const [score, setScore] = useState(0)
  const [hover, setHover] = useState(0)
  const [review, setReview] = useState('')
  const [success, setSuccess] = useState('')

  const mutation = useMutation({
    mutationFn: () => collabApi.submitRating(collabId, score, review || undefined),
    onSuccess: () => {
      setSuccess('Rating submitted!')
      queryClient.invalidateQueries({ queryKey: ['collab', collabId] })
      setTimeout(() => setSuccess(''), 3000)
    },
  })

  if (alreadyRated) {
    return (
      <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#0D0D0D] text-center">
        <p className="font-nunito text-muted">You&apos;ve already rated this collab.</p>
      </div>
    )
  }

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#0D0D0D]">
      <div className="border-b-2 border-ink bg-ink/5 px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-ink">Rate {partnerName}</h3>
      </div>
      <div className="p-5 space-y-4">
        {success && <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">{success}</div>}

        <div className="flex justify-center gap-2">
          {[1, 2, 3, 4, 5].map((star) => (
            <button
              key={star}
              onClick={() => setScore(star)}
              onMouseEnter={() => setHover(star)}
              onMouseLeave={() => setHover(0)}
              className={`text-3xl transition-all hover:scale-110 ${
                (hover || score) >= star ? 'text-neon drop-shadow-[0_0_4px_#C8FF00]' : 'text-gray-300'
              }`}
            >
              ★
            </button>
          ))}
        </div>
        <p className="text-center font-nunito text-sm text-ink">
          {score === 0 ? 'Tap a star to rate' : score === 1 ? 'Poor' : score === 2 ? 'Fair' : score === 3 ? 'Good' : score === 4 ? 'Great' : 'Excellent!'}
        </p>

        <textarea
          value={review}
          onChange={(e) => setReview(e.target.value)}
          rows={2}
          className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none resize-none"
          placeholder="Write a review (optional)"
        />

        <button
          onClick={() => mutation.mutate()}
          disabled={mutation.isPending || score === 0}
          className="w-full border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase text-neon shadow-[3px_3px_0_#0D0D0D] disabled:opacity-50"
        >
          {mutation.isPending ? 'Submitting...' : 'Submit Rating'}
        </button>
      </div>
    </div>
  )
}
