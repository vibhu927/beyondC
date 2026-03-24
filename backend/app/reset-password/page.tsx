'use client'

import { FormEvent, useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import Navbar from '@/components/landing/Navbar'
import { createClient } from '@/lib/supabase/client'
import { validators } from '@/lib/validators'

const inputClass =
  'w-full bg-white border-2 border-ink px-4 py-3 font-nunito text-base text-ink outline-none transition focus:shadow-[4px_4px_0_#C8FF00]'

export default function ResetPasswordPage() {
  const router = useRouter()
  const supabase = createClient()

  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)

  const onSubmit = async (event: FormEvent) => {
    event.preventDefault()

    const requiredPassword = validators.required(newPassword, 'New password')
    const invalidPassword = validators.password(newPassword)
    const requiredConfirm = validators.required(confirmPassword, 'Confirm password')
    const mismatch = validators.confirmPassword(confirmPassword, newPassword)

    if (requiredPassword || invalidPassword || requiredConfirm || mismatch) {
      setError(requiredPassword || invalidPassword || requiredConfirm || mismatch || '')
      return
    }

    setLoading(true)
    setError('')

    const { error: updateError } = await supabase.auth.updateUser({ password: newPassword })

    if (updateError) {
      setError('Could not update password. The link may have expired.')
      setLoading(false)
      return
    }

    setSuccess(true)
    setLoading(false)
    setTimeout(() => router.push('/login'), 2000)
  }

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      <section className="px-4 pb-20 pt-28 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-xl border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#9B5DE5] sm:p-8">
          <p className="text-center text-6xl leading-none">🔑</p>
          <h1 className="mt-4 text-center font-jakarta text-4xl font-extrabold text-ink">Set new password</h1>

          {!success ? (
            <>
              <p className="mt-2 text-center font-nunito text-base text-ink/75">
                Enter your new password below.
              </p>

              {error && (
                <div className="mt-5 border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
                  {error}
                </div>
              )}

              <form onSubmit={onSubmit} className="mt-6 space-y-5">
                <div>
                  <label className="mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
                    New Password
                  </label>
                  <div className="relative">
                    <input
                      type={showPassword ? 'text' : 'password'}
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      className={`${inputClass} pr-20`}
                      placeholder="Minimum 8 characters, at least one number"
                      disabled={loading}
                    />
                    <button
                      type="button"
                      className="absolute right-3 top-1/2 -translate-y-1/2 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink"
                      onClick={() => setShowPassword((prev) => !prev)}
                      disabled={loading}
                    >
                      {showPassword ? 'Hide' : 'Show'}
                    </button>
                  </div>
                </div>

                <div>
                  <label className="mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
                    Confirm Password
                  </label>
                  <div className="relative">
                    <input
                      type={showConfirmPassword ? 'text' : 'password'}
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      className={`${inputClass} pr-20`}
                      placeholder="Re-enter your new password"
                      disabled={loading}
                    />
                    <button
                      type="button"
                      className="absolute right-3 top-1/2 -translate-y-1/2 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink"
                      onClick={() => setShowConfirmPassword((prev) => !prev)}
                      disabled={loading}
                    >
                      {showConfirmPassword ? 'Hide' : 'Show'}
                    </button>
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full border-2 border-ink bg-neon px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink shadow-[4px_4px_0_#0D0D0D] disabled:cursor-not-allowed disabled:opacity-70"
                >
                  {loading ? (
                    <span className="inline-flex items-center gap-2">
                      <span className="h-4 w-4 animate-spin rounded-full border-2 border-ink border-t-transparent" />
                      Updating...
                    </span>
                  ) : (
                    'Update Password →'
                  )}
                </button>
              </form>
            </>
          ) : (
            <p className="mt-6 text-center font-nunito text-base font-bold text-ink">
              ✅ Password updated! Redirecting to login...
            </p>
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
