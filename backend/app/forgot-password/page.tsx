'use client'

import Link from 'next/link'
import { FormEvent, useState } from 'react'
import Navbar from '@/components/landing/Navbar'
import { validators } from '@/lib/validators'

const inputClass =
  'w-full bg-white border-2 border-ink px-4 py-3 font-nunito text-base text-ink outline-none transition focus:shadow-[4px_4px_0_#C8FF00]'

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [sent, setSent] = useState(false)

  const onSubmit = async (event: FormEvent) => {
    event.preventDefault()
    const emailRequired = validators.required(email, 'Email')
    const emailInvalid = validators.email(email)

    if (emailRequired || emailInvalid) {
      setError(emailRequired || emailInvalid || '')
      return
    }

    setLoading(true)
    setError('')

    try {
      const response = await fetch('/api/auth/forgot-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim().toLowerCase() }),
      })

      if (!response.ok) {
        setError('Could not send reset email. Please check the address and try again.')
        return
      }

      setSent(true)
    } catch {
      setError('Could not send reset link. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      <section className="px-4 pb-20 pt-28 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-xl border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#9B5DE5] sm:p-8">
          {!sent ? (
            <>
              <p className="text-center text-6xl leading-none">🔑</p>
              <h1 className="mt-4 text-center font-jakarta text-4xl font-extrabold text-ink">
                Reset your password
              </h1>
              <p className="mt-2 text-center font-nunito text-base text-ink/75">
                Enter your email and we&apos;ll send a reset link.
              </p>

              {error && (
                <div className="mt-5 border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
                  {error}
                </div>
              )}

              <form onSubmit={onSubmit} className="mt-6 space-y-5">
                <div>
                  <label className="mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
                    Email
                  </label>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className={inputClass}
                    placeholder="you@example.com"
                  />
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon shadow-[4px_4px_0_#C8FF00] disabled:cursor-not-allowed disabled:opacity-70"
                >
                  {loading ? (
                    <span className="inline-flex items-center gap-2">
                      <span className="h-4 w-4 animate-spin rounded-full border-2 border-neon border-t-transparent" />
                      Sending...
                    </span>
                  ) : (
                    'Send Reset Link →'
                  )}
                </button>
              </form>
            </>
          ) : (
            <>
              <p className="text-center text-6xl leading-none">✅</p>
              <h2 className="mt-4 text-center font-jakarta text-3xl font-extrabold text-ink">Check your inbox!</h2>
              <p className="mt-2 text-center font-nunito text-base text-ink/75">
                We just sent a reset link to {email}. Use it to create a new password.
              </p>
            </>
          )}

          <p className="mt-6 text-center font-nunito text-base text-ink/80">
            <Link href="/login" className="font-bold text-pink underline underline-offset-4">
              Back to login
            </Link>
          </p>
        </div>
      </section>
    </main>
  )
}
