'use client'

import { useQuery, useMutation } from '@tanstack/react-query'
import { createClient } from '@/lib/supabase/client'
import { useState, useEffect, useCallback } from 'react'
import Link from 'next/link'

type Step = 'choose' | 'bio_username' | 'bio_code' | 'bio_verifying' | 'success' | 'error'
type ConnectMethod = 'oauth' | 'bio' | null

function InstagramIcon({ className = 'w-6 h-6' }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none">
      <rect x="2" y="2" width="20" height="20" rx="5" stroke="currentColor" strokeWidth="2" />
      <circle cx="12" cy="12" r="5" stroke="currentColor" strokeWidth="2" />
      <circle cx="17.5" cy="6.5" r="1.5" fill="currentColor" />
    </svg>
  )
}

export default function InstagramConnectPage() {
  const supabase = createClient()
  const [step, setStep] = useState<Step>('choose')
  const [method, setMethod] = useState<ConnectMethod>(null)
  const [errorMsg, setErrorMsg] = useState('')
  const [successUsername, setSuccessUsername] = useState('')
  const [bioUsername, setBioUsername] = useState('')
  const [bioCode, setBioCode] = useState('')
  const [copied, setCopied] = useState(false)
  const [userRole, setUserRole] = useState<string | null>(null)

  const { data: userData } = useQuery({
    queryKey: ['auth', 'user'],
    queryFn: async () => {
      const { data: { user } } = await supabase.auth.getUser()
      return user
    },
  })

  useEffect(() => {
    if (!userData) return
    supabase
      .from('profiles')
      .select('role')
      .eq('id', userData.id)
      .maybeSingle()
      .then(({ data }) => setUserRole(data?.role || null))
  }, [userData, supabase])

  const profileRedirect = userRole === 'brand' ? '/dashboard/brand/profile' : '/dashboard/creator/profile'

  useEffect(() => {
    const params = new URLSearchParams(window.location.search)
    const status = params.get('status')
    const username = params.get('username')
    if (status === 'success') {
      setSuccessUsername(username || '')
      setStep('success')
    } else if (status === 'error') {
      const errorParam = params.get('error')
      setErrorMsg(errorParam === 'already_linked'
        ? 'This Instagram account is already linked to another Beyond C account.'
        : 'Instagram connection failed. Please try again.')
      setStep('error')
    }
  }, [])

  const redirectToOAuth = async () => {
    try {
      const res = await fetch('/api/auth/instagram/connect?platform=web')
      const data = await res.json()
      if (data.url) {
        window.location.href = data.url
      } else {
        setErrorMsg(data.error || 'Could not start Instagram connection')
        setStep('error')
      }
    } catch {
      setErrorMsg('Network error. Please try again.')
      setStep('error')
    }
  }

  const generateCodeMutation = useMutation({
    mutationFn: async () => {
      const res = await fetch('/api/instagram/generate-code', { method: 'POST' })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to generate code')
      return data.code as string
    },
    onSuccess: (code) => {
      setBioCode(code)
      setStep('bio_code')
    },
    onError: (e: Error) => {
      setErrorMsg(e.message)
      setStep('error')
    },
  })

  const verifyBioMutation = useMutation({
    mutationFn: async () => {
      const res = await fetch('/api/instagram/verify-bio', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: bioUsername }),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Verification failed')
      return data
    },
    onSuccess: (data: { username?: string }) => {
      setSuccessUsername(data.username || bioUsername)
      setStep('success')
    },
    onError: (e: Error) => {
      setErrorMsg(e.message)
      setStep('error')
    },
  })

  const copyCode = useCallback(() => {
    navigator.clipboard.writeText(bioCode)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }, [bioCode])

  const goBack = () => {
    setStep('choose')
    setMethod(null)
    setErrorMsg('')
    setBioUsername('')
    setBioCode('')
  }

  return (
    <main className="min-h-screen bg-white px-4 py-12">
      <div className="mx-auto max-w-lg space-y-6">
        {/* Header */}
        <div className="text-center space-y-2">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-xl border-2 border-ink bg-white shadow-[3px_3px_0_#0D0D0D]"
            style={{ background: 'linear-gradient(135deg, #833AB4, #C13584, #E1306C, #FD1D1D, #F77737, #FCAF45)' }}>
            <InstagramIcon className="w-7 h-7 text-white" />
          </div>
          <h1 className="font-jakarta text-3xl font-extrabold text-ink">Connect Instagram</h1>
          <p className="font-nunito text-sm text-muted">Verify your Instagram to build trust with brands and creators.</p>
        </div>

        {/* Success State */}
        {step === 'success' && (
          <div className="border-2 border-ink bg-white p-8 shadow-[6px_6px_0_#C8FF00] text-center space-y-4">
            <div className="text-5xl">✅</div>
            <h2 className="font-jakarta text-xl font-bold text-ink">Instagram Connected!</h2>
            <p className="font-nunito text-sm text-muted">
              {successUsername ? `@${successUsername} has been verified.` : 'Your Instagram has been verified.'}
              Stats are being fetched in the background.
            </p>
            <div className="flex flex-col gap-2 pt-2">
              <Link
                href={profileRedirect}
                className="inline-flex items-center justify-center border-2 border-ink bg-neon px-6 py-3 font-space text-xs font-bold uppercase text-ink shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#0D0D0D] hover:-translate-y-0.5 transition-all"
              >
                Go to Profile
              </Link>
              <Link href={profileRedirect} className="font-nunito text-xs text-muted hover:text-ink text-center">
                Skip, I&apos;ll check later
              </Link>
            </div>
          </div>
        )}

        {/* Error State */}
        {step === 'error' && (
          <div className="border-2 border-[#EF4444] bg-[#FEE2E2] p-6 space-y-4">
            <div className="flex items-center gap-2">
              <span className="text-xl">❌</span>
              <h2 className="font-jakarta text-lg font-bold text-[#B91C1C]">Connection Failed</h2>
            </div>
            <p className="font-nunito text-sm text-[#B91C1C]">{errorMsg}</p>
            <div className="flex gap-2">
              <button
                onClick={goBack}
                className="border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[2px_2px_0_#0D0D0D] transition-all"
              >
                Try Again
              </button>
              <Link
                href={profileRedirect}
                className="border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon"
              >
                Back to Profile
              </Link>
            </div>
          </div>
        )}

        {/* Bio Verifying State */}
        {step === 'bio_verifying' && (
          <div className="border-2 border-ink bg-white p-8 shadow-[6px_6px_0_#C8FF00] text-center space-y-4">
            <div className="animate-spin w-10 h-10 border-4 border-ink border-t-transparent rounded-full mx-auto" />
            <h2 className="font-jakarta text-lg font-bold text-ink">Verifying your bio...</h2>
            <p className="font-nunito text-sm text-muted">Checking if the code is in your Instagram bio.</p>
          </div>
        )}

        {/* Choose Method */}
        {step === 'choose' && (
          <div className="space-y-3">
            <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted text-center">Choose a verification method</p>

            {/* OAuth Option */}
            <button
              onClick={() => {
                setMethod('oauth')
                redirectToOAuth()
              }}
              className="w-full border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#0D0D0D] hover:shadow-[6px_6px_0_#C8FF00] hover:-translate-y-0.5 transition-all text-left group"
            >
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl flex items-center justify-center shrink-0"
                  style={{ background: 'linear-gradient(135deg, #833AB4, #C13584, #E1306C)' }}>
                  <InstagramIcon className="w-6 h-6 text-white" />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-jakarta text-base font-bold text-ink">Instagram Login</h3>
                  <p className="font-nunito text-xs text-muted mt-0.5">
                    Connect securely via Instagram OAuth. Fastest method.
                  </p>
                </div>
                <span className="font-space text-[10px] font-bold text-pink uppercase shrink-0">→</span>
              </div>
            </button>

            {/* Bio Verification Option */}
            <button
              onClick={() => {
                setMethod('bio')
                setStep('bio_username')
              }}
              className="w-full border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#0D0D0D] hover:shadow-[6px_6px_0_#C8FF00] hover:-translate-y-0.5 transition-all text-left group"
            >
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl border-2 border-ink bg-neon flex items-center justify-center shrink-0">
                  <span className="text-xl">📝</span>
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-jakarta text-base font-bold text-ink">Bio Verification</h3>
                  <p className="font-nunito text-xs text-muted mt-0.5">
                    Add a code to your bio. Works if OAuth isn&apos;t available.
                  </p>
                </div>
                <span className="font-space text-[10px] font-bold text-pink uppercase shrink-0">→</span>
              </div>
            </button>

            <div className="text-center pt-2">
              <Link href={profileRedirect} className="font-nunito text-xs text-muted hover:text-ink">
                ← Back to profile
              </Link>
            </div>
          </div>
        )}

        {/* Bio Step 1: Enter Username */}
        {step === 'bio_username' && (
          <div className="border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#C8FF00] space-y-4">
            <div className="flex items-center gap-2">
              <button onClick={goBack} className="font-space text-xs font-bold text-muted hover:text-ink">← Back</button>
              <span className="font-space text-[9px] font-bold text-muted">Step 1 of 2</span>
            </div>
            <h2 className="font-jakarta text-lg font-bold text-ink">Enter your Instagram username</h2>
            <p className="font-nunito text-sm text-muted">
              We&apos;ll generate a code for you to add to your Instagram bio.
            </p>
            <div className="space-y-2">
              <div className="flex items-center border-2 border-ink bg-white">
                <span className="px-3 font-nunito text-sm text-muted border-r-2 border-ink">@</span>
                <input
                  type="text"
                  value={bioUsername}
                  onChange={(e) => setBioUsername(e.target.value.replace(/[^a-zA-Z0-9._]/g, ''))}
                  placeholder="your_username"
                  className="flex-1 px-3 py-3 font-nunito text-sm text-ink outline-none bg-transparent"
                  autoFocus
                />
              </div>
              <button
                onClick={() => {
                  if (!bioUsername.trim()) return
                  generateCodeMutation.mutate()
                  setStep('bio_code')
                }}
                disabled={!bioUsername.trim() || generateCodeMutation.isPending}
                className="w-full border-2 border-ink bg-neon px-6 py-3 font-space text-xs font-bold uppercase text-ink shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#0D0D0D] hover:-translate-y-0.5 transition-all disabled:opacity-50 disabled:shadow-none disabled:translate-y-0"
              >
                {generateCodeMutation.isPending ? 'Generating...' : 'Generate Code'}
              </button>
            </div>
          </div>
        )}

        {/* Bio Step 2: Show Code + Instructions */}
        {step === 'bio_code' && (
          <div className="border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#C8FF00] space-y-4">
            <div className="flex items-center gap-2">
              <button onClick={() => setStep('bio_username')} className="font-space text-xs font-bold text-muted hover:text-ink">← Back</button>
              <span className="font-space text-[9px] font-bold text-muted">Step 2 of 2</span>
            </div>
            <h2 className="font-jakarta text-lg font-bold text-ink">Add code to your bio</h2>

            {/* Code display */}
            <div className="border-2 border-dashed border-ink bg-neon/10 p-4 text-center">
              <p className="font-space text-[9px] font-bold uppercase text-muted mb-1">Your verification code</p>
              <p className="font-jakarta text-2xl font-extrabold text-ink tracking-wider">{bioCode}</p>
            </div>

            <button
              onClick={copyCode}
              className="w-full border-2 border-ink bg-white px-4 py-2.5 font-space text-xs font-bold text-ink hover:bg-neon/10 transition-all"
            >
              {copied ? '✓ Copied!' : '📋 Copy Code'}
            </button>

            {/* Instructions */}
            <div className="space-y-2">
              <p className="font-space text-[10px] font-bold uppercase text-muted">Instructions</p>
              <ol className="space-y-1.5 font-nunito text-sm text-ink/80">
                <li className="flex gap-2">
                  <span className="font-bold text-ink shrink-0">1.</span>
                  Open Instagram and go to your profile
                </li>
                <li className="flex gap-2">
                  <span className="font-bold text-ink shrink-0">2.</span>
                  Edit your bio and paste the code above
                </li>
                <li className="flex gap-2">
                  <span className="font-bold text-ink shrink-0">3.</span>
                  Save your bio changes
                </li>
                <li className="flex gap-2">
                  <span className="font-bold text-ink shrink-0">4.</span>
                  Come back here and tap &quot;Verify&quot;
                </li>
              </ol>
            </div>

            <button
              onClick={() => {
                setStep('bio_verifying')
                verifyBioMutation.mutate()
              }}
              disabled={verifyBioMutation.isPending}
              className="w-full border-2 border-ink bg-neon px-6 py-3 font-space text-xs font-bold uppercase text-ink shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#0D0D0D] hover:-translate-y-0.5 transition-all disabled:opacity-50"
            >
              Verify My Bio
            </button>
          </div>
        )}
      </div>
    </main>
  )
}
