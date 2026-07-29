'use client'

import Image from 'next/image'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type CreatorDetail } from '@/lib/api/brand'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { useState } from 'react'
import * as Dialog from '@radix-ui/react-dialog'

function formatNumber(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`
  return n.toLocaleString()
}

function isVideo(url: string): boolean {
  return /\.(mp4|mov|webm|avi|mkv)$/i.test(url)
}

function MediaThumb({ url, className }: { url: string; className?: string }) {
  return isVideo(url) ? (
    <video src={url} className={className} />
  ) : (
    <Image src={url} alt="" fill sizes="(max-width: 768px) 100vw, 50vw" className={className} />
  )
}

function StackedCell({ items, startIndex, onClick }: { items: string[]; startIndex: number; onClick: () => void }) {
  const count = Math.min(items.length, 3)
  const getStyle = (i: number, total: number): React.CSSProperties => {
    if (total === 1) return { transform: 'rotate(0deg) scale(0.9)' }
    if (total === 2) {
      return i === 0
        ? { transform: 'rotate(-7deg) translateX(-3px) scale(0.9)', zIndex: 1 }
        : { transform: 'rotate(7deg) translateX(3px) scale(0.9)', zIndex: 2 }
    }
    if (i === 0) return { transform: 'rotate(-8deg) translateX(-4px) scale(0.9)', zIndex: 1 }
    if (i === 1) return { transform: 'rotate(8deg) translateX(4px) scale(0.9)', zIndex: 2 }
    return { transform: 'rotate(0deg) scale(0.9)', zIndex: 3 }
  }
  return (
    <div className="relative cursor-pointer" onClick={onClick}>
      <div className="relative w-full h-full flex items-center justify-center">
        {items.slice(0, count).map((url, i) => (
          <div
            key={i}
            className="absolute origin-center transition-transform"
            style={{ width: '90%', height: '90%', ...getStyle(i, count) }}
          >
            <MediaThumb url={url} className="w-full h-full object-cover border-2 border-ink/30 shadow-md" />
          </div>
        ))}
      </div>
      {items.length > 3 && (
        <div className="absolute bottom-1.5 right-1.5 bg-black/70 px-2 py-0.5 font-space text-[9px] font-bold text-white rounded z-10">
          +{items.length - count}
        </div>
      )}
    </div>
  )
}

export default function BrandCreatorDetailPage() {
  const params = useParams()
  const id = params.id as string
  const router = useRouter()
  const queryClient = useQueryClient()
  const [mediaModalOpen, setMediaModalOpen] = useState(false)
  const [mediaModalIndex, setMediaModalIndex] = useState(0)
  const [requestOpen, setRequestOpen] = useState(false)
  const [collabType, setCollabType] = useState<'paid' | 'barter' | 'hybrid'>('paid')
  const [budget, setBudget] = useState('')
  const [deliverablesInput, setDeliverablesInput] = useState('')
  const [deliverables, setDeliverables] = useState<string[]>([])
  const [message, setMessage] = useState('')
  const [requestMsg, setRequestMsg] = useState('')
  const [requestError, setRequestError] = useState('')

  const { data, isLoading, error } = useQuery({
    queryKey: ['brand', 'creator-detail', id],
    queryFn: () => brandApi.getCreatorDetail(id),
    enabled: !!id,
  })

  const { data: savedData } = useQuery({
    queryKey: ['brand', 'saved-creators'],
    queryFn: () => brandApi.getSavedCreators(),
  })

  const isSaved = savedData?.saved_creators?.some((s) => s.creator_id === id) ?? false

  const saveMutation = useMutation({
    mutationFn: () => brandApi.saveCreator(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['brand', 'saved-creators'] }),
  })

  const unsaveMutation = useMutation({
    mutationFn: () => brandApi.unsaveCreator(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['brand', 'saved-creators'] }),
  })

  const sendRequestMutation = useMutation({
    mutationFn: () =>
      brandApi.sendRequest({
        creator_id: id,
        collab_type: collabType,
        deliverables,
        budget: budget ? Number(budget) * 100 : undefined,
        message: message || undefined,
      }),
    onSuccess: () => {
      setRequestMsg('Request sent!')
      setRequestError('')
      setRequestOpen(false)
      setTimeout(() => router.push('/dashboard/brand/requests'), 1000)
    },
    onError: (e) => {
      setRequestError(e instanceof Error ? e.message : 'Failed to send request')
    },
  })

  const creator: CreatorDetail | undefined = data?.creator
  const portfolioLinks: string[] = creator?.portfolio_links || []

  if (isLoading) {
    return (
      <div className="max-w-5xl mx-auto">
        <div className="border-2 border-ink bg-white p-8 animate-pulse">
          <div className="h-6 bg-gray-200 rounded w-1/3 mb-4" />
          <div className="h-4 bg-gray-200 rounded w-2/3" />
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="max-w-5xl mx-auto border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
        Error loading creator: {error instanceof Error ? error.message : 'Unknown error'}
      </div>
    )
  }

  if (!creator) {
    return (
      <div className="max-w-5xl mx-auto border-2 border-ink bg-white p-8 text-center">
        <p className="text-2xl mb-2">🔍</p>
        <p className="font-nunito text-muted">Creator not found.</p>
      </div>
    )
  }

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <button
        onClick={() => router.back()}
        className="inline-flex items-center gap-1 border-2 border-ink bg-white px-3 py-1.5 font-space text-[10px] font-bold uppercase text-ink hover:shadow-[2px_2px_0_#FF2D78] transition-all"
      >
        ← Back
      </button>

      {/* Header Card */}
      <div className="border-2 border-ink bg-white shadow-[6px_6px_0_#FF2D78]">
        <div className="p-6 sm:p-8">
          <div className="flex items-center gap-4 mb-4">
            <div className="relative w-16 h-16 rounded-full bg-pink border-2 border-ink flex items-center justify-center font-jakarta text-2xl font-bold text-white shrink-0 overflow-hidden">
              {creator.avatar_url ? (
                <Image src={creator.avatar_url} alt="" fill className="object-cover" />
              ) : (
                (creator.full_name?.[0] || creator.first_name?.[0] || '?').toUpperCase()
              )}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <h2 className="font-jakarta text-xl font-bold text-ink truncate">{creator.full_name || creator.first_name}</h2>
                {creator.instagram_verified && <span title="Instagram Verified">✅</span>}
              </div>
              <div className="flex items-center gap-2 mt-0.5">
                {creator.tier && (
                  <span className="border border-ink bg-pink/10 px-2 py-0.5 font-space text-[9px] font-bold uppercase text-ink">{creator.tier}</span>
                )}
                {creator.instagram_username && (
                  <span className="font-nunito text-xs text-muted">@{creator.instagram_username}</span>
                )}
              </div>
            </div>
            <div className="flex gap-2 shrink-0">
              <button
                onClick={() => isSaved ? unsaveMutation.mutate() : saveMutation.mutate()}
                disabled={saveMutation.isPending || unsaveMutation.isPending}
                className={`border-2 border-ink px-4 py-2 font-space text-xs font-bold uppercase transition-all disabled:opacity-50 ${
                  isSaved ? 'bg-pink text-white' : 'bg-white text-ink hover:bg-pink/10'
                }`}
              >
                {isSaved ? '★ Saved' : '☆ Save'}
              </button>
              <button
                onClick={() => setRequestOpen(true)}
                className="border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold uppercase text-white hover:shadow-[3px_3px_0_#FF2D78] transition-all"
              >
                Send Request →
              </button>
            </div>
          </div>

          {creator.bio && (
            <p className="font-nunito text-sm text-ink/80 mb-4">{creator.bio}</p>
          )}

          {/* Location */}
          {creator.city && (
            <p className="font-nunito text-xs text-muted mb-4">📍 {creator.city}{creator.state ? `, ${creator.state}` : ''}</p>
          )}

          {/* Stats Grid */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 mb-4">
            {creator.followers_count != null && (
              <div className="border-2 border-ink bg-white px-3 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Followers</p>
                <p className="font-jakarta text-base font-bold text-ink">{formatNumber(creator.followers_count)}</p>
              </div>
            )}
            {creator.engagement_rate != null && (
              <div className="border-2 border-ink bg-white px-3 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Engagement</p>
                <p className="font-jakarta text-base font-bold text-ink">{creator.engagement_rate.toFixed(1)}%</p>
              </div>
            )}
            {creator.avg_rating != null && (
              <div className="border-2 border-ink bg-white px-3 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Avg Rating</p>
                <p className="font-jakarta text-base font-bold text-ink">{creator.avg_rating.toFixed(1)} ⭐</p>
              </div>
            )}
            {creator.total_collabs > 0 && (
              <div className="border-2 border-ink bg-white px-3 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Collabs</p>
                <p className="font-jakarta text-base font-bold text-ink">{creator.total_collabs}</p>
              </div>
            )}
            {creator.starting_price != null && (
              <div className="border-2 border-ink bg-white px-3 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Starting Price</p>
                <p className="font-jakarta text-base font-bold text-ink">₹{creator.starting_price.toLocaleString()}</p>
              </div>
            )}
            {creator.posts_count != null && (
              <div className="border-2 border-ink bg-white px-3 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Posts</p>
                <p className="font-jakarta text-base font-bold text-ink">{formatNumber(creator.posts_count)}</p>
              </div>
            )}
            {creator.avg_video_views != null && (
              <div className="border-2 border-ink bg-white px-3 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Avg Views</p>
                <p className="font-jakarta text-base font-bold text-ink">{formatNumber(creator.avg_video_views)}</p>
              </div>
            )}
          </div>

          {/* Niches */}
          {creator.niches.length > 0 && (
            <div className="mb-2">
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1.5">Niches</p>
              <div className="flex flex-wrap gap-1.5">
                {creator.niches.map((n: string) => (
                  <span key={n} className="border border-ink bg-pink/10 px-2 py-0.5 font-space text-[9px] font-bold text-ink">{n}</span>
                ))}
              </div>
            </div>
          )}

          {/* Content Types */}
          {creator.content_types.length > 0 && (
            <div>
              <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1.5">Platforms / Content Types</p>
              <div className="flex flex-wrap gap-1.5">
                {creator.content_types.map((t: string) => (
                  <span key={t} className="border border-ink bg-white px-2 py-0.5 font-space text-[9px] font-bold text-ink">{t}</span>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Portfolio Grid */}
      <div className="border-2 border-ink bg-white shadow-[6px_6px_0_#FF2D78]">
        <div className="p-6 sm:p-8">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="font-jakarta text-lg font-bold text-ink">Portfolio</h2>
              <p className="font-nunito text-xs text-muted mt-0.5">{portfolioLinks.length} media items</p>
            </div>
          </div>

          {portfolioLinks.length === 0 ? (
            <div className="text-center py-10 border-2 border-dashed border-ink/30">
              <p className="text-3xl mb-2">🖼️</p>
              <p className="font-nunito text-sm text-muted">No portfolio items yet.</p>
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-2">
              {/* Cell 0 */}
              <div
                className="relative aspect-square border-2 border-ink bg-ink/5 overflow-hidden cursor-pointer hover:border-pink transition-colors"
                onClick={() => { setMediaModalIndex(0); setMediaModalOpen(true) }}
              >
                <MediaThumb url={portfolioLinks[0]} className="object-cover" />
              </div>

              {/* Cell 1 */}
              {portfolioLinks.length > 1 ? (
                <div
                  className="relative aspect-square border-2 border-ink bg-ink/5 overflow-hidden cursor-pointer hover:border-pink transition-colors"
                  onClick={() => { setMediaModalIndex(1); setMediaModalOpen(true) }}
                >
                  <MediaThumb url={portfolioLinks[1]} className="object-cover" />
                </div>
              ) : (
                <div className="aspect-square border-2 border-dashed border-ink/30 bg-white" />
              )}

              {/* Cell 2 */}
              {portfolioLinks.length > 2 ? (
                <div
                  className="relative aspect-square border-2 border-ink bg-ink/5 overflow-hidden cursor-pointer hover:border-pink transition-colors"
                  onClick={() => { setMediaModalIndex(2); setMediaModalOpen(true) }}
                >
                  <MediaThumb url={portfolioLinks[2]} className="object-cover" />
                </div>
              ) : (
                <div className="aspect-square border-2 border-dashed border-ink/30 bg-white" />
              )}

              {/* Cell 3 */}
              {portfolioLinks.length > 3 ? (
                portfolioLinks.length === 4 ? (
                  <div
                    className="relative aspect-square border-2 border-ink bg-ink/5 overflow-hidden cursor-pointer hover:border-pink transition-colors"
                    onClick={() => { setMediaModalIndex(3); setMediaModalOpen(true) }}
                  >
                    <MediaThumb url={portfolioLinks[3]} className="object-cover" />
                  </div>
                ) : (
                  <div className="relative aspect-square">
                    <StackedCell
                      items={portfolioLinks.slice(3)}
                      startIndex={3}
                      onClick={() => { setMediaModalIndex(3); setMediaModalOpen(true) }}
                    />
                  </div>
                )
              ) : (
                <div className="aspect-square border-2 border-dashed border-ink/30 bg-white" />
              )}
            </div>
          )}
        </div>
      </div>

      {requestMsg && (
        <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">{requestMsg}</div>
      )}

      {/* Send Request Modal */}
      <Dialog.Root open={requestOpen} onOpenChange={setRequestOpen}>
        <Dialog.Portal>
          <Dialog.Overlay className="fixed inset-0 z-50 bg-black/80" />
          <Dialog.Content className="fixed inset-4 z-50 flex flex-col mx-auto my-auto max-w-lg max-h-[90vh] bg-white border-2 border-ink p-6 sm:p-8 overflow-y-auto">
            <div className="flex items-center justify-between mb-6">
              <Dialog.Title className="font-jakarta text-lg font-bold text-ink">Send Request to {creator.full_name || creator.first_name}</Dialog.Title>
              <Dialog.Close asChild>
                <button className="w-8 h-8 flex items-center justify-center border-2 border-ink bg-white text-ink hover:bg-red-50 transition-colors">✕</button>
              </Dialog.Close>
            </div>

            {requestError && (
              <div className="mb-4 border-2 border-[#EF4444] bg-[#FEE2E2] px-3 py-2 font-nunito text-xs text-[#B91C1C]">{requestError}</div>
            )}

            <div className="space-y-4">
              <div>
                <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Collab Type</p>
                <div className="flex gap-2">
                  {(['paid', 'barter', 'hybrid'] as const).map((t) => (
                    <button
                      key={t}
                      onClick={() => setCollabType(t)}
                      className={`flex-1 border-2 border-ink px-3 py-2 font-space text-[10px] font-bold uppercase transition-all ${
                        collabType === t ? 'bg-pink text-white' : 'bg-white text-ink hover:bg-pink/10'
                      }`}
                    >
                      {t}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Budget (₹) — optional</p>
                <input
                  type="number"
                  value={budget}
                  onChange={(e) => setBudget(e.target.value)}
                  placeholder="e.g. 5000"
                  className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none"
                />
              </div>

              <div>
                <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Deliverables</p>
                <div className="flex gap-1">
                  <input
                    type="text"
                    value={deliverablesInput}
                    onChange={(e) => setDeliverablesInput(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' && deliverablesInput.trim()) {
                        e.preventDefault()
                        setDeliverables((d) => [...d, deliverablesInput.trim()])
                        setDeliverablesInput('')
                      }
                    }}
                    placeholder="Type and press Enter"
                    className="flex-1 border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none"
                  />
                </div>
                {deliverables.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 mt-1.5">
                    {deliverables.map((d, i) => (
                      <span key={i} className="flex items-center gap-1 border border-ink bg-pink/10 px-2 py-0.5 font-space text-[9px] font-bold text-ink">
                        {d}
                        <button onClick={() => setDeliverables((arr) => arr.filter((_, j) => j !== i))} className="text-ink/50 hover:text-red-600">✕</button>
                      </span>
                    ))}
                  </div>
                )}
              </div>

              <div>
                <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Message — optional</p>
                <textarea
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder="Brief note to the creator..."
                  rows={3}
                  className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none resize-none"
                />
              </div>
            </div>

            <div className="mt-6 flex gap-3">
              <button
                onClick={() => sendRequestMutation.mutate()}
                disabled={sendRequestMutation.isPending || deliverables.length === 0}
                className="flex-1 border-2 border-ink bg-pink px-4 py-2 font-space text-xs font-bold uppercase text-white disabled:opacity-50"
              >
                {sendRequestMutation.isPending ? 'Sending...' : 'Send Request'}
              </button>
              <Dialog.Close asChild>
                <button className="border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold uppercase text-ink">Cancel</button>
              </Dialog.Close>
            </div>
          </Dialog.Content>
        </Dialog.Portal>
      </Dialog.Root>

      {/* Media Viewer Modal */}
      <Dialog.Root open={mediaModalOpen} onOpenChange={setMediaModalOpen}>
        <Dialog.Portal>
          <Dialog.Overlay className="fixed inset-0 z-50 bg-black/80" />
          <Dialog.Content className="fixed inset-4 z-50 flex flex-col items-center justify-center mx-auto my-auto max-w-4xl max-h-[90vh] bg-ink border-2 border-white/20 p-4">
            <div className="flex items-center justify-between w-full mb-3">
              <Dialog.Title className="font-jakarta text-sm font-bold text-white">
                Portfolio ({mediaModalIndex + 1} of {portfolioLinks.length})
              </Dialog.Title>
              <Dialog.Close asChild>
                <button className="w-8 h-8 flex items-center justify-center border border-white/30 bg-white/10 text-white hover:bg-red-600 transition-colors">
                  ✕
                </button>
              </Dialog.Close>
            </div>

            <div className="flex-1 w-full flex items-center justify-center overflow-hidden min-h-0">
              {portfolioLinks[mediaModalIndex] && (
                isVideo(portfolioLinks[mediaModalIndex]) ? (
                  <video src={portfolioLinks[mediaModalIndex]} controls className="max-w-full max-h-[60vh] object-contain border-2 border-white/10" />
                ) : (
                  <Image src={portfolioLinks[mediaModalIndex]} alt={`Portfolio ${mediaModalIndex + 1}`} width={800} height={600} className="max-w-full max-h-[60vh] object-contain border-2 border-white/10" unoptimized />
                )
              )}
            </div>

            {portfolioLinks.length > 1 && (
              <div className="flex items-center justify-center gap-1.5 w-full py-2">
                {portfolioLinks.map((url, i) => (
                  <button
                    key={i}
                    onClick={() => setMediaModalIndex(i)}
                    className={`relative shrink-0 w-12 h-12 border-2 overflow-hidden transition-all ${
                      i === mediaModalIndex ? 'border-pink scale-110' : 'border-white/20 opacity-60 hover:opacity-100'
                    }`}
                  >
                    {isVideo(url) ? (
                      <video src={url} className="w-full h-full object-cover" />
                    ) : (
                      <Image src={url} alt="" fill className="object-cover" />
                    )}
                  </button>
                ))}
              </div>
            )}

            <div className="flex items-center justify-between w-full mt-3">
              <button
                onClick={() => setMediaModalIndex((i) => Math.max(0, i - 1))}
                disabled={mediaModalIndex === 0}
                className="border border-white/30 bg-white/10 px-4 py-1.5 font-space text-[10px] font-bold uppercase text-white hover:bg-white/20 transition-all disabled:opacity-30"
              >
                ← Prev
              </button>
              <button
                onClick={() => setMediaModalIndex((i) => Math.min(portfolioLinks.length - 1, i + 1))}
                disabled={mediaModalIndex >= portfolioLinks.length - 1}
                className="border border-white/30 bg-white/10 px-4 py-1.5 font-space text-[10px] font-bold uppercase text-white hover:bg-white/20 transition-all disabled:opacity-30"
              >
                Next →
              </button>
            </div>
          </Dialog.Content>
        </Dialog.Portal>
      </Dialog.Root>
    </div>
  )
}
