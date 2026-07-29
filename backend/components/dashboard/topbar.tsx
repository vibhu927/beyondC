'use client'

import Link from 'next/link'
import Image from 'next/image'
import { useFrontendSession } from '@/hooks/useFrontendSession'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { clearFrontendSession } from '@/lib/frontend-session'
import { useSidebar } from './sidebar-context'

export default function Topbar() {
  const { session } = useFrontendSession()
  const { collapsed } = useSidebar()
  const router = useRouter()
  const role = session?.role || 'creator'
  const hoverBg = role === 'brand' ? 'hover:bg-pink' : 'hover:bg-neon'

  const handleLogout = async () => {
    const supabase = createClient()
    await supabase.auth.signOut()
    clearFrontendSession()
    router.push('/')
  }

  return (
    <header
      className={`sticky top-0 z-30 flex items-center justify-between h-16 px-4 sm:px-6 bg-white border-b-2 border-ink transition-all duration-200 ${
        collapsed ? 'lg:ml-20' : 'lg:ml-64'
      }`}
    >
      <div className="flex items-center gap-3 lg:hidden">
        <span className="relative block h-8 w-8 overflow-hidden rounded-full border-2 border-ink">
          <Image
            src="/assets/logo.png"
            alt="BeyondC"
            fill
            className="object-cover"
          />
        </span>
        <span className="font-space text-xs font-bold text-ink">BeyondC</span>
      </div>

      <div className="hidden lg:flex items-center gap-2">
        <span className="font-space text-xs font-bold uppercase tracking-[0.08em] text-muted">
          {session?.role === 'creator' ? 'Creator Portal' : 'Brand Portal'}
        </span>
      </div>

      <div className="flex items-center gap-3 ml-auto">
        <Link
          href="/dashboard/notifications"
          className={`relative flex items-center justify-center w-10 h-10 border-2 border-ink bg-white ${hoverBg} transition-colors`}
        >
          <span className="text-lg">🔔</span>
        </Link>

        <div className="hidden sm:flex items-center gap-3 border-2 border-ink bg-white px-3 py-1.5">
          <span className="font-jakarta text-sm font-bold text-ink">
            {session?.firstName || 'User'}
          </span>
        </div>

        <button
          onClick={handleLogout}
          className="flex items-center justify-center w-10 h-10 border-2 border-ink bg-white hover:bg-pink hover:text-white transition-colors"
          title="Logout"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
        </button>
      </div>
    </header>
  )
}
