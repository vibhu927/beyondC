'use client'

import { useEffect, useState, useRef } from 'react'
import { useCountUp } from '@/hooks/useCountUp'

export default function Stats() {
  const [isVisible, setIsVisible] = useState(false)
  const sectionRef = useRef<HTMLDivElement>(null)

  const creators = useCountUp(10000, 2000, isVisible)
  const brands = useCountUp(2400, 2000, isVisible)
  const paidOut = useCountUp(50, 2000, isVisible)
  const rating = useCountUp(48, 2000, isVisible)

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true)
        }
      },
      { threshold: 0.3 }
    )

    if (sectionRef.current) {
      observer.observe(sectionRef.current)
    }

    return () => {
      if (sectionRef.current) {
        observer.unobserve(sectionRef.current)
      }
    }
  }, [])

  const stats = [
    {
      value: `${creators.toLocaleString()}+`,
      label: 'Creators',
      color: 'text-neon',
    },
    {
      value: `${brands.toLocaleString()}+`,
      label: 'Brands',
      color: 'text-pink',
    },
    {
      value: `₹${paidOut}L+`,
      label: 'Paid Out',
      color: 'text-blue',
    },
    {
      value: `${(rating / 10).toFixed(1)}★`,
      label: 'Rating',
      color: 'text-purple',
    },
  ]

  return (
    <section ref={sectionRef} className="relative bg-ink py-20 sm:py-32 overflow-hidden">
      {/* Animated Background Gradient */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] rounded-full blur-3xl animate-pulse"
          style={{
            background: 'radial-gradient(circle, #C8FF00 0%, #FF2D78 50%, #3D5BFF 100%)',
          }}
        />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-12">
          {stats.map((stat, index) => (
            <div key={index} className="text-center">
              <div className={`font-space text-5xl sm:text-6xl lg:text-7xl font-bold text-white mb-3 ${stat.color}`}>
                {stat.value}
              </div>
              <div className={`font-jakarta text-lg sm:text-xl font-semibold ${stat.color}`}>
                {stat.label}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
