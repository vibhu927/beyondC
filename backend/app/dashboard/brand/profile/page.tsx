'use client'

import Image from 'next/image'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type BrandProfile } from '@/lib/api/brand'
import { useState, useRef } from 'react'
import { createClient } from '@/lib/supabase/client'

const categoryOptions = ['D2C', 'SaaS', 'FMCG', 'Fashion', 'Beauty', 'Food & Beverage', 'Health', 'Education', 'Finance', 'Travel', 'Other']
const sizeOptions = [
  { value: 'micro', label: 'Micro', desc: 'Startup / small business' },
  { value: 'mid', label: 'Mid-size', desc: 'Growing brand' },
  { value: 'big', label: 'Enterprise', desc: 'Large / established brand' },
]

export default function BrandProfilePage() {
  const queryClient = useQueryClient()
  const [isEditing, setIsEditing] = useState(false)
  const [form, setForm] = useState({
    brand_name: '',
    brand_category: '',
    website: '',
    description: '',
    size: '' as string,
    gst_number: '',
    state: '',
    city: '',
    portfolio_links: [] as string[],
  })
  const [newLink, setNewLink] = useState('')
  const [successMsg, setSuccessMsg] = useState('')
  const [errorMsg, setErrorMsg] = useState('')
  const [uploadingLogo, setUploadingLogo] = useState(false)
  const logoInputRef = useRef<HTMLInputElement>(null)

  const { data, isLoading } = useQuery({
    queryKey: ['brand', 'profile'],
    queryFn: () => brandApi.getProfile(),
  })

  const profile = data?.profile

  const updateMutation = useMutation({
    mutationFn: (data: Partial<BrandProfile>) => brandApi.updateProfile(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brand', 'profile'] })
      setSuccessMsg('Profile updated!')
      setTimeout(() => setSuccessMsg(''), 3000)
      setIsEditing(false)
    },
    onError: (e: Error) => {
      setErrorMsg(e.message || 'Failed to save')
      setTimeout(() => setErrorMsg(''), 3000)
    },
  })

  if (isLoading) {
    return (
      <div className="max-w-3xl mx-auto">
        <div className="border-2 border-ink bg-white p-8 animate-pulse">
          <div className="h-6 bg-gray-200 rounded w-1/3 mb-4" />
          <div className="h-4 bg-gray-200 rounded w-2/3" />
        </div>
      </div>
    )
  }

  const handleStartEdit = () => {
    if (profile) {
      setForm({
        brand_name: profile.brand_name || '',
        brand_category: profile.brand_category || '',
        website: profile.website || '',
        description: profile.description || '',
        size: profile.size || '',
        gst_number: profile.gst_number || '',
        state: profile.state || '',
        city: profile.city || '',
        portfolio_links: [...(profile.portfolio_links || [])],
      })
    }
    setIsEditing(true)
  }

  const handleSave = () => {
    setErrorMsg('')
    updateMutation.mutate({
      brand_name: form.brand_name,
      brand_category: form.brand_category,
      website: form.website || undefined,
      description: form.description || undefined,
      size: (form.size as 'micro' | 'mid' | 'big') || undefined,
      gst_number: form.gst_number || undefined,
      state: form.state || undefined,
      city: form.city || undefined,
      portfolio_links: form.portfolio_links.length > 0 ? form.portfolio_links : undefined,
    })
  }

  const handleLogoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    setUploadingLogo(true)
    setErrorMsg('')
    try {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Not authenticated')
      const ext = file.name.split('.').pop()
      const path = `brands/${user.id}-logo-${Date.now()}.${ext}`
      const { error: uploadError } = await supabase.storage.from('avatars').upload(path, file)
      if (uploadError) throw uploadError
      const { data: urlData } = supabase.storage.from('avatars').getPublicUrl(path)
      await brandApi.updateProfile({ logo_url: urlData.publicUrl })
      queryClient.invalidateQueries({ queryKey: ['brand', 'profile'] })
      setSuccessMsg('Logo uploaded!')
      setTimeout(() => setSuccessMsg(''), 3000)
    } catch (e: any) {
      setErrorMsg(e.message || 'Logo upload failed')
      setTimeout(() => setErrorMsg(''), 3000)
    } finally {
      setUploadingLogo(false)
      if (logoInputRef.current) logoInputRef.current.value = ''
    }
  }

  const addPortfolioLink = () => {
    if (!newLink.trim()) return
    try {
      new URL(newLink)
    } catch {
      setErrorMsg('Please enter a valid URL')
      setTimeout(() => setErrorMsg(''), 3000)
      return
    }
    setForm(f => ({ ...f, portfolio_links: [...f.portfolio_links, newLink.trim()] }))
    setNewLink('')
  }

  const removePortfolioLink = (index: number) => {
    setForm(f => ({ ...f, portfolio_links: f.portfolio_links.filter((_, i) => i !== index) }))
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-jakarta text-3xl font-extrabold text-ink">Brand Profile</h1>
          <p className="mt-1 font-nunito text-base text-muted">Your brand information and settings.</p>
        </div>
        <button
          onClick={isEditing ? () => setIsEditing(false) : handleStartEdit}
          className="border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon hover:shadow-[3px_3px_0_#FF2D78] transition-all"
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
      <div className="border-2 border-ink bg-white shadow-[6px_6px_0_#FF2D78]">
        <div className="p-6 sm:p-8">
          {/* Logo + Brand Name */}
          <div className="flex items-center gap-4 mb-6">
            <div className="relative group">
              <input
                ref={logoInputRef}
                type="file"
                accept="image/*"
                onChange={handleLogoUpload}
                className="hidden"
              />
              {profile?.logo_url ? (
                <button
                  onClick={() => logoInputRef.current?.click()}
                  disabled={uploadingLogo}
                  className="relative w-20 h-20 rounded-full border-2 border-ink overflow-hidden hover:opacity-80 transition-opacity"
                >
                  <Image src={profile.logo_url} alt="Logo" fill className="object-cover" />
                </button>
              ) : (
                <button
                  onClick={() => logoInputRef.current?.click()}
                  disabled={uploadingLogo}
                  className="w-20 h-20 rounded-full bg-pink border-2 border-ink flex items-center justify-center font-jakarta text-3xl font-bold text-white hover:bg-pink/80 transition-colors"
                >
                  {uploadingLogo ? '...' : profile?.brand_name?.[0] || 'B'}
                </button>
              )}
              <div className="absolute inset-0 rounded-full bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center pointer-events-none">
                <span className="text-white text-[9px] font-space font-bold uppercase">Upload</span>
              </div>
            </div>
            <div className="flex-1 min-w-0">
              {isEditing ? (
                <div className="space-y-1">
                  <input
                    value={form.brand_name}
                    onChange={(e) => setForm(f => ({ ...f, brand_name: e.target.value }))}
                    className="border-2 border-ink px-2 py-1 font-jakarta text-xl font-bold text-ink w-full outline-none"
                    placeholder="Brand name"
                  />
                  <p className="font-nunito text-sm text-muted">{profile?.full_name || profile?.email || 'No info set'}</p>
                </div>
              ) : (
                <>
                  <h2 className="font-jakarta text-xl font-bold text-ink">{profile?.brand_name}</h2>
                  <div className="flex items-center gap-2 mt-1">
                    {profile?.brand_category && (
                      <span className="rounded-full border-2 border-ink bg-pink/20 px-3 py-0.5 font-space text-[9px] font-bold uppercase text-ink">
                        {profile.brand_category}
                      </span>
                    )}
                    {profile?.size && (
                      <span className="rounded-full border-2 border-ink bg-white px-3 py-0.5 font-space text-[9px] font-bold uppercase text-muted capitalize">
                        {profile.size}
                      </span>
                    )}
                    {profile?.is_brand_verified && (
                      <span className="rounded-full border-2 border-ink bg-neon px-3 py-0.5 font-space text-[9px] font-bold uppercase text-ink">
                        Verified
                      </span>
                    )}
                  </div>
                </>
              )}
            </div>
          </div>

          {isEditing ? (
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Brand Name</label>
                  <input
                    value={form.brand_name}
                    onChange={(e) => setForm(f => ({ ...f, brand_name: e.target.value }))}
                    className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]"
                  />
                </div>
                <div>
                  <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Category</label>
                  <select
                    value={form.brand_category}
                    onChange={(e) => setForm(f => ({ ...f, brand_category: e.target.value }))}
                    className="w-full border-2 border-ink bg-white px-3 py-3 font-nunito text-sm text-ink"
                  >
                    {categoryOptions.map((c) => <option key={c} value={c}>{c}</option>)}
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Website</label>
                  <input
                    value={form.website}
                    onChange={(e) => setForm(f => ({ ...f, website: e.target.value }))}
                    className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none"
                    placeholder="https://..."
                  />
                </div>
                <div>
                  <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Brand Size</label>
                  <div className="flex gap-2">
                    {sizeOptions.map((opt) => (
                      <button
                        key={opt.value}
                        type="button"
                        onClick={() => setForm(f => ({ ...f, size: f.size === opt.value ? '' : opt.value }))}
                        className={`flex-1 border-2 border-ink px-3 py-2 font-space text-[10px] font-bold transition-all ${
                          form.size === opt.value ? 'bg-pink text-white' : 'bg-white text-muted hover:bg-ink/5'
                        }`}
                      >
                        {opt.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">GST Number</label>
                  <input
                    value={form.gst_number}
                    onChange={(e) => setForm(f => ({ ...f, gst_number: e.target.value }))}
                    className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none"
                    placeholder="Optional"
                  />
                </div>
                <div>
                  <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">City</label>
                  <input
                    value={form.city}
                    onChange={(e) => setForm(f => ({ ...f, city: e.target.value }))}
                    className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none"
                    placeholder="e.g. Mumbai"
                  />
                </div>
              </div>

              <div>
                <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">State</label>
                <input
                  value={form.state}
                  onChange={(e) => setForm(f => ({ ...f, state: e.target.value }))}
                  className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none"
                  placeholder="e.g. Maharashtra"
                />
              </div>

              <div>
                <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Description</label>
                <textarea
                  value={form.description}
                  onChange={(e) => setForm(f => ({ ...f, description: e.target.value }))}
                  rows={3}
                  className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none"
                  placeholder="Tell creators about your brand..."
                />
              </div>

              {/* Portfolio Links */}
              <div>
                <label className="mb-1 block font-space text-[10px] font-bold uppercase text-muted">Portfolio Links</label>
                <div className="space-y-2">
                  {form.portfolio_links.map((link, i) => (
                    <div key={i} className="flex items-center gap-2">
                      <span className="flex-1 border-2 border-ink bg-white px-4 py-2 font-nunito text-sm text-ink truncate">{link}</span>
                      <button
                        type="button"
                        onClick={() => removePortfolioLink(i)}
                        className="border-2 border-ink bg-white px-2 py-2 font-space text-[9px] font-bold text-red-500 hover:bg-red-50"
                      >
                        ✕
                      </button>
                    </div>
                  ))}
                  <div className="flex gap-2">
                    <input
                      value={newLink}
                      onChange={(e) => setNewLink(e.target.value)}
                      onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addPortfolioLink())}
                      className="flex-1 border-2 border-ink bg-white px-4 py-2 font-nunito text-sm text-ink outline-none"
                      placeholder="https://..."
                    />
                    <button
                      type="button"
                      onClick={addPortfolioLink}
                      className="border-2 border-ink bg-white px-4 py-2 font-space text-[10px] font-bold text-ink hover:bg-ink/5"
                    >
                      + Add
                    </button>
                  </div>
                </div>
              </div>

              <button
                onClick={handleSave}
                disabled={updateMutation.isPending}
                className="w-full border-2 border-ink bg-pink px-6 py-3 font-space text-sm font-bold uppercase text-white shadow-[3px_3px_0_#0D0D0D] disabled:opacity-50"
              >
                {updateMutation.isPending ? 'Saving...' : 'Save Changes'}
              </button>
            </div>
          ) : (
            <>
              {/* Stats Row */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Credits</p>
                  <p className="font-jakarta text-lg font-bold text-ink">{profile?.credit_balance || 0}</p>
                </div>
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Collabs</p>
                  <p className="font-jakarta text-lg font-bold text-ink">{profile?.total_collabs || 0}</p>
                </div>
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Rating</p>
                  <p className="font-jakarta text-lg font-bold text-ink">{profile?.avg_rating ? `${Number(profile.avg_rating).toFixed(1)} ⭐` : '—'}</p>
                </div>
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Verified</p>
                  <p className="font-jakarta text-lg font-bold text-ink">{profile?.is_brand_verified ? '✓' : '—'}</p>
                </div>
              </div>

              {/* Info Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Website</p>
                  <p className="font-nunito text-sm font-semibold text-ink">{profile?.website || '—'}</p>
                </div>
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Email</p>
                  <p className="font-nunito text-sm font-semibold text-ink">{profile?.full_name || profile?.email || '—'}</p>
                </div>
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Brand Size</p>
                  <p className="font-nunito text-sm font-semibold text-ink capitalize">{profile?.size || '—'}</p>
                </div>
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Location</p>
                  <p className="font-nunito text-sm font-semibold text-ink">
                    {profile?.city ? `${profile.city}${profile.state ? `, ${profile.state}` : ''}` : '—'}
                  </p>
                </div>
                {profile?.gst_number && (
                  <div className="border-2 border-ink bg-white px-3 py-2">
                    <p className="font-space text-[9px] font-bold uppercase text-muted">GST Number</p>
                    <p className="font-nunito text-sm font-semibold text-ink">{profile.gst_number}</p>
                  </div>
                )}
              </div>

              {/* Description */}
              {profile?.description && (
                <div className="mt-4">
                  <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1">About</p>
                  <p className="font-nunito text-sm text-ink/80">{profile.description}</p>
                </div>
              )}

              {/* Portfolio Links */}
              {profile?.portfolio_links && profile.portfolio_links.length > 0 && (
                <div className="mt-4">
                  <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-2">Portfolio</p>
                  <div className="flex flex-wrap gap-2">
                    {profile.portfolio_links.map((link, i) => (
                      <a
                        key={i}
                        href={link}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="border-2 border-ink bg-white px-3 py-1 font-nunito text-xs text-ink hover:bg-pink/10 transition-colors truncate max-w-[200px]"
                      >
                        {new URL(link).hostname}
                      </a>
                    ))}
                  </div>
                </div>
              )}

              {/* Instagram Connection */}
              <div className="mt-4 flex items-center gap-3 flex-wrap">
                {profile?.instagram_verified ? (
                  <>
                    <span className="rounded-full border-2 border-ink px-3 py-1 font-space text-[10px] font-bold uppercase bg-pink text-white">
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
                    <a
                      href="/instagram-connect"
                      className="border-2 border-ink bg-ink px-3 py-1 font-space text-[9px] font-bold text-pink"
                    >
                      Connect
                    </a>
                  </>
                )}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
