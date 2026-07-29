import type { Metadata } from 'next'
import { League_Spartan, Space_Grotesk, Nunito } from 'next/font/google'
import './globals.css'
import { QueryProvider } from '@/components/providers/query-provider'

const leagueSpartanJakarta = League_Spartan({
  subsets: ['latin'],
  variable: '--font-jakarta',
  weight: ['600', '700', '800'],
  display: 'swap',
})

const spaceGrotesk = Space_Grotesk({
  subsets: ['latin'],
  variable: '--font-space',
  display: 'swap',
})

const nunito = Nunito({
  subsets: ['latin'],
  variable: '--font-nunito',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'BeyondC - Collabs that go Beyond the feed',
  description: 'BeyondC connects brands and creators  for real paid collabs — starting at just ₹100. No fake followers. No cold DMs. Just results.',
  icons: {
    icon: '/favicon.svg',
  },
  keywords: 'brand collaboration, content creators, influencer marketing, paid collabs, creator economy, India',
  openGraph: {
    title: 'BeyondC - Collabs that go Beyond the feed',
    description: 'Real paid collabs between brands and creators. Starting at just ₹100.',
    type: 'website',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={`${leagueSpartanJakarta.variable} ${spaceGrotesk.variable} ${nunito.variable}`}>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </head>
      <body className={nunito.className}>
        <QueryProvider>{children}</QueryProvider>
      </body>
    </html>
  )
}
