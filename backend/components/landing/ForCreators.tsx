'use client'

export default function ForCreators() {
  return (
    <section id="for-creators" className="bg-white py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left - Text */}
          <div>
            <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-extrabold text-ink mb-6">
              Made for <span className="text-pink">every</span> creator.
            </h2>

            {/* Bullet Points */}
            <div className="space-y-4 mb-8">
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-neon mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                  Nano (under 5K) to Macro (500K+) — all welcome
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-neon mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                  Brands discover YOU — no cold pitching needed
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-neon mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                  Wallet system — pay only when you accept a collab
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-neon mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                  Your Instagram stays hidden until you say yes
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-neon mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-ink">
                  Get invited to brand events — your digital entry ticket lives right in the app 🎟️
                </p>
              </div>
            </div>

            {/* CTA */}
            <button 
              className="px-8 py-4 bg-ink text-neon border-2 border-ink shadow-neo-neon font-jakarta font-bold text-lg hover:shadow-[6px_6px_0_#C8FF00] hover:-translate-y-1 transition-all"
              onClick={() => document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' })}
            >
              Start as Creator →
            </button>
          </div>

          {/* Right - Creator Dashboard Card */}
          <div className="flex justify-center lg:justify-end">
            <div className="bg-white border-2 border-ink shadow-neo-neon p-6 w-full max-w-[400px]">
              {/* Profile Header */}
              <div className="flex items-center gap-4 mb-6">
                <div className="w-16 h-16 rounded-full bg-neon flex items-center justify-center font-jakarta font-bold text-ink text-2xl">
                  PS
                </div>
                <div>
                  <h3 className="font-jakarta font-bold text-ink text-xl">Priya S.</h3>
                  <span className="inline-block px-2 py-1 bg-neon text-ink text-xs font-jakarta font-bold rounded-full">
                    Micro Creator 🎨
                  </span>
                </div>
              </div>

              {/* Stats Row */}
              <div className="grid grid-cols-3 gap-4 mb-6 pb-6 border-b-2 border-gray-200">
                <div>
                  <p className="font-nunito text-xs text-muted">Followers</p>
                  <p className="font-jakarta font-bold text-ink text-lg">18.2K</p>
                </div>
                <div>
                  <p className="font-nunito text-xs text-muted">Engagement</p>
                  <p className="font-jakarta font-bold text-ink text-lg">4.3%</p>
                </div>
                <div>
                  <p className="font-nunito text-xs text-muted">Avg Rate</p>
                  <p className="font-jakarta font-bold text-ink text-lg">₹800</p>
                </div>
              </div>

              {/* Notifications */}
              <div className="space-y-3 mb-6">
                <div className="flex items-center gap-3 p-3 bg-pink/10 border border-pink rounded">
                  <span className="text-xl">🔔</span>
                  <p className="font-nunito text-sm text-ink font-semibold">3 new brand requests</p>
                </div>
                <div className="flex items-center gap-3 p-3 bg-blue/10 border border-blue rounded">
                  <span className="text-xl">📢</span>
                  <p className="font-nunito text-sm text-ink font-semibold">2 active campaigns</p>
                </div>
                <div className="flex items-center gap-3 p-3 bg-purple/10 border border-purple rounded">
                  <span className="text-xl">🎟️</span>
                  <p className="font-nunito text-sm text-ink font-semibold">1 event invite</p>
                </div>
              </div>

              {/* Wallet */}
              <div className="p-3 bg-neon/20 border-2 border-neon rounded">
                <p className="font-nunito text-sm text-ink">
                  <span className="font-semibold">Wallet balance:</span> ₹240
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
