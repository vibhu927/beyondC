import dynamicImport from 'next/dynamic'
import Navbar from '@/components/landing/Navbar'
import Hero from '@/components/landing/Hero'
import RecoveryHashRedirect from '@/components/auth/RecoveryHashRedirect'

const Marquee = dynamicImport(() => import('@/components/landing/Marquee'))
const HowItWorks = dynamicImport(() => import('@/components/landing/HowItWorks'))
const PrivacySection = dynamicImport(() => import('@/components/landing/PrivacySection'))
const CollabTypes = dynamicImport(() => import('@/components/landing/CollabTypes'))
const EventInvite = dynamicImport(() => import('@/components/landing/EventInvite'))
const ForCreators = dynamicImport(() => import('@/components/landing/ForCreators'))
const ForBrands = dynamicImport(() => import('@/components/landing/ForBrands'))
const ForAgencies = dynamicImport(() => import('@/components/landing/ForAgencies'))
const Pricing = dynamicImport(() => import('@/components/landing/Pricing'))
const FAQ = dynamicImport(() => import('@/components/landing/FAQ'))
const Waitlist = dynamicImport(() => import('@/components/landing/Waitlist'))
const Footer = dynamicImport(() => import('@/components/landing/Footer'))

export const dynamic = 'force-dynamic'

export default function Home() {
  return (
    <main className="min-h-screen">
      <RecoveryHashRedirect />
      <Navbar />
      <Hero />
      <Marquee />
      <HowItWorks />
      <PrivacySection />
      <CollabTypes />
      <EventInvite />
      {/* <Stats /> */}
      <ForCreators />
      <ForBrands />
      <ForAgencies />
      <Marquee />
      <Pricing />
      <FAQ />
      <Waitlist />
      <Footer />
    </main>
  )
}
