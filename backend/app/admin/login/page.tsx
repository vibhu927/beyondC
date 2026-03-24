'use client'

import { FormEvent, useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

export default function AdminLoginPage() {
  const router = useRouter()
  const supabase = createClient()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [isDark, setIsDark] = useState(true)

  useEffect(() => {
    const saved = window.localStorage.getItem('beyondc_admin_theme')
    if (saved === 'dark') {
      setIsDark(true)
      return
    }

    if (saved === 'light') {
      setIsDark(false)
      return
    }

    setIsDark(window.matchMedia('(prefers-color-scheme: dark)').matches)
  }, [])

  const onSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setError(null)
    setLoading(true)

    const { data, error: signInError } = await supabase.auth.signInWithPassword({ email, password })

    if (signInError || !data.user) {
      setError(signInError?.message || 'Unable to login')
      setLoading(false)
      return
    }

    const profileResponse = await fetch('/api/auth/me')
    const profileJson = await profileResponse.json()

    if (!profileResponse.ok || !profileJson?.profile?.is_admin) {
      await supabase.auth.signOut()
      setError('Access denied. This account does not have admin privileges.')
      setLoading(false)
      return
    }

    router.push('/admin/dashboard')
    router.refresh()
  }

  return (
    <div className={isDark ? 'dark' : undefined}>
      <div className="flex min-h-screen items-center justify-center bg-zinc-100 p-4 dark:bg-zinc-950">
      <Card className="w-full max-w-md">
        <CardHeader>
          <p className="text-2xl font-black text-lime-500">BeyondC</p>
          <p className="text-xs uppercase tracking-widest text-zinc-500 dark:text-zinc-400">Admin Panel</p>
          <CardTitle className="pt-3">Sign In</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="space-y-4" onSubmit={onSubmit}>
            <div>
              <label className="mb-1 block text-sm font-medium dark:text-zinc-200">Email</label>
              <Input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium dark:text-zinc-200">Password</label>
              <Input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
            </div>
            {error && <p className="text-sm text-red-600">{error}</p>}
            <Button type="submit" variant="neon" className="w-full" disabled={loading}>
              {loading ? 'Signing in...' : 'Login to Admin'}
            </Button>
          </form>
        </CardContent>
      </Card>
      </div>
    </div>
  )
}
