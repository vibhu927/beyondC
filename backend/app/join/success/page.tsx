'use client'

import Link from 'next/link'
import { useEffect, useMemo, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { setFrontendSession } from '@/lib/frontend-session'

export default function JoinSuccessPage() {
  const router = useRouter()
  const supabase = useMemo(() => createClient(), [])

  const [firstName, setFirstName] = useState('there')
  const [role, setRole] = useState<'creator' | 'brand' | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const loadProfile = async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser()

      if (!user) {
        router.push('/join')
        return
      }

      const { data: profile } = await supabase
        .from('profiles')
        .select('first_name, full_name, role, email')
        .eq('id', user.id)
        .single()

      if (!profile) {
        router.push('/join')
        return
      }

      if (profile.first_name) setFirstName(profile.first_name)
      const userRole = profile.role as 'creator' | 'brand'
      if (userRole === 'creator' || userRole === 'brand') setRole(userRole)

      setFrontendSession({
        id: user.id,
        firstName: profile.first_name || user.email?.split('@')[0] || 'User',
        fullName: profile.full_name || '',
        email: user.email || '',
        role: userRole,
      })

      setLoading(false)

      if (userRole === 'creator') {
        router.push('/dashboard/creator')
      } else if (userRole === 'brand') {
        router.push('/dashboard/brand')
      }
    }

    void loadProfile()
  }, [router, supabase])

  const onLogout = async () => {
    await supabase.auth.signOut()
    router.push('/login')
  }

  const roleBadge = role === 'creator' ? 'Joined as Creator 🎨' : role === 'brand' ? 'Joined as Brand 🏢' : ''

  return (
    <main className="flex min-h-screen items-center justify-center bg-ink px-4 py-12">
      <div className="w-full max-w-3xl text-center">
        <div className="mx-auto flex w-max items-center gap-0 font-space text-4xl font-bold sm:text-5xl">
          <span className="text-white">Beyond</span>
          <span className="rounded-full bg-white px-3 py-1 text-neon border-2 border-white">C</span>
        </div>

        <p className="mt-8 text-[80px] leading-none">🎉</p>

        <h1 className="mt-6 font-jakarta text-4xl font-extrabold text-white sm:text-[40px]">
          {loading ? 'Loading...' : `You're in, ${firstName}! 🎉`}
        </h1>

        {!!roleBadge && (
          <p className="mx-auto mt-3 w-max border-2 border-white bg-neon px-3 py-1 font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
            {roleBadge}
          </p>
        )}

        <p className="mx-auto mt-4 max-w-xl font-nunito text-lg text-white/75">
          {loading ? '' : 'You are being redirected to your dashboard...'}
        </p>

        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
          <Link
            href={role === 'creator' ? '/dashboard/creator' : role === 'brand' ? '/dashboard/brand' : '/'}
            className="inline-flex w-full items-center justify-center gap-2 border-2 border-neon bg-ink px-6 py-4 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon shadow-[4px_4px_0_#C8FF00] sm:w-auto"
          >
            <span aria-hidden>⌂</span>
            Go to Dashboard
          </Link>
        </div>

        <button
          type="button"
          onClick={onLogout}
          className="mt-6 font-space text-xs font-bold uppercase tracking-[0.08em] text-white underline underline-offset-4"
        >
          Log out
        </button>
      </div>
    </main>
  )
}
