'use client'

import { useState } from 'react'

export default function Waitlist() {
  const [email, setEmail] = useState('')
  const [submitted, setSubmitted] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [errorMessage, setErrorMessage] = useState('')

  const submitWaitlist = async () => {
    const normalizedEmail = email.trim()
    if (!normalizedEmail || isSubmitting) return

    setIsSubmitting(true)
    setErrorMessage('')

    try {
      const response = await fetch('/api/waitlist', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: normalizedEmail }),
      })

      const data = await response.json()

      if (!response.ok) {
        setErrorMessage(data?.error || 'Could not join waitlist. Please try again.')
        return
      }

      setSubmitted(true)
      setEmail('')
    } catch {
      setErrorMessage('Could not join waitlist. Please try again.')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <section id="waitlist" className="bg-neon py-20 sm:py-32">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          {/* Headline */}
          <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-black text-ink mb-6 leading-tight">
            Join the waitlist.<br />
            Be Beyond first.
          </h2>

          {/* Subtext */}
          <p className="font-nunito text-lg sm:text-xl text-ink mb-10">
            Launching soon on iOS & Android. Early members get 3 free credits + priority access.
          </p>

          {/* Form or Success State */}
          {!submitted ? (
            <div className="max-w-lg mx-auto mb-6" role="form" aria-label="Join waitlist">
              <div className="flex flex-col sm:flex-row gap-4">
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault()
                      void submitWaitlist()
                    }
                  }}
                  placeholder="your@email.com"
                  required
                  className="flex-1 px-6 py-4 bg-white border-2 border-ink text-ink font-nunito text-lg shadow-neo focus:outline-none focus:shadow-[6px_6px_0_#0D0D0D] transition-all"
                />
                <button
                  type="button"
                  onClick={() => {
                    void submitWaitlist()
                  }}
                  disabled={isSubmitting}
                  className="px-8 py-4 bg-ink text-neon border-2 border-ink shadow-neo font-jakarta font-bold text-lg hover:shadow-[6px_6px_0_#0D0D0D] hover:-translate-y-1 transition-all whitespace-nowrap"
                >
                  {isSubmitting ? (
                    <span className="inline-flex items-center gap-2">
                      <span className="h-4 w-4 animate-spin rounded-full border-2 border-neon border-t-transparent" />
                      Joining...
                    </span>
                  ) : (
                    'Join Now →'
                  )}
                </button>
              </div>
              {errorMessage && (
                <p className="mt-4 font-nunito text-sm text-red-700">{errorMessage}</p>
              )}
            </div>
          ) : (
            <div className="max-w-lg mx-auto mb-6 p-6 bg-ink text-neon border-2 border-ink shadow-neo">
              <div className="flex items-center justify-center gap-3 mb-3">
                <span className="text-3xl">✓</span>
                <h3 className="font-jakarta text-2xl font-bold">Thankyou for joining the waitlist.</h3>
              </div>
              <p className="font-nunito text-lg">We&apos;ll hit you up at launch. 🎉</p>
            </div>
          )}

          {/* Trust Signal */}
          {/* <p className="font-nunito text-sm text-ink mb-8">
            🔒 No spam. Unsubscribe anytime.
          </p> */}

          {/* Divider */}
          <div className="flex items-center gap-4 max-w-lg mx-auto mb-8">
            <div className="flex-1 h-px bg-ink/20"></div>
            <span className="font-jakarta font-bold text-ink text-sm">OR DOWNLOAD NOW</span>
            <div className="flex-1 h-px bg-ink/20"></div>
          </div>

          {/* App Store Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <a 
              href="https://apps.apple.com" 
              target="_blank" 
              rel="noopener noreferrer"
              className="group flex items-center gap-3 px-6 py-3 bg-ink text-white border-2 border-ink shadow-neo hover:shadow-[6px_6px_0_#0D0D0D] hover:-translate-y-1 transition-all"
            >
              <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              <div className="text-left">
                <p className="font-nunito text-xs text-white/70">Download on the</p>
                <p className="font-jakarta font-bold text-base text-white">App Store</p>
              </div>
            </a>
            <a 
              href="https://play.google.com" 
              target="_blank" 
              rel="noopener noreferrer"
              className="group flex items-center gap-3 px-6 py-3 bg-ink text-white border-2 border-ink shadow-neo hover:shadow-[6px_6px_0_#0D0D0D] hover:-translate-y-1 transition-all"
            >
              <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor">
                <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
              </svg>
              <div className="text-left">
                <p className="font-nunito text-xs text-white/70">GET IT ON</p>
                <p className="font-jakarta font-bold text-base text-white">Google Play</p>
              </div>
            </a>
          </div>
        </div>
      </div>
    </section>
  )
}
