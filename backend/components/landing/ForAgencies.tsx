'use client'

import Link from 'next/link'
import { useFrontendSession } from '@/hooks/useFrontendSession'

export default function ForAgencies() {
  const { session, hasSession } = useFrontendSession()

  return (
    <section id="for-agencies" className="bg-purple-50 py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          
          {/* Left */}
          <div>
            <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-extrabold text-ink mb-6 leading-tight">
              Scale your <span className="text-purple-600">agency</span>.<br />
              <span>Represent creators better.</span>
            </h2>

              <div className="space-y-4 mb-8">
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-purple mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                 Manage and pitch multiple creators to brands from one dashboard
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-purple mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                 Invite creators to your roster, review pitches, and track collaborations
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-purple mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                  Charge credits only on successful brand matches — no upfront fees
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-purple mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                  Built-in discovery, roster management, and direct brand outreach
                </p>
              </div>
            </div>


            {/* CTA */}
            {/* {hasSession ? (
              <p className="inline-flex items-center rounded-full border-2 border-ink bg-purple-600 px-4 py-2 font-space text-xs font-bold uppercase tracking-[0.08em] text-white">
                Account ready, {session?.firstName}
              </p>
            ) : (
              <Link
                href="/join/agency"
                className="px-8 py-4 bg-purple-600 text-white border-2 border-ink shadow-neo-purple neo-card neo-card-purple font-jakarta font-bold text-lg transition-all"
              >
                Start as Agency →
              </Link>
            )} */}
          </div>

          {/* Right Card */}
          <div className="flex justify-center lg:justify-end">
            <div className="bg-white border-2 border-ink shadow-neo-purple neo-card neo-card-purple p-6 w-full max-w-[420px]">

              {/* Header */}
              <div className="flex items-center gap-3 mb-6">
              <div className="w-16 h-16 rounded-full bg-purple flex items-center justify-center font-jakarta font-bold text-ink text-2xl">
                  CH
                </div>
                <div>
                  <h3 className="font-jakarta font-bold text-ink text-xl">
                    Creator Hub
                  </h3>
                  <span className="inline-block px-2 py-1 bg-purple-600 text-white text-xs font-jakarta font-bold rounded-full">
                    Agency Pro 🏢
                  </span>
                </div>
              </div>

              {/* Stats */}
              <div className="grid grid-cols-2 gap-4 mb-6 pb-6 border-b-2 border-gray-200">
                <Stat label="Creators" value="24" />
                <Stat label="Pitches" value="18" />
                <Stat label="Won" value="5" highlight />
                <Stat label="Rating" value="4.8⭐" />
              </div>

               <div className="space-y-3 mb-6">
                <div className="flex items-center gap-3 p-3 bg-pink/10 border border-pink rounded">
                  <span className="text-xl">👥</span>
                  <p className="font-nunito text-sm text-ink font-semibold">12 active creators</p>
                </div>
                <div className="flex items-center gap-3 p-3 bg-blue/10 border border-blue rounded">
                  <span className="text-xl">🎯</span>
                  <p className="font-nunito text-sm text-ink font-semibold">5 pitches pending</p>
                </div>
                <div className="flex items-center gap-3 p-3 bg-neon/10 border border-neon rounded">
                  <span className="text-xl">✅</span>
                  <p className="font-nunito text-sm text-ink font-semibold">2 collabs active</p>
                </div>
              </div>

              {/* Credits */}
              <div className="p-3 bg-purple/10 border border-purple rounded">
                <p className="font-nunito text-sm text-ink">
                  <span className="font-semibold">Credits Balance:</span> 45
                </p>
              </div>

            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

/* Small reusable components so you stop duplicating chaos */

function Stat({ label, value, highlight }: any) {
  return (
    <div>
      <p className="font-nunito text-xs text-muted">{label}</p>
      <p className={`font-jakarta font-bold text-lg ${highlight ? 'text-purple-600' : 'text-ink'}`}>
        {value}
      </p>
    </div>
  )
}

function Badge({ icon, text, color }: any) {
  const colors: any = {
    purple: 'bg-purple-50 border-purple-300',
    blue: 'bg-blue-50 border-blue-300',
    green: 'bg-green-50 border-green-300',
  }

  return (
    <div className={`flex items-center gap-3 p-3 border rounded ${colors[color]}`}>
      <span className="text-xl">{icon}</span>
      <p className="font-nunito text-sm text-ink font-semibold">{text}</p>
    </div>
  )
}