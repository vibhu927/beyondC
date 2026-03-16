'use client'

import Link from 'next/link'
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
            <Link href="/" className="flex items-center gap-0 font-space text-2xl sm:text-3xl font-bold">
              <span className="text-ink">Beyond</span>
              <span className="bg-ink text-neon px-2 sm:px-3 py-1 rounded-full">C</span>
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
            <a href="#pricing" className="text-ink hover:text-neon transition-colors">
              Pricing
            </a>
          </div>

          {/* CTA Buttons */}
          <div className="relative z-[120] flex items-center gap-3 shrink-0 pointer-events-auto">
            {hasSession ? (
              <>
                <span className="hidden sm:inline-flex items-center rounded-full border-2 border-ink bg-neon px-4 py-2 font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
                  Hi, {session?.firstName}
                </span>
                <Link
                  href="/"
                  className="shrink-0 cursor-pointer px-4 py-2 bg-ink text-neon border-2 border-ink font-jakarta font-semibold text-sm hover:bg-transparent hover:text-ink transition-all"
                >
                  Home
                </Link>
              </>
            ) : (
              <>
                <Link
                  href="/join/creator"
                  className="hidden sm:block shrink-0 cursor-pointer px-4 py-2 bg-ink text-neon border-2 border-ink font-jakarta font-semibold text-sm hover:bg-transparent hover:text-ink transition-all"
                >
                  Join as Creator
                </Link>
                <Link
                  href="/join/brand"
                  className="shrink-0 cursor-pointer px-4 py-2 bg-neon text-ink border-2 border-ink font-jakarta font-semibold text-sm hover:shadow-neo transition-all"
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
