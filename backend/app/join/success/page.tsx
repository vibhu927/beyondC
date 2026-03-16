'use client'

import Link from 'next/link'
import { useFrontendSession } from '@/hooks/useFrontendSession'

export default function JoinSuccessPage() {
  const { session } = useFrontendSession()

  return (
    <main className="flex min-h-screen items-center justify-center bg-ink px-4 py-12">
      <div className="w-full max-w-3xl text-center">
        <div className="mx-auto flex w-max items-center gap-0 font-space text-4xl font-bold sm:text-5xl">
          <span className="text-white">Beyond</span>
          <span className="rounded-full bg-white px-3 py-1 text-neon border-2 border-white">C</span>
        </div>

        <p className="mt-8 text-[80px] leading-none">🎉</p>

        <h1 className="mt-6 font-jakarta text-4xl font-extrabold text-white sm:text-[40px]">
          You&apos;re in{session?.firstName ? `, ${session.firstName}` : ''}!
        </h1>

        <p className="mx-auto mt-4 max-w-xl font-nunito text-lg text-white/75">
          Thanks for joining BeyondC. Download the app and log in with the same account.
        </p>

        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
          <Link
            href="/"
            className="inline-flex w-full items-center justify-center gap-2 border-2 border-neon bg-ink px-6 py-4 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon shadow-[4px_4px_0_#C8FF00] sm:w-auto"
          >
            <span aria-hidden>⌂</span>
            Go to Home
          </Link>

          <Link
            href="#"
            className="inline-flex w-full items-center justify-center gap-2 border-2 border-ink bg-white px-6 py-4 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink shadow-[4px_4px_0_#0D0D0D] sm:w-auto"
          >
            <span aria-hidden>🍎</span>
            Download on App Store
          </Link>

          <Link
            href="#"
            className="inline-flex w-full items-center justify-center gap-2 border-2 border-ink bg-neon px-6 py-4 font-space text-sm font-bold uppercase tracking-[0.08em] text-ink shadow-[4px_4px_0_#0D0D0D] sm:w-auto"
          >
            <span aria-hidden>▶</span>
            Get it on Google Play
          </Link>
        </div>

        <p className="mt-6 font-nunito text-sm text-white/60">
          Your account is ready. Same email and password works on the app.
        </p>
      </div>
    </main>
  )
}
