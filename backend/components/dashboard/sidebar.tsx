'use client'

import Link from 'next/link'
import Image from 'next/image'
import { usePathname } from 'next/navigation'
import { useFrontendSession } from '@/hooks/useFrontendSession'
import { useSidebar } from './sidebar-context'
import { useTheme } from './theme-context'

interface NavItem {
  label: string
  href: string
  icon: string
}

const creatorNav: NavItem[] = [
  { label: 'Home', href: '/dashboard/creator', icon: '⌂' },
  { label: 'Browse Campaigns', href: '/dashboard/creator/campaigns', icon: '⊞' },
  { label: 'My Bids', href: '/dashboard/creator/bids', icon: '⚑' },
  { label: 'Requests', href: '/dashboard/creator/requests', icon: '✉' },
  { label: 'My Collabs', href: '/dashboard/creator/collabs', icon: '⇄' },
  { label: 'Events', href: '/dashboard/creator/events', icon: '◈' },
  { label: 'Wallet', href: '/dashboard/creator/wallet', icon: '₿' },
  { label: 'Earnings', href: '/dashboard/creator/earnings', icon: '📈' },
  { label: 'Profile', href: '/dashboard/creator/profile', icon: '👤' },
]

const brandNav: NavItem[] = [
  { label: 'Home', href: '/dashboard/brand', icon: '⌂' },
  { label: 'Discover', href: '/dashboard/brand/discover', icon: '🔍' },
  { label: 'Campaigns', href: '/dashboard/brand/campaigns', icon: '⊞' },
  { label: 'Requests', href: '/dashboard/brand/requests', icon: '✉' },
  { label: 'Collabs', href: '/dashboard/brand/collabs', icon: '⇄' },
  { label: 'Events', href: '/dashboard/brand/events', icon: '◈' },
  { label: 'Credits', href: '/dashboard/brand/credits', icon: '₿' },
  { label: 'Saved Creators', href: '/dashboard/brand/saved-creators', icon: '☆' },
  { label: 'Analytics', href: '/dashboard/brand/analytics', icon: '📊' },
  { label: 'Profile', href: '/dashboard/brand/profile', icon: '👤' },
]

const sharedNav: NavItem[] = [
  { label: 'Notifications', href: '/dashboard/notifications', icon: '🔔' },
]

export default function Sidebar() {
  const pathname = usePathname()
  const { session } = useFrontendSession()
  const { collapsed, setCollapsed } = useSidebar()
  const { dark, toggle: toggleTheme } = useTheme()
  const role = session?.role || 'creator'
  const navItems = role === 'creator' ? creatorNav : brandNav
  const activeBg = role === 'brand' ? 'bg-pink' : 'bg-neon'
  const activeText = role === 'brand' ? 'text-white' : 'text-ink'

  return (
    <aside
      className={`hidden lg:flex flex-col bg-white dark:bg-[#14142a] border-r-2 border-ink dark:border-white/10 min-h-screen fixed left-0 top-0 z-40 transition-all duration-200 ${
        collapsed ? 'w-20' : 'w-64'
      }`}
    >
      <div className={`flex items-center h-16 border-b-2 border-ink dark:border-white/10 ${collapsed ? 'justify-center px-0' : 'gap-3 px-6'}`}>
        <span className="relative block h-10 w-10 overflow-hidden rounded-full border-2 border-ink dark:border-white/20 shrink-0">
          <Image
            src="/assets/logo.png"
            alt="BeyondC"
            fill
            className="object-cover"
          />
        </span>
        {!collapsed && <span className="font-space text-sm font-bold text-ink dark:text-white">BeyondC</span>}
      </div>

      <nav className="flex-1 overflow-y-auto py-4 px-3 space-y-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center font-nunito text-sm font-semibold border-2 transition-all ${
                collapsed ? 'justify-center px-0 py-3' : 'gap-3 px-4 py-3'
              } ${
                isActive
                  ? `${activeBg} border-ink ${activeText} dark:${activeBg} dark:border-ink dark:${activeText}`
                  : 'border-transparent text-ink/70 dark:text-white/60 hover:border-ink dark:hover:border-white/20 hover:text-ink dark:hover:text-white hover:bg-white dark:hover:bg-white/5'
              }`}
              title={collapsed ? item.label : undefined}
            >
              <span className="text-base w-5 text-center shrink-0">{item.icon}</span>
              {!collapsed && item.label}
            </Link>
          )
        })}
      </nav>

      <div className={`px-3 py-4 border-t-2 border-ink dark:border-white/10 space-y-1 ${collapsed ? 'flex flex-col items-center' : ''}`}>
        {sharedNav.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center font-nunito text-sm font-semibold border-2 transition-all ${
                collapsed ? 'justify-center px-0 py-3' : 'gap-3 px-4 py-3'
              } ${
                isActive
                  ? `${activeBg} border-ink ${activeText}`
                  : 'border-transparent text-ink/70 dark:text-white/60 hover:border-ink dark:hover:border-white/20 hover:text-ink dark:hover:text-white hover:bg-white dark:hover:bg-white/5'
              }`}
              title={collapsed ? item.label : undefined}
            >
              <span className="text-base w-5 text-center shrink-0">{item.icon}</span>
              {!collapsed && item.label}
            </Link>
          )
        })}

        {/* Dark mode toggle */}
        <button
          onClick={toggleTheme}
          className={`flex items-center w-full font-nunito text-sm font-semibold border-2 border-transparent text-ink/70 dark:text-white/60 hover:border-ink dark:hover:border-white/20 hover:text-ink dark:hover:text-white hover:bg-white dark:hover:bg-white/5 transition-all ${
            collapsed ? 'justify-center px-0 py-3' : 'gap-3 px-4 py-3'
          }`}
          title={dark ? 'Light mode' : 'Dark mode'}
        >
          <span className="text-base w-5 text-center shrink-0">{dark ? '☀️' : '🌙'}</span>
          {!collapsed && (dark ? 'Light Mode' : 'Dark Mode')}
        </button>

        {/* Collapse toggle */}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className={`flex items-center w-full font-nunito text-sm font-semibold border-2 border-transparent text-ink/70 dark:text-white/60 hover:border-ink dark:hover:border-white/20 hover:text-ink dark:hover:text-white hover:bg-white dark:hover:bg-white/5 transition-all ${
            collapsed ? 'justify-center px-0 py-3' : 'gap-3 px-4 py-3'
          }`}
          title={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          <span className="text-base w-5 text-center shrink-0">{collapsed ? '→' : '←'}</span>
          {!collapsed && 'Collapse'}
        </button>
      </div>
    </aside>
  )
}
