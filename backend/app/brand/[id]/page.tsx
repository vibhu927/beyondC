'use client'

import Image from 'next/image'
import { useQuery } from '@tanstack/react-query'
import { apiClient } from '@/lib/api/client'
import { useParams } from 'next/navigation'
import Link from 'next/link'

interface PublicBrandProfile {
  id: string
  brand_name: string
  brand_category: string
  description: string | null
  website: string | null
  logo_url: string | null
  verified: boolean
  total_collabs: number
  avg_rating: number | null
  size: string | null
  city: string | null
  state: string | null
  portfolio_links: string[]
}

export default function PublicBrandProfilePage() {
  const params = useParams()
  const brandId = params.id as string

  const { data, isLoading, error } = useQuery({
    queryKey: ['brand', 'public', brandId],
    queryFn: () => apiClient<{ brand: PublicBrandProfile }>(`/api/brand/${brandId}`),
    enabled: !!brandId,
  })

  if (isLoading) {
    return (
      <div className="min-h-screen bg-cream">
        <div className="max-w-3xl mx-auto px-4 py-12">
          <div className="border-2 border-ink bg-white p-8 animate-pulse">
            <div className="h-6 bg-gray-200 rounded w-1/3 mb-4" />
            <div className="h-4 bg-gray-200 rounded w-2/3" />
          </div>
        </div>
      </div>
    )
  }

  if (error || !data?.brand) {
    return (
      <div className="min-h-screen bg-cream">
        <div className="max-w-3xl mx-auto px-4 py-12">
          <div className="border-2 border-ink bg-white p-8 text-center">
            <h1 className="font-jakarta text-2xl font-bold text-ink mb-2">Brand Not Found</h1>
            <p className="font-nunito text-muted">This brand profile does not exist or is not available.</p>
            <Link href="/" className="mt-4 inline-block border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon">
              Go Home
            </Link>
          </div>
        </div>
      </div>
    )
  }

  const brand = data.brand

  return (
    <div className="min-h-screen bg-cream">
      <div className="max-w-3xl mx-auto px-4 py-12">
        {/* Header Card */}
        <div className="border-2 border-ink bg-white shadow-[6px_6px_0_#FF2D78]">
          <div className="p-6 sm:p-8">
            <div className="flex items-center gap-4 mb-6">
              <div className="relative w-20 h-20 rounded-full border-2 border-ink overflow-hidden bg-pink flex items-center justify-center">
                {brand.logo_url ? (
                  <Image src={brand.logo_url} alt={brand.brand_name} fill className="object-cover" />
                ) : (
                  <span className="font-jakarta text-3xl font-bold text-white">{brand.brand_name?.[0] || 'B'}</span>
                )}
              </div>
              <div>
                <h1 className="font-jakarta text-2xl font-extrabold text-ink">{brand.brand_name}</h1>
                <div className="flex items-center gap-2 mt-1">
                  <span className="rounded-full border-2 border-ink bg-pink/20 px-3 py-0.5 font-space text-[9px] font-bold uppercase text-ink">
                    {brand.brand_category}
                  </span>
                  {brand.size && (
                    <span className="rounded-full border-2 border-ink bg-white px-3 py-0.5 font-space text-[9px] font-bold uppercase text-muted capitalize">
                      {brand.size}
                    </span>
                  )}
                  {brand.verified && (
                    <span className="rounded-full border-2 border-ink bg-neon px-3 py-0.5 font-space text-[9px] font-bold uppercase text-ink">
                      Verified
                    </span>
                  )}
                </div>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-3 mb-6">
              <div className="border-2 border-ink bg-white px-3 py-2 text-center">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Collabs</p>
                <p className="font-jakarta text-lg font-bold text-ink">{brand.total_collabs || 0}</p>
              </div>
              <div className="border-2 border-ink bg-white px-3 py-2 text-center">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Rating</p>
                <p className="font-jakarta text-lg font-bold text-ink">
                  {brand.avg_rating ? `${brand.avg_rating.toFixed(1)} ★` : '—'}
                </p>
              </div>
              <div className="border-2 border-ink bg-white px-3 py-2 text-center">
                <p className="font-space text-[9px] font-bold uppercase text-muted">Location</p>
                <p className="font-nunito text-sm font-semibold text-ink">
                  {brand.city || '—'}
                </p>
              </div>
            </div>

            {/* Description */}
            {brand.description && (
              <div className="mb-6">
                <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-1">About</p>
                <p className="font-nunito text-sm text-ink/80 leading-relaxed">{brand.description}</p>
              </div>
            )}

            {/* Info */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-6">
              {brand.website && (
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Website</p>
                  <a
                    href={brand.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="font-nunito text-sm font-semibold text-pink hover:underline"
                  >
                    {brand.website.replace(/^https?:\/\//, '')}
                  </a>
                </div>
              )}
              {brand.state && (
                <div className="border-2 border-ink bg-white px-3 py-2">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">State</p>
                  <p className="font-nunito text-sm font-semibold text-ink">{brand.state}</p>
                </div>
              )}
            </div>

            {/* Portfolio Links */}
            {brand.portfolio_links && brand.portfolio_links.length > 0 && (
              <div className="mb-6">
                <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted mb-2">Portfolio</p>
                <div className="flex flex-wrap gap-2">
                  {brand.portfolio_links.map((link, i) => (
                    <a
                      key={i}
                      href={link}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="border-2 border-ink bg-white px-3 py-1 font-nunito text-xs text-ink hover:bg-neon/20 transition-colors"
                    >
                      {new URL(link).hostname}
                    </a>
                  ))}
                </div>
              </div>
            )}

            {/* CTA */}
            <div className="flex gap-3">
              <Link
                href={`/join?ref=brand-${brand.id}`}
                className="flex-1 border-2 border-ink bg-pink px-6 py-3 font-space text-sm font-bold uppercase text-white text-center shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#0D0D0D] transition-all"
              >
                Collaborate
              </Link>
              {brand.website && (
                <a
                  href={brand.website}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex-1 border-2 border-ink bg-white px-6 py-3 font-space text-sm font-bold uppercase text-ink text-center hover:bg-ink/5 transition-all"
                >
                  Visit Website
                </a>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
