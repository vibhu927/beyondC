'use client'

import Link from 'next/link'
import Navbar from '@/components/landing/Navbar'
import { useFrontendSession } from '@/hooks/useFrontendSession'

const creatorTags = ['Nano', 'Micro', 'Macro']
const brandTags = ['Startup', 'D2C', 'Big Brand']

function RoleCard({
  href,
  badge,
  badgeClass,
  title,
  description,
  tags,
  shadow,
  buttonClass,
  buttonText,
}: {
  href: string
  badge: string
  badgeClass: string
  title: string
  description: string
  tags: string[]
  shadow: string
  buttonClass: string
  buttonText: string
}) {
  return (
    <Link
      href={href}
      className={`neo-card block bg-white border-2 border-ink p-6 md:p-8 ${shadow} hover:-translate-y-1 transition-all`}
    >
      <div className="space-y-5">
        <span className={`inline-flex items-center rounded-full px-4 py-1 text-sm font-space font-bold border-2 border-ink ${badgeClass}`}>
          {badge}
        </span>

        <h2 className="font-jakarta text-3xl md:text-4xl font-extrabold text-ink">
          {title}
        </h2>

        <p className="font-nunito text-lg text-ink/80 leading-relaxed">{description}</p>

        <div className="flex flex-wrap gap-2">
          {tags.map((tag) => (
            <span
              key={tag}
              className="rounded-full border-2 border-ink bg-white px-3 py-1 text-xs font-space font-bold text-ink"
            >
              {tag}
            </span>
          ))}
        </div>

        <div className={`inline-flex items-center justify-center border-2 border-ink px-5 py-3 text-sm font-space font-bold ${buttonClass}`}>
          {buttonText}
        </div>
      </div>
    </Link>
  )
}

export default function JoinPage() {
  const { session, hasSession } = useFrontendSession()

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      <section className="px-4 pb-20 pt-28 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-6xl">
          <h1 className="text-center font-jakarta text-[40px] font-extrabold leading-tight text-ink md:text-[56px]">
            I am a...
          </h1>

          {hasSession ? (
            <div className="mx-auto mt-10 max-w-2xl border-2 border-ink bg-white p-8 text-center shadow-[6px_6px_0_#C8FF00]">
              <p className="font-space text-xs font-bold uppercase tracking-[0.08em] text-ink/70">
                Account Already Created
              </p>
              <h2 className="mt-3 font-jakarta text-3xl font-extrabold text-ink">
                Welcome, {session?.firstName}
              </h2>
              <p className="mt-4 font-nunito text-base text-ink/80">
                You are already onboarded. Join options are hidden for your session.
              </p>
              <div className="mt-6">
                <Link
                  href="/"
                  className="inline-flex items-center justify-center border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon shadow-[4px_4px_0_#0D0D0D]"
                >
                  Go to Home →
                </Link>
              </div>
            </div>
          ) : (
            <>
              <div className="mt-10 grid grid-cols-1 gap-8 lg:grid-cols-2">
                <RoleCard
                  href="/join/creator"
                  badge="🎨 For Creators"
                  badgeClass="bg-neon text-ink"
                  title="Content Creator"
                  description="Get paid to create. Collabs starting at ₹100."
                  tags={creatorTags}
                  shadow="shadow-[6px_6px_0_#C8FF00]"
                  buttonClass="bg-ink text-neon"
                  buttonText="Join as Creator →"
                />

                <RoleCard
                  href="/join/brand"
                  badge="🏢 For Brands"
                  badgeClass="bg-pink text-white"
                  title="Brand / Startup"
                  description="Find creators for campaigns and events."
                  tags={brandTags}
                  shadow="shadow-[6px_6px_0_#FF2D78]"
                  buttonClass="bg-pink text-white"
                  buttonText="Join as Brand →"
                />
              </div>

              <p className="mt-10 text-center font-nunito text-base text-ink/80">
                Already have an account?{' '}
                <Link href="/login" className="font-bold text-pink underline underline-offset-4">
                  Log in
                </Link>
              </p>
            </>
          )}
        </div>
      </section>
    </main>
  )
}
