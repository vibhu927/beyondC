'use client'

import { FormEvent, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import Navbar from '@/components/landing/Navbar'
import StepProgress from '@/components/join/StepProgress'
import { createClient } from '@/lib/supabase/client'
import { validators } from '@/lib/validators'

type AgencyForm = {
  agency_name: string
  contact_name: string
  email: string
  phone: string
  website: string
  password: string
  confirmPassword: string
  termsAccepted: boolean
}

const inputClass =
  'w-full bg-white border-2 border-ink px-4 py-3 font-nunito text-base text-ink outline-none transition focus:shadow-[4px_4px_0_#C8FF00]'

const labelClass = 'mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink'

type ErrorMap = Record<string, string>

export default function AgencyJoinPage() {
  const router = useRouter()
  const [step, setStep] = useState(1)
  const [isLoading, setIsLoading] = useState(false)
  const [errors, setErrors] = useState<ErrorMap>({})
  const [submitError, setSubmitError] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [form, setForm] = useState<AgencyForm>({
    agency_name: '',
    contact_name: '',
    email: '',
    phone: '',
    website: '',
    password: '',
    confirmPassword: '',
    termsAccepted: false,
  })

  const setField = (key: keyof AgencyForm, value: string | boolean) => {
    setForm((prev) => ({ ...prev, [key]: value }))
    setErrors((prev) => {
      const next = { ...prev }
      delete next[key]
      return next
    })
    setSubmitError('')
  }

  const validateStep1 = () => {
    const nextErrors: ErrorMap = {}

    nextErrors.agency_name = validators.required(form.agency_name, 'Agency name') || ''
    nextErrors.contact_name = validators.required(form.contact_name, 'Contact name') || ''

    const emailRequired = validators.required(form.email, 'Email')
    nextErrors.email = emailRequired || validators.email(form.email) || ''

    const phoneRequired = validators.required(form.phone, 'Phone')
    nextErrors.phone = phoneRequired || validators.phone(form.phone) || ''

    const passwordRequired = validators.required(form.password, 'Password')
    nextErrors.password = passwordRequired || validators.password(form.password) || ''

    const confirmRequired = validators.required(form.confirmPassword, 'Confirm password')
    nextErrors.confirmPassword =
      confirmRequired || validators.confirmPassword(form.confirmPassword, form.password) || ''

    Object.keys(nextErrors).forEach((key) => {
      if (!nextErrors[key]) delete nextErrors[key]
    })

    setErrors(nextErrors)
    return Object.keys(nextErrors).length === 0
  }

  const validateStep2 = () => {
    const nextErrors: ErrorMap = {}
    if (form.website && !/^https?:\/\//.test(form.website)) nextErrors.website = 'Include https:// or http:// in website URL.'
    setErrors(nextErrors)
    return Object.keys(nextErrors).length === 0
  }

  const validateStep3 = () => {
    const nextErrors: ErrorMap = {}
    if (!form.termsAccepted) nextErrors.termsAccepted = 'Please accept the terms to continue.'
    setErrors(nextErrors)
    return Object.keys(nextErrors).length === 0
  }

  const goNext = () => {
    if (isLoading) return
    if (step === 1 && !validateStep1()) return
    if (step === 2 && !validateStep2()) return
    setStep((prev) => Math.min(prev + 1, 3))
  }

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault()
    if (!validateStep3()) return

    setIsLoading(true)
    setSubmitError('')

    try {
      const response = await fetch('/api/auth/web-signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: form.email.trim(),
          password: form.password,
          role: 'agency',
          agency_name: form.agency_name.trim(),
          contact_name: form.contact_name.trim(),
          phone: form.phone.trim(),
          website: form.website.trim() || null,
        }),
      })

      const payload = await response.json()
      if (!response.ok) {
        const apiError = String(payload?.error || '')
        if (apiError.toLowerCase().includes('already registered')) {
          setSubmitError('This email is already registered. Log in instead.')
        } else {
          setSubmitError('Something went wrong. Please try again.')
        }
        return
      }

      const supabase = createClient()
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: form.email.trim(),
        password: form.password,
      })

      if (signInError) {
        setSubmitError('Account created, but auto-login failed. Please log in manually.')
        return
      }

      router.push('/join/success')
    } catch (error) {
      setSubmitError('Something went wrong. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      <section className="px-4 pb-20 pt-28 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl">
          <h1 className="text-center font-jakarta text-4xl font-extrabold text-ink md:text-5xl">
            Agency Signup
          </h1>

          <div className="mt-4 flex justify-center">
            <span className="rounded-full border-2 border-ink bg-purple px-4 py-1 font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
              3-step onboarding
            </span>
          </div>

          <div className="mt-8 border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#9B5DE5] sm:p-8">
            <StepProgress currentStep={step} />

            <form onSubmit={handleSubmit} className="mt-8 space-y-6">
              <fieldset disabled={isLoading} className="space-y-6">
                {step === 1 && (
                  <div className="space-y-4">
                    <div>
                      <label className={labelClass}>Agency Name</label>
                      <input
                        className={inputClass}
                        value={form.agency_name}
                        onChange={(e) => setField('agency_name', e.target.value)}
                        placeholder="Your agency name"
                      />
                      {errors.agency_name && <p className="mt-2 text-sm text-[#EF4444]">{errors.agency_name}</p>}
                    </div>

                    <div>
                      <label className={labelClass}>Primary Contact</label>
                      <input
                        className={inputClass}
                        value={form.contact_name}
                        onChange={(e) => setField('contact_name', e.target.value)}
                        placeholder="Full name"
                      />
                      {errors.contact_name && <p className="mt-2 text-sm text-[#EF4444]">{errors.contact_name}</p>}
                    </div>

                    <div>
                      <label className={labelClass}>Email</label>
                      <input
                        type="email"
                        className={inputClass}
                        value={form.email}
                        onChange={(e) => setField('email', e.target.value)}
                        placeholder="agency@example.com"
                      />
                      {errors.email && <p className="mt-2 text-sm text-[#EF4444]">{errors.email}</p>}
                    </div>

                    <div>
                      <label className={labelClass}>Phone</label>
                      <input
                        className={inputClass}
                        value={form.phone}
                        onChange={(e) => setField('phone', e.target.value.replace(/\D/g, '').slice(0, 10))}
                        placeholder="9876543210"
                      />
                      {errors.phone && <p className="mt-2 text-sm text-[#EF4444]">{errors.phone}</p>}
                    </div>

                    <div>
                      <label className={labelClass}>Password</label>
                      <div className="relative">
                        <input
                          type={showPassword ? 'text' : 'password'}
                          className={`${inputClass} pr-20`}
                          value={form.password}
                          onChange={(e) => setField('password', e.target.value)}
                          placeholder="Minimum 8 characters"
                        />
                        <button
                          type="button"
                          className="absolute right-3 top-1/2 -translate-y-1/2 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink"
                          onClick={() => setShowPassword((prev) => !prev)}
                        >
                          {showPassword ? 'Hide' : 'Show'}
                        </button>
                      </div>
                      {errors.password && <p className="mt-2 text-sm text-[#EF4444]">{errors.password}</p>}
                    </div>

                    <div>
                      <label className={labelClass}>Confirm Password</label>
                      <div className="relative">
                        <input
                          type={showConfirmPassword ? 'text' : 'password'}
                          className={`${inputClass} pr-20`}
                          value={form.confirmPassword}
                          onChange={(e) => setField('confirmPassword', e.target.value)}
                          placeholder="Re-enter your password"
                        />
                        <button
                          type="button"
                          className="absolute right-3 top-1/2 -translate-y-1/2 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink"
                          onClick={() => setShowConfirmPassword((prev) => !prev)}
                        >
                          {showConfirmPassword ? 'Hide' : 'Show'}
                        </button>
                      </div>
                      {errors.confirmPassword && (
                        <p className="mt-2 text-sm text-[#EF4444]">{errors.confirmPassword}</p>
                      )}
                    </div>
                  </div>
                )}

                {step === 2 && (
                  <div className="space-y-4">
                    <div>
                      <label className={labelClass}>Website</label>
                      <input
                        className={inputClass}
                        value={form.website}
                        onChange={(e) => setField('website', e.target.value)}
                        placeholder="https://youragency.com"
                      />
                      {errors.website && <p className="mt-2 text-sm text-[#EF4444]">{errors.website}</p>}
                    </div>

                    <div>
                      <p className="font-nunito text-sm text-ink/80">Tell us briefly about your agency and number of creators you manage in your profile after signup.</p>
                    </div>
                  </div>
                )}

                {step === 3 && (
                  <div className="space-y-6">
                    <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#3D5BFF]">
                      <h2 className="font-jakarta text-2xl font-extrabold text-ink">Review Your Details</h2>
                      <div className="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2">
                        <div className="border-2 border-ink bg-white px-3 py-2">
                          <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink/70">Agency</p>
                          <p className="mt-1 font-nunito text-sm font-semibold text-ink">{form.agency_name || '-'}</p>
                        </div>
                        <div className="border-2 border-ink bg-white px-3 py-2">
                          <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink/70">Contact</p>
                          <p className="mt-1 font-nunito text-sm font-semibold text-ink">{form.contact_name || '-'}</p>
                        </div>
                      </div>
                    </div>

                    <label className="flex items-start gap-3">
                      <input
                        type="checkbox"
                        checked={form.termsAccepted}
                        onChange={(e) => setField('termsAccepted', e.target.checked)}
                        className="mt-1 h-4 w-4 border-2 border-ink accent-purple"
                      />
                      <span className="font-nunito text-sm text-ink">
                        I agree to BeyondC&apos;s{' '}
                        <Link href="#" className="font-bold underline underline-offset-2">Terms of Service</Link>{' '}
                        and{' '}
                        <Link href="#" className="font-bold underline underline-offset-2">Privacy Policy</Link>.
                      </span>
                    </label>
                    {errors.termsAccepted && (
                      <p className="text-sm text-[#EF4444]">{errors.termsAccepted}</p>
                    )}
                  </div>
                )}

                <div className={`flex gap-3 ${step === 3 ? 'flex-col' : 'justify-between'}`}>
                  {step > 1 && (
                    <button
                      type="button"
                      onClick={() => setStep((prev) => Math.max(prev - 1, 1))}
                      disabled={isLoading}
                      className="border-2 border-ink bg-white px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink shadow-[4px_4px_0_#0D0D0D]"
                    >
                      ← Back
                    </button>
                  )}

                  {step < 3 ? (
                    <button
                      type="button"
                      onClick={goNext}
                      disabled={isLoading}
                      className="ml-auto border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-purple shadow-[4px_4px_0_#9B5DE5]"
                    >
                      Next →
                    </button>
                  ) : (
                    <button
                      type="submit"
                      disabled={isLoading}
                      className="w-full border-2 border-ink bg-purple px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink shadow-[4px_4px_0_#0D0D0D] disabled:cursor-not-allowed disabled:opacity-70"
                    >
                      {isLoading ? (
                        <span className="inline-flex items-center gap-2">
                          <span className="h-4 w-4 animate-spin rounded-full border-2 border-ink border-t-transparent" />
                          Creating...
                        </span>
                      ) : (
                        'Create My Account →'
                      )}
                    </button>
                  )}
                </div>

                {submitError && step === 3 && (
                  <p className="text-sm text-[#EF4444]">{submitError}</p>
                )}
              </fieldset>
            </form>
          </div>
        </div>
      </section>
    </main>
  )
}
