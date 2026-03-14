export default function EventInvite() {
  return (
    <section className="bg-ink py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left - Text */}
          <div>
            {/* Badge */}
            <div className="mb-6">
              <span className="inline-block px-4 py-2 bg-purple text-white border-2 border-white font-jakarta font-bold text-sm">
                🎟️ NEW FEATURE
              </span>
            </div>

            {/* Headline */}
            <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-extrabold text-white mb-6 leading-tight">
              <span className="block">IRL collabs just</span>
              <span className="block">
                <span className="inline-block relative">
                  got an upgrade.
                  <span className="absolute bottom-0 left-0 w-full h-1 bg-purple"></span>
                </span>
              </span>
            </h2>

            {/* Description */}
            <p className="font-nunito text-lg text-gray-300 leading-relaxed mb-8">
              Brands can now invite creators to their real-world events — product launches, brand parties, press meets and more. Creators get a digital entry pass with a QR code, right inside the app.
            </p>

            {/* Feature Pills */}
            <div className="space-y-3 mb-8">
              <div className="flex items-center gap-3">
                <span className="text-2xl">📍</span>
                <p className="font-nunito text-white">Works for physical & virtual events</p>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-2xl">📲</span>
                <p className="font-nunito text-white">Ticket lives in your app — no printing needed</p>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-2xl">✨</span>
                <p className="font-nunito text-white">Shareable on stories — free brand exposure</p>
              </div>
            </div>

            {/* CTA */}
            <button className="px-8 py-4 bg-transparent text-white border-2 border-white shadow-neo-purple font-jakarta font-bold text-lg hover:shadow-[6px_6px_0_#9B5DE5] hover:-translate-y-1 transition-all">
              Learn More →
            </button>
          </div>

          {/* Right - Digital Ticket Card */}
          <div className="flex justify-center lg:justify-end">
            <div 
              className="bg-white border-2 border-ink shadow-neo-purple w-full max-w-[380px] rounded-lg overflow-hidden float-element"
              style={{ transform: 'rotate(-3deg)' }}
            >
              {/* Accepted Badge */}
              <div className="absolute top-4 right-4 z-10">
                <span className="inline-block px-3 py-1 bg-green-600 text-white text-xs font-jakarta font-bold rounded-full">
                  ✅ Accepted
                </span>
              </div>

              {/* Top Half */}
              <div className="p-6 border-b-2 border-dashed border-ink">
                <h3 className="font-jakarta text-2xl font-bold text-ink mb-2">
                  NikeIndia 👟
                </h3>
                <p className="font-jakarta text-xl font-semibold text-pink mb-4">
                  Air Max Day Launch Party 🎉
                </p>
                <div className="space-y-2">
                  <p className="font-nunito text-sm text-ink">
                    <span className="font-semibold">Date:</span> Saturday, 15 Feb 2025
                  </p>
                  <p className="font-nunito text-sm text-ink">
                    <span className="font-semibold">Time:</span> 7:00 PM onwards
                  </p>
                  <p className="font-nunito text-sm text-ink">
                    <span className="font-semibold">Location:</span> The Collective, Mumbai
                  </p>
                </div>
              </div>

              {/* Bottom Half */}
              <div className="p-6">
                <div className="mb-4">
                  <p className="font-jakarta font-bold text-ink text-lg">Priya Sharma</p>
                  <p className="font-nunito text-sm text-muted">Micro Creator 🎨</p>
                </div>

                {/* Fake QR Code */}
                <div className="flex items-center justify-between">
                  <div className="grid grid-cols-8 gap-1 w-24 h-24">
                    {Array.from({ length: 64 }).map((_, i) => (
                      <div
                        key={i}
                        className={`${
                          Math.random() > 0.5 ? 'bg-ink' : 'bg-white'
                        }`}
                      />
                    ))}
                  </div>
                  <div className="text-right">
                    <p className="font-space text-xs text-muted">Powered by</p>
                    <p className="font-space text-sm font-bold text-ink">
                      Beyond<span className="text-neon">C</span>
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
