'use client'

import { FormEvent, useMemo, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import Navbar from '@/components/landing/Navbar'
import StepProgress from '@/components/join/StepProgress'
import { setFrontendSession } from '@/lib/frontend-session'

type BrandForm = {
  first_name: string
  full_name: string
  email: string
  phone: string
  password: string
  confirmPassword: string
  brand_name: string
  brand_category: string
  website: string
  gst_number: string
  description: string
  termsAccepted: boolean
}

const categoryOptions = [
  'D2C',
  'SaaS',
  'FMCG',
  'Fashion',
  'Beauty',
  'Food & Beverage',
  'Health',
  'Education',
  'Finance',
  'Travel',
  'Other',
]

const inputClass =
  'w-full bg-white border-2 border-ink px-4 py-3 font-nunito text-base text-ink outline-none transition focus:shadow-[4px_4px_0_#C8FF00]'

const labelClass = 'mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink'

type ErrorMap = Record<string, string>

function isEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
}

function isValidUrl(value: string) {
  try {
    const url = new URL(value)
    return url.protocol === 'http:' || url.protocol === 'https:'
  } catch {
    return false
  }
}

export default function BrandJoinPage() {
  const router = useRouter()
  const [step, setStep] = useState(1)
  const [isLoading, setIsLoading] = useState(false)
  const [errors, setErrors] = useState<ErrorMap>({})
  const [submitError, setSubmitError] = useState('')
  const [form, setForm] = useState<BrandForm>({
    first_name: '',
    full_name: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    brand_name: '',
    brand_category: '',
    website: '',
    gst_number: '',
    description: '',
    termsAccepted: false,
  })

  const summary = useMemo(
    () => [
      ['Role', 'Brand'],
      ['First Name', form.first_name],
      ['Full Name', form.full_name],
      ['Email', form.email],
      ['Phone', form.phone],
      ['Brand Name', form.brand_name],
      ['Brand Category', form.brand_category],
      ['Website', form.website || 'Not provided'],
      ['GST Number', form.gst_number || 'Not provided'],
      ['Description', form.description],
    ],
    [form]
  )

  const setField = (key: keyof BrandForm, value: string | boolean) => {
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

    if (!form.first_name.trim()) nextErrors.first_name = 'First name is required.'
    if (!form.full_name.trim()) nextErrors.full_name = 'Full name is required.'

    if (!form.email.trim()) nextErrors.email = 'Email is required.'
    else if (!isEmail(form.email)) nextErrors.email = 'Enter a valid email address.'

    if (!form.phone.trim()) nextErrors.phone = 'Phone is required.'
    else if (!/^[6-9]\d{9}$/.test(form.phone)) {
      nextErrors.phone = 'Enter a valid 10-digit Indian phone number.'
    }

    if (!form.password) nextErrors.password = 'Password is required.'
    else if (form.password.length < 8) nextErrors.password = 'Password must be at least 8 characters.'

    if (!form.confirmPassword) nextErrors.confirmPassword = 'Please confirm your password.'
    else if (form.confirmPassword !== form.password) nextErrors.confirmPassword = 'Passwords do not match.'

    setErrors(nextErrors)
    return Object.keys(nextErrors).length === 0
  }

  const validateStep2 = () => {
    const nextErrors: ErrorMap = {}

    if (!form.brand_name.trim()) nextErrors.brand_name = 'Brand name is required.'
    if (!form.brand_category) nextErrors.brand_category = 'Please select a category.'
    if (!form.description.trim()) nextErrors.description = 'Brief description is required.'

    if (form.website.trim() && !isValidUrl(form.website.trim())) {
      nextErrors.website = 'Enter a valid website URL (https://...).'
    }

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
          role: 'brand',
          first_name: form.first_name.trim(),
          full_name: form.full_name.trim(),
          phone: form.phone.trim(),
          brand_name: form.brand_name.trim(),
          brand_category: form.brand_category,
          website: form.website.trim() || null,
          gst_number: form.gst_number.trim() || null,
          description: form.description.trim(),
        }),
      })

      const payload = await response.json()
      if (!response.ok) {
        setSubmitError(payload.error || 'Signup failed. Please try again.')
        return
      }

      setFrontendSession({
        firstName: form.first_name.trim(),
        fullName: form.full_name.trim(),
        email: form.email.trim(),
        role: 'brand',
      })

      router.push('/join/success')
    } catch {
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
            Brand Signup
          </h1>

          <div className="mt-4 flex justify-center">
            <span className="rounded-full border-2 border-ink bg-pink px-4 py-1 font-space text-xs font-bold uppercase tracking-[0.08em] text-white">
              3-step onboarding
            </span>
          </div>

          <div className="mt-8 border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#FF2D78] sm:p-8">
            <StepProgress currentStep={step} />

            {submitError && (
              <div className="mt-6 border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
                {submitError}
              </div>
            )}

            <form onSubmit={handleSubmit} className="mt-8 space-y-6">
              {step === 1 && (
                <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
                  <div>
                    <label className={labelClass}>First Name</label>
                    <input
                      className={inputClass}
                      value={form.first_name}
                      onChange={(e) => setField('first_name', e.target.value)}
                      placeholder="Vaibhav"
                    />
                    {errors.first_name && <p className="mt-2 text-sm text-[#EF4444]">{errors.first_name}</p>}
                  </div>

                  <div>
                    <label className={labelClass}>Full Name</label>
                    <input
                      className={inputClass}
                      value={form.full_name}
                      onChange={(e) => setField('full_name', e.target.value)}
                      placeholder="Vaibhav Sharma"
                    />
                    {errors.full_name && <p className="mt-2 text-sm text-[#EF4444]">{errors.full_name}</p>}
                  </div>

                  <div>
                    <label className={labelClass}>Email</label>
                    <input
                      type="email"
                      className={inputClass}
                      value={form.email}
                      onChange={(e) => setField('email', e.target.value)}
                      placeholder="you@example.com"
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
                    <input
                      type="password"
                      className={inputClass}
                      value={form.password}
                      onChange={(e) => setField('password', e.target.value)}
                      placeholder="Minimum 8 characters"
                    />
                    {errors.password && <p className="mt-2 text-sm text-[#EF4444]">{errors.password}</p>}
                  </div>

                  <div>
                    <label className={labelClass}>Confirm Password</label>
                    <input
                      type="password"
                      className={inputClass}
                      value={form.confirmPassword}
                      onChange={(e) => setField('confirmPassword', e.target.value)}
                      placeholder="Re-enter your password"
                    />
                    {errors.confirmPassword && (
                      <p className="mt-2 text-sm text-[#EF4444]">{errors.confirmPassword}</p>
                    )}
                  </div>
                </div>
              )}

              {step === 2 && (
                <div className="space-y-5">
                  <div>
                    <label className={labelClass}>Brand Name</label>
                    <input
                      className={inputClass}
                      value={form.brand_name}
                      onChange={(e) => setField('brand_name', e.target.value)}
                      placeholder="Acme Foods"
                    />
                    {errors.brand_name && (
                      <p className="mt-2 text-sm text-[#EF4444]">{errors.brand_name}</p>
                    )}
                  </div>

                  <div>
                    <label className={labelClass}>Brand Category</label>
                    <select
                      className={inputClass}
                      value={form.brand_category}
                      onChange={(e) => setField('brand_category', e.target.value)}
                    >
                      <option value="">Select your category</option>
                      {categoryOptions.map((category) => (
                        <option key={category} value={category}>
                          {category}
                        </option>
                      ))}
                    </select>
                    {errors.brand_category && (
                      <p className="mt-2 text-sm text-[#EF4444]">{errors.brand_category}</p>
                    )}
                  </div>

                  <div>
                    <label className={labelClass}>Website (optional)</label>
                    <input
                      className={inputClass}
                      value={form.website}
                      onChange={(e) => setField('website', e.target.value)}
                      placeholder="https://yourbrand.com"
                    />
                    {errors.website && <p className="mt-2 text-sm text-[#EF4444]">{errors.website}</p>}
                  </div>

                  <div>
                    <label className={labelClass}>GST Number (optional)</label>
                    <input
                      className={inputClass}
                      value={form.gst_number}
                      onChange={(e) => setField('gst_number', e.target.value)}
                      placeholder="22AAAAA0000A1Z5"
                    />
                  </div>

                  <div>
                    <label className={labelClass}>Brief Description of Brand</label>
                    <textarea
                      className={`${inputClass} min-h-28`}
                      value={form.description}
                      onChange={(e) => setField('description', e.target.value)}
                      placeholder="Tell creators what your brand does and the audience you target."
                    />
                    {errors.description && (
                      <p className="mt-2 text-sm text-[#EF4444]">{errors.description}</p>
                    )}
                  </div>
                </div>
              )}

              {step === 3 && (
                <div className="space-y-6">
                  <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#9B5DE5]">
                    <h2 className="font-jakarta text-2xl font-extrabold text-ink">Review Your Details</h2>
                    <div className="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2">
                      {summary.map(([label, value]) => (
                        <div key={label} className="border-2 border-ink bg-white px-3 py-2">
                          <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink/70">
                            {label}
                          </p>
                          <p className="mt-1 font-nunito text-sm font-semibold text-ink">{value || '-'}</p>
                        </div>
                      ))}
                    </div>
                  </div>

                  <label className="flex items-start gap-3">
                    <input
                      type="checkbox"
                      checked={form.termsAccepted}
                      onChange={(e) => setField('termsAccepted', e.target.checked)}
                      className="mt-1 h-4 w-4 border-2 border-ink accent-pink"
                    />
                    <span className="font-nunito text-sm text-ink">
                      I agree to BeyondC&apos;s{' '}
                      <Link href="#" className="font-bold underline underline-offset-2">
                        Terms of Service
                      </Link>{' '}
                      and{' '}
                      <Link href="#" className="font-bold underline underline-offset-2">
                        Privacy Policy
                      </Link>
                      .
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
                    className="border-2 border-ink bg-white px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink shadow-[4px_4px_0_#0D0D0D]"
                  >
                    ← Back
                  </button>
                )}

                {step < 3 ? (
                  <button
                    type="button"
                    onClick={goNext}
                    className="ml-auto border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon shadow-[4px_4px_0_#C8FF00]"
                  >
                    Next →
                  </button>
                ) : (
                  <button
                    type="submit"
                    disabled={isLoading}
                    className="w-full border-2 border-ink bg-pink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-white shadow-[4px_4px_0_#0D0D0D] disabled:cursor-not-allowed disabled:opacity-70"
                  >
                    {isLoading ? (
                      <span className="inline-flex items-center gap-2">
                        <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                        Creating...
                      </span>
                    ) : (
                      'Create My Account →'
                    )}
                  </button>
                )}
              </div>
            </form>
          </div>
        </div>
      </section>
    </main>
  )
}
