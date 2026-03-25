'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { useEffect, useMemo, useState } from 'react'
import { Menu, X, LogOut, Search, Moon, Sun } from 'lucide-react'
import { PermissionMap } from '@/lib/admin/constants'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { useAdminPermissions, canAccess } from '@/components/admin/permissions-provider'

type NavItem = {
  label: string
  href: string
  page: keyof PermissionMap
  icon: string
  superAdminOnly?: boolean
}

const NAV_ITEMS: NavItem[] = [
  { label: 'Dashboard', href: '/admin/dashboard', page: 'dashboard', icon: '📊' },
  { label: 'Users', href: '/admin/users', page: 'users', icon: '👥' },
  { label: 'Campaigns', href: '/admin/campaigns', page: 'campaigns', icon: '📢' },
  { label: 'Collabs', href: '/admin/collabs', page: 'collabs', icon: '🤝' },
  { label: 'Events', href: '/admin/events', page: 'events', icon: '🎟️' },
  { label: 'Payments', href: '/admin/payments', page: 'payments', icon: '💳' },
  { label: 'Wallets', href: '/admin/wallets', page: 'payments', icon: '🪙' },
  { label: 'Disputes', href: '/admin/disputes', page: 'disputes', icon: '⚠️' },
  { label: 'Notifications', href: '/admin/notifications', page: 'notifications', icon: '🔔' },
  { label: 'Analytics', href: '/admin/analytics', page: 'analytics', icon: '📈' },
  { label: 'Settings', href: '/admin/settings', page: 'settings', icon: '⚙️', superAdminOnly: true },
  { label: 'Staff Management', href: '/admin/staff', page: 'staff', icon: '👔', superAdminOnly: true },
]

export function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const router = useRouter()
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [query, setQuery] = useState('')
  const [isDark, setIsDark] = useState(false)
  const { permissions, identity } = useAdminPermissions()

  useEffect(() => {
    const saved = window.localStorage.getItem('beyondc_admin_theme')
    if (saved === 'dark') {
      setIsDark(true)
      return
    }

    if (!saved && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      setIsDark(true)
    }
  }, [])

  useEffect(() => {
    window.localStorage.setItem('beyondc_admin_theme', isDark ? 'dark' : 'light')
  }, [isDark])

  const navItems = useMemo(() => {
    return NAV_ITEMS.filter((item) => {
      if (item.superAdminOnly && !identity.isSuperAdmin) {
        return false
      }

      return canAccess(permissions, identity.isSuperAdmin, item.page, 'can_view')
    })
  }, [identity.isSuperAdmin, permissions])

  const pageTitle = navItems.find((item) => pathname.startsWith(item.href))?.label ?? 'Admin Panel'

  const logout = async () => {
    await fetch('/api/auth/logout', { method: 'POST' })
    router.push('/admin/login')
  }

  return (
    <div
      className={cn(
        'min-h-screen',
        isDark ? 'dark bg-zinc-950 text-zinc-100' : 'bg-zinc-50 text-zinc-900'
      )}
    >
      <div className="lg:flex">
        <aside
          className={cn(
            'fixed inset-y-0 left-0 z-50 w-60 border-r border-zinc-200 bg-white p-4 transition-transform lg:translate-x-0 dark:border-zinc-800 dark:bg-zinc-900',
            drawerOpen ? 'translate-x-0' : '-translate-x-full'
          )}
        >
          <div className="flex items-center justify-between lg:justify-start">
            <div>
              <p className="text-xl font-black text-lime-500">BeyondC</p>
              <p className="text-xs uppercase tracking-widest text-zinc-500 dark:text-zinc-400">Admin Panel</p>
            </div>
            <button className="lg:hidden dark:text-zinc-100" onClick={() => setDrawerOpen(false)}>
              <X className="h-5 w-5" />
            </button>
          </div>

          <nav className="mt-8 space-y-1">
            {navItems.map((item) => {
              const active = pathname.startsWith(item.href)
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    'flex items-center gap-2 rounded-r-md border-l-4 px-3 py-2 text-sm font-medium transition-colors',
                    active
                      ? 'border-lime-400 bg-lime-50 text-lime-700 dark:bg-lime-500/10 dark:text-lime-300'
                      : 'border-transparent text-zinc-600 hover:bg-zinc-100 dark:text-zinc-300 dark:hover:bg-zinc-800'
                  )}
                  onClick={() => setDrawerOpen(false)}
                >
                  <span>{item.icon}</span>
                  <span>{item.label}</span>
                </Link>
              )
            })}
          </nav>

          <div className="absolute bottom-4 left-4 right-4 rounded-md border border-zinc-200 p-3 dark:border-zinc-700 dark:bg-zinc-900">
            <p className="text-sm font-semibold">{identity.name}</p>
            <p className="text-xs text-zinc-500 dark:text-zinc-400">{identity.designation}</p>
            <Button variant="outline" size="sm" className="mt-3 w-full" onClick={logout}>
              <LogOut className="mr-2 h-4 w-4" />
              Logout
            </Button>
          </div>
        </aside>

        {drawerOpen && (
          <button
            className="fixed inset-0 z-40 bg-black/30 lg:hidden"
            onClick={() => setDrawerOpen(false)}
            aria-label="Close menu"
          />
        )}

        <main className="flex-1 lg:pl-60">
          <header className="sticky top-0 z-30 border-b border-zinc-200 bg-white/95 px-4 py-3 backdrop-blur lg:px-6 dark:border-zinc-800 dark:bg-zinc-900/95">
            <div className="flex items-center gap-3">
              <button className="lg:hidden dark:text-zinc-100" onClick={() => setDrawerOpen(true)}>
                <Menu className="h-5 w-5" />
              </button>

              <div className="min-w-0 flex-1">
                <p className="text-xs uppercase tracking-widest text-zinc-500 dark:text-zinc-400">BeyondC Admin</p>
                <h1 className="truncate text-lg font-semibold">{pageTitle}</h1>
              </div>

              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() => setIsDark((prev) => !prev)}
                className="hidden md:inline-flex"
              >
                {isDark ? <Sun className="mr-2 h-4 w-4" /> : <Moon className="mr-2 h-4 w-4" />}
                {isDark ? 'Light' : 'Dark'}
              </Button>

              <form
                className="hidden items-center gap-2 rounded-md border border-zinc-200 px-2 py-1 md:flex dark:border-zinc-700 dark:bg-zinc-900"
                onSubmit={(event) => {
                  event.preventDefault()
                  if (!query.trim()) return
                  router.push(`/admin/users?q=${encodeURIComponent(query)}`)
                }}
              >
                <Search className="h-4 w-4 text-zinc-500 dark:text-zinc-400" />
                <Input
                  className="h-8 w-56 border-none p-0 focus-visible:ring-0 dark:bg-transparent"
                  placeholder="Search users/campaigns/collabs"
                  value={query}
                  onChange={(event) => setQuery(event.target.value)}
                />
              </form>

              <div className="rounded-md border border-zinc-200 px-3 py-1.5 text-sm dark:border-zinc-700 dark:bg-zinc-900">
                <p className="font-semibold leading-tight">{identity.name}</p>
                <p className="text-xs text-zinc-500 leading-tight dark:text-zinc-400">{identity.email}</p>
              </div>
            </div>
          </header>

          <div className="p-4 lg:p-6">{children}</div>
        </main>
      </div>
    </div>
  )
}
