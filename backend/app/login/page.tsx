'use client'

import Link from 'next/link'
import { FormEvent, useState, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import Navbar from '@/components/landing/Navbar'
import { createClient } from '@/lib/supabase/client'
import { validators } from '@/lib/validators'
import { setFrontendSession } from '@/lib/frontend-session'

const inputClass =
  'w-full bg-white border-2 border-ink px-4 py-3 font-nunito text-base text-ink outline-none transition focus:shadow-[4px_4px_0_#C8FF00]'

const labelClass = 'mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [submitError, setSubmitError] = useState('')
  const [loading, setLoading] = useState(false)
  const [googleLoading, setGoogleLoading] = useState(false)
  const [showPassword, setShowPassword] = useState(false)

  const supabase = useMemo(() => createClient(), [])

  const validate = () => {
    const nextErrors: Record<string, string> = {}

    const emailRequired = validators.required(email, 'Email')
    nextErrors.email = emailRequired || validators.email(email) || ''

    nextErrors.password = validators.required(password, 'Password') || ''

    Object.keys(nextErrors).forEach((key) => {
      if (!nextErrors[key]) delete nextErrors[key]
    })

    setErrors(nextErrors)
    return Object.keys(nextErrors).length === 0
  }

  const onSubmit = async (event: FormEvent) => {
    event.preventDefault()
    setLoading(true)
    setSubmitError('')

    try {
      if (!validate()) {
        setLoading(false)
        return
      }

      const { data, error } = await supabase.auth.signInWithPassword({
        email: email.trim(),
        password,
      })

      if (error || !data?.user) {
        setSubmitError('Invalid email or password. Please try again.')
        setLoading(false)
        return
      }

      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('first_name, full_name, is_admin, role')
        .eq('id', data.user.id)
        .maybeSingle()

      if (profileError) {
        setSubmitError('Account found, but profile could not be loaded. Please contact support.')
        setLoading(false)
        return
      }

      if (profile?.is_admin) {
        setFrontendSession({
          id: data.user.id,
          firstName: profile.first_name || 'Admin',
          fullName: profile.full_name || '',
          email: data.user.email || '',
          role: 'brand',
        })
        router.push('/admin/dashboard')
        return
      }

      setFrontendSession({
        id: data.user.id,
        firstName: profile?.first_name || data.user.email?.split('@')[0] || 'User',
        fullName: profile?.full_name || '',
        email: data.user.email || '',
        role: (profile?.role as 'creator' | 'brand') || 'creator',
      })

      if (profile?.role === 'creator') {
        router.push('/dashboard/creator')
      } else if (profile?.role === 'brand') {
        router.push('/dashboard/brand')
      } else {
        router.push('/join/success')
      }
    } catch (err) {
      console.error('Login error:', err)
      setSubmitError('Something went wrong. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleGoogleLogin = async () => {
    setGoogleLoading(true)
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/api/auth/callback`,
        },
      })
      if (error) {
        setSubmitError('Google login failed. Please try again.')
      }
    } catch {
      setSubmitError('Something went wrong. Please try again.')
    } finally {
      setGoogleLoading(false)
    }
  }

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      <section className="px-4 pb-20 pt-28 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-xl border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#C8FF00] sm:p-8">
          <h1 className="font-jakarta text-4xl font-extrabold text-ink">
            Welcome <span className="text-neon">back.</span> 👋
          </h1>

          <p className="mt-2 font-nunito text-base text-ink/75">
            Log in to continue your journey on BeyondC.
          </p>

          {submitError && (
            <div className="mt-5 border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
              {submitError}
            </div>
          )}

          <form onSubmit={onSubmit} className="mt-6 space-y-5">
            <div>
              <label className={labelClass}>Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value)
                  setErrors((prev) => ({ ...prev, email: '' }))
                }}
                className={inputClass}
                placeholder="you@example.com"
              />
              {errors.email && <p className="mt-2 text-sm text-[#EF4444]">{errors.email}</p>}
            </div>

            <div>
              <label className={labelClass}>Password</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => {
                    setPassword(e.target.value)
                    setErrors((prev) => ({ ...prev, password: '' }))
                  }}
                  className={`${inputClass} pr-20`}
                  placeholder="Enter your password"
                />
                <button
                  type="button"
                  className="absolute right-3 top-1/2 -translate-y-1/2 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink"
                  onClick={(e) => {
                    e.preventDefault()
                    setShowPassword((prev) => !prev)
                  }}
                >
                  {showPassword ? 'Hide' : 'Show'}
                </button>
              </div>
              {errors.password && <p className="mt-2 text-sm text-[#EF4444]">{errors.password}</p>}
            </div>

            <div className="text-right">
              <Link href="/forgot-password" className="font-space text-xs font-bold uppercase tracking-[0.08em] text-pink">
                Forgot password?
              </Link>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon shadow-[4px_4px_0_#C8FF00] disabled:cursor-not-allowed disabled:opacity-70"
            >
              {loading ? (
                <span className="inline-flex items-center gap-2">
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-neon border-t-transparent" />
                  Logging in...
                </span>
              ) : (
                'Log In →'
              )}
            </button>
          </form>

          <div className="my-6 flex items-center gap-3">
            <div className="h-[2px] flex-1 bg-ink/20" />
            <span className="font-space text-xs font-bold uppercase tracking-[0.08em] text-ink/60">or</span>
            <div className="h-[2px] flex-1 bg-ink/20" />
          </div>

          <button
            type="button"
            disabled={googleLoading}
            onClick={handleGoogleLogin}
            className="w-full border-2 border-ink bg-white px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink shadow-[4px_4px_0_#0D0D0D] disabled:cursor-not-allowed disabled:opacity-70"
          >
            {googleLoading ? (
              <span className="inline-flex items-center gap-2">
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-ink border-t-transparent" />
                Redirecting...
              </span>
            ) : (
              'Continue with Google'
            )}
          </button>

          <p className="mt-6 text-center font-nunito text-base text-ink/80">
            Don&apos;t have an account?{' '}
            <Link href="/join" className="font-bold text-neon underline underline-offset-4">
              Sign up
            </Link>
          </p>
        </div>
      </section>
    </main>
  )
}
