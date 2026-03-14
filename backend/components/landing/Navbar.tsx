'use client'

import { useState, useEffect } from 'react'

export default function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10)
    }

    window.addEventListener('scroll', handleScroll, { passive: true })
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return (
    <nav 
      className={`fixed top-0 left-0 right-0 z-50 bg-white border-b-2 border-ink transition-all duration-300 ${
        isScrolled ? 'shadow-md' : ''
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16 sm:h-20">
          {/* Logo */}
          <div className="flex items-center">
            <a href="#" className="flex items-center gap-0 font-space text-2xl sm:text-3xl font-bold">
              <span className="text-ink">Beyond</span>
              <span className="bg-ink text-neon px-2 sm:px-3 py-1 rounded-full">C</span>
            </a>
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
          <div className="flex items-center gap-3">
            <button 
              className="hidden sm:block px-4 py-2 bg-ink text-neon border-2 border-ink font-jakarta font-semibold text-sm hover:bg-transparent hover:text-ink transition-all"
              onClick={() => document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' })}
            >
              Join as Creator
            </button>
            <button 
              className="px-4 py-2 bg-neon text-ink border-2 border-ink font-jakarta font-semibold text-sm hover:shadow-neo transition-all"
              onClick={() => document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' })}
            >
              Join as Brand
            </button>
          </div>
        </div>
      </div>
    </nav>
  )
}
