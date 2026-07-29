'use client'

import Image from 'next/image'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { creatorApi, type CreatorProfile } from '@/lib/api/creator'
import { useState, useRef, useCallback } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import * as Dialog from '@radix-ui/react-dialog'

function formatNumber(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`
  return n.toLocaleString()
}

const MAX_PORTFOLIO = 6

function isVideo(url: string): boolean {
  return /\.(mp4|mov|webm|avi|mkv)$/i.test(url)
}

function MediaThumb({ url, className }: { url: string; className?: string }) {
  return isVideo(url) ? (
    <video src={url} className={className} />
  ) : (
    <Image src={url} alt="Portfolio" fill sizes="(max-width: 768px) 100vw, 50vw" className={className} />
  )
}

function MediaCell({ url, index, onClick, onDelete }: { url: string; index: number; onClick: () => void; onDelete: (url: string) => void }) {
  return (
    <div
      className="relative group border-2 border-ink bg-ink/5 overflow-hidden cursor-pointer hover:border-neon transition-colors"
      onClick={onClick}
    >
      <MediaThumb url={url} className="w-full h-full object-cover" />
      <button
        onClick={(e) => { e.stopPropagation(); onDelete(url) }}
        className="absolute top-1.5 right-1.5 w-7 h-7 rounded-full bg-black/60 flex items-center justify-center text-white text-xs opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
      >
        ✕
      </button>
    </div>
  )
}

function AddCell({ onClick, uploading }: { onClick: () => void; uploading: boolean }) {
  return (
    <button
      onClick={onClick}
      disabled={uploading}
      className="border-2 border-dashed border-ink/30 bg-white flex items-center justify-center hover:border-ink hover:bg-neon/10 transition-all"
    >
      <span className="text-2xl text-muted">+</span>
    </button>
  )
}

function StackedCell({ items, startIndex, totalCount, onClick }: { items: string[]; startIndex: number; totalCount: number; onClick: () => void }) {
  const count = Math.min(items.length, 3)
  const getStyle = (i: number, total: number): React.CSSProperties => {
    if (total === 1) return { transform: 'rotate(0deg) scale(0.9)' }
    if (total === 2) {
      return i === 0
        ? { transform: 'rotate(-7deg) translateX(-3px) scale(0.9)', zIndex: 1 }
        : { transform: 'rotate(7deg) translateX(3px) scale(0.9)', zIndex: 2 }
    }
    // 3 cards
    if (i === 0) return { transform: 'rotate(-8deg) translateX(-4px) scale(0.9)', zIndex: 1 }
    if (i === 1) return { transform: 'rotate(8deg) translateX(4px) scale(0.9)', zIndex: 2 }
    return { transform: 'rotate(0deg) scale(0.9)', zIndex: 3 }
  }
  return (
    <div
      className="relative cursor-pointer"
      onClick={onClick}
    >
      <div className="relative w-full h-full flex items-center justify-center">
        {items.slice(0, count).map((url, i) => (
          <div
            key={i}
            className="absolute origin-center transition-transform"
            style={{
              width: '90%',
              height: '90%',
              ...getStyle(i, count),
            }}
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

export default function CreatorProfilePage() {
  const queryClient = useQueryClient()
  const [isEditing, setIsEditing] = useState(false)
  const [editData, setEditData] = useState<Record<string, any>>({})
  const [saving, setSaving] = useState(false)
  const [successMsg, setSuccessMsg] = useState('')
  const [errorMsg, setErrorMsg] = useState('')
  const [uploading, setUploading] = useState(false)
  const [refreshingStats, setRefreshingStats] = useState(false)
  const [refreshMsg, setRefreshMsg] = useState('')
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [mediaModalOpen, setMediaModalOpen] = useState(false)
  const [mediaModalIndex, setMediaModalIndex] = useState(0)

  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'profile'],
    queryFn: () => creatorApi.getProfile(),
  })

  const profile = data?.profile
  const portfolioLinks: string[] = profile?.portfolio_links || []

  const startEditing = () => {
    if (!profile) return
    setEditData({
      display_name: profile.full_name || profile.first_name || '',
      phone: profile.phone || '',
      state: profile.state || '',
      city: profile.city || '',
      starting_price: profile.starting_price ? String(Math.round(profile.starting_price / 100)) : '',
      niches: [...(profile.niche || [])],
      platforms: [...(profile.content_type || [])],
    })
    setIsEditing(true)
  }

  const handleSave = async () => {
    setSaving(true)
    setErrorMsg('')
    setSuccessMsg('')
    try {
      await creatorApi.updateProfile({
        display_name: editData.display_name,
        phone: editData.phone || null,
        state: editData.state || null,
        city: editData.city || null,
        starting_price: editData.starting_price ? Number(editData.starting_price) * 100 : null,
        niches: editData.niches,
        platforms: editData.platforms,
      } as any)
      queryClient.invalidateQueries({ queryKey: ['creator', 'profile'] })
      setSuccessMsg('Profile updated!')
      setTimeout(() => setSuccessMsg(''), 3000)
      setIsEditing(false)
    } catch (e) {
      setErrorMsg(e instanceof Error ? e.message : 'Failed to save')
    } finally {
      setSaving(false)
    }
  }

  const updatePortfolio = async (links: string[]) => {
    try {
      await creatorApi.updateProfile({ portfolio_links: links } as any)
      queryClient.invalidateQueries({ queryKey: ['creator', 'profile'] })
    } catch (e) {
      setErrorMsg(e instanceof Error ? e.message : 'Failed to update portfolio')
    }
  }

  const handleRefreshStats = async () => {
    setRefreshingStats(true)
    setRefreshMsg('')
    try {
      const res = await fetch('/api/instagram/refresh-stats', { method: 'POST' })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to refresh')
      queryClient.invalidateQueries({ queryKey: ['creator', 'profile'] })
      setRefreshMsg('Stats refreshed!')
      setTimeout(() => setRefreshMsg(''), 3000)
    } catch (e) {
      setRefreshMsg(e instanceof Error ? e.message : 'Failed to refresh stats')
      setTimeout(() => setRefreshMsg(''), 5000)
    } finally {
      setRefreshingStats(false)
    }
  }

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    setUploading(true)
    setErrorMsg('')
    try {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Not authenticated')
      const ext = file.name.split('.').pop()
      const path = `creators/${user.id}-${Date.now()}.${ext}`
      const { error: uploadError } = await supabase.storage.from('avatars').upload(path, file)
      if (uploadError) throw uploadError
      const { data: urlData } = supabase.storage.from('avatars').getPublicUrl(path)
      const next = [...portfolioLinks, urlData.publicUrl]
      await creatorApi.updateProfile({ portfolio_links: next } as any)
      queryClient.invalidateQueries({ queryKey: ['creator', 'profile'] })
      setSuccessMsg('Media uploaded!')
      setTimeout(() => setSuccessMsg(''), 3000)
    } catch (e: any) {
      setErrorMsg(e.message || 'Upload failed')
    } finally {
      setUploading(false)
      if (fileInputRef.current) fileInputRef.current.value = ''
    }
  }

  const handleDeleteMedia = async (url: string) => {
    const next = portfolioLinks.filter((u) => u !== url)
    await updatePortfolio(next)
    setSuccessMsg('Media removed.')
    setTimeout(() => setSuccessMsg(''), 3000)
  }

  const toggleNiche = (n: string) => {
    setEditData((d: Record<string, any>) => ({
      ...d,
      niches: (d.niches || []).includes(n)
        ? d.niches.filter((x: string) => x !== n)
        : [...(d.niches || []), n],
    }))
  }

  const togglePlatform = (t: string) => {
    setEditData((d: Record<string, any>) => ({
      ...d,
      platforms: (d.platforms || []).includes(t)
        ? d.platforms.filter((x: string) => x !== t)
        : [...(d.platforms || []), t],
    }))
  }

  const nicheOptions = ['Fashion', 'Food', 'Travel', 'Tech', 'Beauty', 'Comedy', 'Fitness', 'Gaming', 'Lifestyle', 'Health', 'Education']
  const platformOptions = ['Reels', 'YouTube', 'Blog', 'Podcast', 'Shorts', 'Stories']

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

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-jakarta text-3xl font-extrabold text-ink">Profile</h1>
          <p className="mt-1 font-nunito text-base text-muted">Your creator profile and settings.</p>
        </div>
        <button
          onClick={() => (isEditing ? setIsEditing(false) : startEditing())}
          className="border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon hover:shadow-[3px_3px_0_#C8FF00] transition-all"
        >
          {isEditing ? 'Cancel' : 'Edit Profile'}
        </button>
      </div>

      {successMsg && (
        <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">{successMsg}</div>
      )}
      {errorMsg && (
        <div className="border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">{errorMsg}</div>
      )}

      {/* Profile Card */}
      <div className="border-2 border-ink bg-white shadow-[6px_6px_0_#C8FF00]">
        <div className="p-6 sm:p-8">
          <div className="flex items-center gap-4 mb-6">
            <div className="w-16 h-16 rounded-full bg-neon border-2 border-ink flex items-center justify-center font-jakarta text-2xl font-bold text-ink">
              {profile?.first_name?.[0] || '?'}
            </div>
            <div>
              {isEditing ? (
                <div className="space-y-1">
                  <input
                    value={editData.display_name || ''}
                    onChange={(e) => setEditData((d: any) => ({ ...d, display_name: e.target.value }))}
                    className="border-2 border-ink px-2 py-1 font-jakarta text-lg font-bold text-ink w-full outline-none"
                    placeholder="Full name"
                  />
                  <p className="font-nunito text-sm text-muted">{profile?.email}</p>
                </div>
              ) : (
                <>
                  <h2 className="font-jakarta text-xl font-bold text-ink">{profile?.first_name} {profile?.full_name}</h2>
                  <p className="font-nunito text-sm text-muted">{profile?.email}</p>
                </>
              )}
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase text-muted">Phone</p>
              {isEditing ? (
                <input
                  value={editData.phone || ''}
                  onChange={(e) => setEditData((d: any) => ({ ...d, phone: e.target.value }))}
                  className="w-full border-0 p-0 font-nunito text-sm font-semibold text-ink outline-none"
                  placeholder="+91..."
                />
              ) : (
                <p className="font-nunito text-sm font-semibold text-ink">{profile?.phone || '—'}</p>
              )}
            </div>
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase text-muted">Location</p>
              {isEditing ? (
                <div className="flex gap-1">
                  <input
                    value={editData.city || ''}
                    onChange={(e) => setEditData((d: any) => ({ ...d, city: e.target.value }))}
                    className="w-1/2 border-0 p-0 font-nunito text-sm font-semibold text-ink outline-none"
                    placeholder="City"
                  />
                  <input
                    value={editData.state || ''}
                    onChange={(e) => setEditData((d: any) => ({ ...d, state: e.target.value }))}
                    className="w-1/2 border-0 p-0 font-nunito text-sm font-semibold text-ink outline-none"
                    placeholder="State"
                  />
                </div>
              ) : (
                <p className="font-nunito text-sm font-semibold text-ink">{profile?.city ? `${profile.city}, ${profile.state}` : '—'}</p>
              )}
            </div>
            {profile?.tier && (
              <div className="border-2 border-ink bg-white px-3 py-2">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Tier</p>
                <p className="font-nunito text-sm font-semibold text-ink capitalize">{profile.tier}</p>
              </div>
            )}
            <div className="border-2 border-ink bg-white px-3 py-2">
              <p className="font-space text-[9px] font-bold uppercase text-muted">Starting Price</p>
              {isEditing ? (
                <div className="flex items-center gap-1">
                  <span className="font-nunito text-sm font-semibold text-ink">₹</span>
                  <input
                    type="number"
                    value={editData.starting_price || ''}
                    onChange={(e) => setEditData((d: any) => ({ ...d, starting_price: e.target.value }))}
                    className="flex-1 border-0 p-0 font-nunito text-sm font-semibold text-ink outline-none"
                    placeholder="0"
                  />
                </div>
              ) : (
                <p className="font-nunito text-sm font-semibold text-ink">
                  {profile?.starting_price != null ? `₹${Math.round(profile.starting_price / 100).toLocaleString()}` : '—'}
                </p>
              )}
            </div>
          </div>

          {/* Niches */}
          <div className="mt-4">
            <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-2">Niches</p>
            {isEditing ? (
              <div className="flex flex-wrap gap-1.5">
                {nicheOptions.map((n) => (
                  <button
                    key={n}
                    onClick={() => toggleNiche(n)}
                    className={`border-2 border-ink px-2 py-0.5 font-space text-[9px] font-bold transition-all ${
                      (editData.niches || []).includes(n) ? 'bg-neon text-ink' : 'bg-white text-muted'
                    }`}
                  >
                    {n}
                  </button>
                ))}
              </div>
            ) : (
              <div className="flex flex-wrap gap-1.5">
                {profile?.niche?.map((n: string) => (
                  <span key={n} className="border border-ink bg-neon/30 px-2 py-0.5 font-space text-[9px] font-bold text-ink">{n}</span>
                ))}
              </div>
            )}
          </div>

          {/* Platforms */}
          <div className="mt-4">
            <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-2">Platforms</p>
            {isEditing ? (
              <div className="flex flex-wrap gap-1.5">
                {platformOptions.map((t) => (
                  <button
                    key={t}
                    onClick={() => togglePlatform(t)}
                    className={`border-2 border-ink px-2 py-0.5 font-space text-[9px] font-bold transition-all ${
                      (editData.platforms || []).includes(t) ? 'bg-ink text-white' : 'bg-white text-muted'
                    }`}
                  >
                    {t}
                  </button>
                ))}
              </div>
            ) : (
              <div className="flex flex-wrap gap-1.5">
                {profile?.content_type?.map((t: string) => (
                  <span key={t} className="border border-ink bg-white px-2 py-0.5 font-space text-[9px] font-bold text-ink">{t}</span>
                ))}
              </div>
            )}
          </div>

          {/* Instagram Connection Status */}
          <div className="mt-6 flex items-center gap-3 flex-wrap">
            {profile?.instagram_verified ? (
              <>
                <span className="rounded-full border-2 border-ink px-3 py-1 font-space text-[10px] font-bold uppercase bg-neon text-ink">
                  ✅ Instagram Connected
                </span>
                {profile?.instagram_username && (
                  <span className="rounded-full border-2 border-ink px-3 py-1 font-space text-[10px] font-bold bg-white text-ink">
                    @{profile.instagram_username}
                  </span>
                )}
              </>
            ) : (
              <>
                <span className="rounded-full border-2 border-ink px-3 py-1 font-space text-[10px] font-bold uppercase bg-white text-muted">
                  ❌ Instagram Not Connected
                </span>
                <Link
                  href="/instagram-connect"
                  className="border-2 border-ink bg-ink px-3 py-1 font-space text-[9px] font-bold text-neon"
                >
                  Connect
                </Link>
              </>
            )}
          </div>

          {isEditing && (
            <div className="mt-6 flex gap-3">
              <button
                onClick={handleSave}
                disabled={saving}
                className="border-2 border-ink bg-neon px-6 py-2 font-space text-xs font-bold uppercase text-ink disabled:opacity-50"
              >
                {saving ? 'Saving...' : 'Save Changes'}
              </button>
              <button
                onClick={() => setIsEditing(false)}
                className="border-2 border-ink bg-white px-6 py-2 font-space text-xs font-bold uppercase text-ink"
              >
                Cancel
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Instagram Stats + Media — Side by Side */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Instagram Stats Card — LEFT */}
        {profile?.instagram_verified && (
          <div className="border-2 border-ink overflow-hidden shadow-[6px_6px_0_#0D0D0D] h-fit"
            style={{
              background: 'linear-gradient(135deg, #833AB4, #C13584, #E1306C, #FD1D1D, #F77737, #FCAF45)',
            }}
          >
            <div className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-8 h-8 rounded-lg bg-white/20 flex items-center justify-center border border-white/30">
                  <span className="text-white text-sm">📷</span>
                </div>
                <div className="flex-1">
                  <p className="font-jakarta text-lg font-extrabold text-white">
                    @{profile.instagram_username || 'instagram'}
                  </p>
                </div>
                <span className="rounded-full bg-white/20 px-3 py-1 font-space text-[9px] font-bold uppercase text-white border border-white/30 flex items-center gap-1">
                  ✅ Verified
                </span>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="bg-white/15 rounded-lg px-4 py-3 border border-white/20">
                  <p className="font-space text-[8px] font-bold uppercase text-white/70">Followers</p>
                  <p className="font-jakarta text-xl font-extrabold text-white">{profile.followers_count ? formatNumber(profile.followers_count) : '—'}</p>
                </div>
                <div className="bg-white/15 rounded-lg px-4 py-3 border border-white/20">
                  <p className="font-space text-[8px] font-bold uppercase text-white/70">Engagement</p>
                  <p className="font-jakarta text-xl font-extrabold text-white">{profile.engagement_rate ? `${profile.engagement_rate.toFixed(1)}%` : '—'}</p>
                </div>
                <div className="bg-white/15 rounded-lg px-4 py-3 border border-white/20">
                  <p className="font-space text-[8px] font-bold uppercase text-white/70">Avg Views</p>
                  <p className="font-jakarta text-xl font-extrabold text-white">{profile.avg_video_views ? formatNumber(profile.avg_video_views) : '—'}</p>
                </div>
                <div className="bg-white/15 rounded-lg px-4 py-3 border border-white/20">
                  <p className="font-space text-[8px] font-bold uppercase text-white/70">Posts</p>
                  <p className="font-jakarta text-xl font-extrabold text-white">{profile.posts_count ? formatNumber(profile.posts_count) : '—'}</p>
                </div>
              </div>

              {profile.following_count != null && (
                <div className="mt-2 flex items-center gap-4 text-white/60 font-nunito text-xs">
                  <span>{formatNumber(profile.following_count)} following</span>
                  {profile.avg_likes != null && <span>{formatNumber(profile.avg_likes)} avg likes</span>}
                  {profile.avg_comments != null && <span>{formatNumber(profile.avg_comments)} avg comments</span>}
                </div>
              )}

              <div className="mt-4 flex items-center justify-between">
                <p className="text-white/50 font-nunito text-[10px]">
                  {profile.stats_fetched_at
                    ? `Last updated: ${new Date(profile.stats_fetched_at).toLocaleDateString()}`
                    : 'Stats not yet fetched'}
                </p>
                <button
                  onClick={handleRefreshStats}
                  disabled={refreshingStats}
                  className="border-2 border-white/50 bg-white/20 px-4 py-1.5 font-space text-[10px] font-bold uppercase text-white hover:bg-white/30 transition-all disabled:opacity-50"
                >
                  {refreshingStats ? 'Refreshing...' : refreshMsg || 'Refresh Stats'}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Portfolio Media — RIGHT */}
        <div className="border-2 border-ink bg-white shadow-[6px_6px_0_#C8FF00] h-fit">
          <div className="p-6 sm:p-8">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="font-jakarta text-lg font-bold text-ink">Portfolio</h2>
                <p className="font-nunito text-xs text-muted mt-0.5">
                  Showcase your work ({portfolioLinks.length}/{MAX_PORTFOLIO})
                </p>
              </div>
              <div>
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*,video/*"
                  onChange={handleUpload}
                  className="hidden"
                />
                <button
                  onClick={() => fileInputRef.current?.click()}
                  disabled={uploading || portfolioLinks.length >= MAX_PORTFOLIO}
                  className="border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon hover:shadow-[3px_3px_0_#C8FF00] transition-all disabled:opacity-50"
                >
                  {uploading ? 'Uploading...' : '+ Add'}
                </button>
              </div>
            </div>

            {portfolioLinks.length === 0 ? (
              <div className="text-center py-10 border-2 border-dashed border-ink/30 aspect-square flex flex-col items-center justify-center">
                <p className="text-3xl mb-2">🖼️</p>
                <p className="font-nunito text-sm text-muted">
                  Upload photos or videos to showcase your work.
                </p>
              </div>
            ) : (
              <div className="aspect-square grid grid-cols-2 gap-2">
                {/* Cell 0 — top-left */}
                <MediaCell
                  url={portfolioLinks[0]}
                  index={0}
                  onClick={() => { setMediaModalIndex(0); setMediaModalOpen(true) }}
                  onDelete={handleDeleteMedia}
                />

                {/* Cell 1 — top-right */}
                {portfolioLinks.length > 1 ? (
                  <MediaCell
                    url={portfolioLinks[1]}
                    index={1}
                    onClick={() => { setMediaModalIndex(1); setMediaModalOpen(true) }}
                    onDelete={handleDeleteMedia}
                  />
                ) : (
                  <AddCell onClick={() => fileInputRef.current?.click()} uploading={uploading} />
                )}

                {/* Cell 2 — bottom-left */}
                {portfolioLinks.length > 2 ? (
                  <MediaCell
                    url={portfolioLinks[2]}
                    index={2}
                    onClick={() => { setMediaModalIndex(2); setMediaModalOpen(true) }}
                    onDelete={handleDeleteMedia}
                  />
                ) : (
                  <AddCell onClick={() => fileInputRef.current?.click()} uploading={uploading} />
                )}

                {/* Cell 3 — bottom-right: 4th image, stacked, or add button */}
                {portfolioLinks.length > 3 ? (
                  portfolioLinks.length === 4 ? (
                    <MediaCell
                      url={portfolioLinks[3]}
                      index={3}
                      onClick={() => { setMediaModalIndex(3); setMediaModalOpen(true) }}
                      onDelete={handleDeleteMedia}
                    />
                  ) : (
                    <StackedCell
                      items={portfolioLinks.slice(3)}
                      startIndex={3}
                      totalCount={portfolioLinks.length}
                      onClick={() => { setMediaModalIndex(3); setMediaModalOpen(true) }}
                    />
                  )
                ) : (
                  <AddCell onClick={() => fileInputRef.current?.click()} uploading={uploading} />
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Media Viewer Modal */}
      <Dialog.Root open={mediaModalOpen} onOpenChange={setMediaModalOpen}>
        <Dialog.Portal>
          <Dialog.Overlay className="fixed inset-0 z-50 bg-black/80 media-modal-overlay" />
          <Dialog.Content className="fixed inset-4 z-50 flex flex-col items-center justify-center mx-auto my-auto max-w-4xl max-h-[90vh] bg-ink border-2 border-white/20 p-4 media-modal-content">
            <div className="flex items-center justify-between w-full mb-3">
              <Dialog.Title className="font-jakarta text-sm font-bold text-white">
                Media ({mediaModalIndex + 1} of {portfolioLinks.length})
              </Dialog.Title>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => fileInputRef.current?.click()}
                  className="border border-white/30 bg-white/10 px-3 py-1 font-space text-[10px] font-bold uppercase text-white hover:bg-white/20 transition-all"
                >
                  + Upload
                </button>
                <Dialog.Close asChild>
                  <button className="w-8 h-8 flex items-center justify-center border border-white/30 bg-white/10 text-white hover:bg-red-600 transition-colors">
                    ✕
                  </button>
                </Dialog.Close>
              </div>
            </div>

            <div className="relative flex-1 w-full flex items-center justify-center overflow-hidden min-h-0">
              {portfolioLinks[mediaModalIndex] && (
                isVideo(portfolioLinks[mediaModalIndex]) ? (
                  <video
                    src={portfolioLinks[mediaModalIndex]}
                    controls
                    className="max-w-full max-h-[60vh] object-contain border-2 border-white/10"
                  />
                ) : (
                  <Image
                    src={portfolioLinks[mediaModalIndex]}
                    alt={`Media ${mediaModalIndex + 1}`}
                    fill
                    className="object-contain border-2 border-white/10"
                  />
                )
              )}
            </div>

            {/* Thumbnail strip */}
            {portfolioLinks.length > 1 && (
              <div className="flex items-center justify-center gap-1.5 w-full py-2">
                {portfolioLinks.map((url, i) => (
                  <button
                    key={i}
                    onClick={() => setMediaModalIndex(i)}
                    className={`relative shrink-0 w-12 h-12 border-2 overflow-hidden transition-all ${
                      i === mediaModalIndex
                        ? 'border-neon scale-110'
                        : 'border-white/20 opacity-60 hover:opacity-100'
                    }`}
                  >
                    {isVideo(url) ? (
                      <video src={url} className="w-full h-full object-cover" />
                    ) : (
                      <Image src={url} alt={`Thumb ${i + 1}`} fill className="object-cover" />
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
                onClick={() => {
                  const url = portfolioLinks[mediaModalIndex]
                  if (url) {
                    handleDeleteMedia(url)
                    if (mediaModalIndex >= portfolioLinks.length - 1 && mediaModalIndex > 0) {
                      setMediaModalIndex(mediaModalIndex - 1)
                    }
                  }
                }}
                className="border border-red-500/50 bg-red-600/20 px-4 py-1.5 font-space text-[10px] font-bold uppercase text-red-400 hover:bg-red-600/40 transition-all"
              >
                Delete
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
