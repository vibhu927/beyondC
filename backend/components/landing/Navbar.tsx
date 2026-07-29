'use client'

import Link from 'next/link'
import Image from 'next/image'
import { useState, useEffect } from 'react'
import { useFrontendSession } from '@/hooks/useFrontendSession'

export default function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false)
  const { session, hasSession } = useFrontendSession()

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10)
    }

    window.addEventListener('scroll', handleScroll, { passive: true })
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return (
    <nav 
      className={`fixed top-0 left-0 right-0 z-[100] bg-white border-b-2 border-ink transition-all duration-300 ${
        isScrolled ? 'shadow-md' : ''
      }`}
    >
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16 sm:h-20">
          {/* Logo */}
          <div className="flex items-center">
            <Link href="/" className="flex items-center">
              <span className="relative block h-12 w-12 overflow-hidden rounded-full border-2 border-ink sm:h-14 sm:w-14">
                <Image
                  src="/assets/logo.png"
                  alt="BeyondC logo"
                  fill
                  className="object-cover"
                  priority
                />
              </span>
            </Link>
          </div>

          {/* Desktop Nav Links */}
          <div className="hidden lg:flex items-center gap-8 font-jakarta text-sm font-medium">
            <a href="#how-it-works" className="text-ink hover:text-neon transition-colors">
              How It Works
            </a>
            <a href="#for-creators" className="text-ink hover:text-neon transition-colors">
              For Creators
            </a>
            <a href="#for-brands" className="text-ink hover:text-neon transition-colors">
              For Brands
            </a>
            <a href="#for-agencies" className="text-ink hover:text-neon transition-colors">
              For Agencies
            </a>
            <a href="#pricing" className="text-ink hover:text-neon transition-colors">
              Pricing
            </a>
          </div>

          {/* CTA Buttons */}
          <div className="relative z-[120] flex items-center gap-3 shrink-0 pointer-events-auto">
            {hasSession ? (
              <>
                <span className="hidden sm:inline-flex items-center rounded-full border-2 border-ink bg-neon px-4 py-2 font-jakarta text-xs font-bold uppercase tracking-[0.08em] text-ink">
                  Hi, {session?.firstName}
                </span>
                <Link
                  href={session?.role === 'brand' ? '/dashboard/brand' : '/dashboard/creator'}
                  className="shrink-0 cursor-pointer px-4 py-2 bg-ink text-neon border-2 border-ink font-jakarta font-semibold text-sm hover:bg-transparent hover:text-ink transition-all"
                >
                  Dashboard
                </Link>
              </>
            ) : (
              <>
                <Link
                  href="/login"
                  className="hidden sm:block shrink-0 cursor-pointer px-4 py-2 bg-purple text-white border-2 border-ink font-jakarta font-semibold text-sm shadow-[3px_3px_0_#0D0D0D] hover:shadow-[4px_4px_0_#9B5DE5] hover:-translate-y-0.5 transition-all"
                >
                  Log In
                </Link>
                <Link
                  href="#waitlist"
                  className="hidden sm:block shrink-0 cursor-pointer px-4 py-2 bg-ink text-neon border-2 border-ink font-jakarta font-semibold text-sm shadow-[3px_3px_0_#C8FF00] hover:shadow-[4px_4px_0_#C8FF00] hover:-translate-y-0.5 transition-all"
                >
                  Join as Creator
                </Link>
                <Link
                  href="/join/brand"
                  className="shrink-0 cursor-pointer px-5 py-2 bg-pink text-white border-2 border-ink font-jakarta font-semibold text-sm shadow-[3px_3px_0_#0D0D0D] hover:shadow-[4px_4px_0_#0D0D0D] hover:-translate-y-0.5 transition-all"
                >
                  Join as Brand
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  )
}
