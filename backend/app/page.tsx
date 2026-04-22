import Navbar from '@/components/landing/Navbar'
import Hero from '@/components/landing/Hero'
import Marquee from '@/components/landing/Marquee'
import HowItWorks from '@/components/landing/HowItWorks'
import PrivacySection from '@/components/landing/PrivacySection'
import CollabTypes from '@/components/landing/CollabTypes'
import EventInvite from '@/components/landing/EventInvite'
// import Stats from '@/components/landing/Stats'
import ForCreators from '@/components/landing/ForCreators'
import ForBrands from '@/components/landing/ForBrands'
import ForAgencies from '@/components/landing/ForAgencies'
import Pricing from '@/components/landing/Pricing'
import FAQ from '@/components/landing/FAQ'
import Waitlist from '@/components/landing/Waitlist'
import Footer from '@/components/landing/Footer'
import RecoveryHashRedirect from '@/components/auth/RecoveryHashRedirect'

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
