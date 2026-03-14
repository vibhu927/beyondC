'use client'

export default function ForBrands() {
  return (
    <section id="for-brands" className="bg-ink py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left - Campaign Post Card */}
          <div className="flex justify-center lg:justify-start order-2 lg:order-1">
            <div className="bg-zinc-900 border-2 border-pink shadow-neo-pink p-6 w-full max-w-[400px]">
              {/* Brand Header */}
              <div className="mb-4">
                <span className="inline-block px-3 py-2 bg-pink text-white text-sm font-jakarta font-bold rounded-full mb-3">
                  HealthPlus 🏥
                </span>
                <span className="inline-block ml-2 px-2 py-1 bg-white/10 text-white text-xs font-nunito rounded">
                  Health & Wellness
                </span>
              </div>

              {/* Campaign Details */}
              <div className="mb-6 pb-6 border-b border-gray-700">
                <h3 className="font-jakarta font-bold text-white text-xl mb-3">
                  Looking for Fitness Creators
                </h3>
                <div className="space-y-2">
                  <p className="font-nunito text-sm text-gray-300">
                    <span className="font-semibold">Budget:</span> ₹1,500–₹3,000 OR product worth ₹2,000
                  </p>
                  <p className="font-nunito text-sm text-gray-300">
                    <span className="font-semibold">Niche:</span> Fitness & Wellness
                  </p>
                </div>
              </div>

              {/* Status */}
              <div className="mb-6">
                <div className="flex items-center justify-between">
                  <span className="inline-block px-3 py-1 bg-neon text-ink text-sm font-jakarta font-bold rounded">
                    12 bids received 🔥
                  </span>
                  <span className="font-nunito text-sm text-gray-400">3 days left ⏳</span>
                </div>
              </div>

              {/* Mini Bid Cards */}
              <div className="space-y-3">
                <div className="p-3 bg-white/5 border border-gray-700 rounded">
                  <div className="flex items-center justify-between mb-2">
                    <p className="font-jakarta font-bold text-white text-sm">Rahul M.</p>
                    <p className="font-jakarta font-bold text-neon text-sm">₹1,800</p>
                  </div>
                  <p className="font-nunito text-xs text-gray-400">2 Reels + 3 Stories</p>
                </div>
                <div className="p-3 bg-white/5 border border-gray-700 rounded">
                  <div className="flex items-center justify-between mb-2">
                    <p className="font-jakarta font-bold text-white text-sm">Ananya K.</p>
                    <p className="font-jakarta font-bold text-neon text-sm">₹2,200</p>
                  </div>
                  <p className="font-nunito text-xs text-gray-400">3 Reels + reel cover design</p>
                </div>
              </div>
            </div>
          </div>

          {/* Right - Text */}
          <div className="order-1 lg:order-2">
            <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-extrabold text-white mb-6 leading-tight">
              Find creators.<br />
              <span className="inline-block relative">
                <span className="strikethrough text-pink">guesswork</span>
                <span className="ml-3">Without the chaos.</span>
              </span>
            </h2>

            {/* Bullet Points */}
            <div className="space-y-4 mb-8">
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-pink mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-white">
                  Filter by niche, content type, reach range and budget
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-pink mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-white">
                  Post a campaign and let creators pitch YOU
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-pink mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-white">
                  Host events and send digital invites to hand-picked creators
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-pink mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-white">
                  Credit system — only charged when there's a match
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 rounded-full bg-pink mt-2 flex-shrink-0"></div>
                <p className="font-nunito text-lg text-white">
                  Verified reach — no inflated follower counts
                </p>
              </div>
            </div>

            {/* CTA */}
            <button 
              className="px-8 py-4 bg-pink text-white border-2 border-white shadow-neo-pink font-jakarta font-bold text-lg hover:shadow-[6px_6px_0_#FF2D78] hover:-translate-y-1 transition-all"
              onClick={() => document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' })}
            >
              Start as Brand →
            </button>
          </div>
        </div>
      </div>
    </section>
  )
}
