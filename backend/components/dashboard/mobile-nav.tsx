'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useFrontendSession } from '@/hooks/useFrontendSession'

interface NavItem {
  label: string
  href: string
  icon: string
}

const creatorNav: NavItem[] = [
  { label: 'Home', href: '/dashboard/creator', icon: '⌂' },
  { label: 'Campaigns', href: '/dashboard/creator/campaigns', icon: '⊞' },
  { label: 'Collabs', href: '/dashboard/creator/collabs', icon: '⇄' },
  { label: 'Wallet', href: '/dashboard/creator/wallet', icon: '₿' },
  { label: 'Profile', href: '/dashboard/creator/profile', icon: '👤' },
]

const brandNav: NavItem[] = [
  { label: 'Home', href: '/dashboard/brand', icon: '⌂' },
  { label: 'Campaigns', href: '/dashboard/brand/campaigns', icon: '⊞' },
  { label: 'Collabs', href: '/dashboard/brand/collabs', icon: '⇄' },
  { label: 'Credits', href: '/dashboard/brand/credits', icon: '₿' },
  { label: 'Profile', href: '/dashboard/brand/profile', icon: '👤' },
]

export default function MobileNav() {
  const pathname = usePathname()
  const { session } = useFrontendSession()
  const role = session?.role || 'creator'
  const navItems = role === 'creator' ? creatorNav : brandNav
  const activeBarColor = role === 'brand' ? 'bg-pink' : 'bg-neon'

  return (
    <nav className="lg:hidden fixed bottom-0 left-0 right-0 z-50 bg-white border-t-2 border-ink">
      <div className="flex items-center justify-around h-16 px-2">
        {navItems.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex flex-col items-center justify-center gap-0.5 px-3 py-1.5 min-w-0 transition-colors ${
                isActive ? 'text-ink' : 'text-muted/60'
              }`}
            >
              <span className={`text-lg ${isActive ? 'font-bold' : ''}`}>{item.icon}</span>
              <span className={`text-[10px] font-space font-bold uppercase tracking-wider ${
                isActive ? 'text-ink' : 'text-muted'
              }`}>
                {item.label}
              </span>
              {isActive && (
                <span className={`absolute bottom-0 left-1/2 -translate-x-1/2 w-8 h-0.5 ${activeBarColor} rounded-full`} />
              )}
            </Link>
          )
        })}
      </div>
    </nav>
  )
}
