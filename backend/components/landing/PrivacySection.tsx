export default function PrivacySection() {
  return (
    <section className="bg-ink py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left - Text */}
          <div>
            <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-extrabold text-white mb-6 leading-tight">
              <span className="block">Your identity.</span>
              <span className="block">
                <span className="inline-block relative">
                  Your control.
                  <span className="absolute bottom-0 left-0 w-full h-1 bg-neon"></span>
                </span>
              </span>
            </h2>
            <p className="font-nunito text-lg text-gray-300 leading-relaxed">
              Brands only see your first name, follower range, niche and content type — never your Instagram handle or full name. Full info unlocks only when BOTH sides say yes.
            </p>
          </div>

          {/* Right - Profile Cards */}
          <div className="flex items-center justify-center gap-6">
            {/* Before Match Card */}
            <div className="bg-zinc-900 border-2 border-neon shadow-neo-neon p-6 w-full max-w-[200px]">
              <div className="mb-4">
                <span className="inline-block px-2 py-1 bg-red-600 text-white text-xs font-jakarta font-bold rounded mb-3">
                  🔒 Not Matched
                </span>
              </div>
              <div className="space-y-3">
                <div>
                  <p className="font-jakarta font-bold text-white text-lg">Varun D</p>
                  <p className="font-nunito text-sm text-gray-400">████████</p>
                </div>
                <div>
                  <p className="font-nunito text-xs text-gray-500">Handle</p>
                  <p className="font-nunito text-sm text-gray-400">@██████████</p>
                </div>
                <div>
                  <p className="font-nunito text-xs text-gray-500">Stats</p>
                  <p className="font-nunito text-sm text-white">18.2K followers</p>
                  <p className="font-nunito text-sm text-white">Fashion</p>
                </div>
              </div>
            </div>

            {/* Arrow */}
            <div className="flex flex-col items-center">
              <span className="text-neon text-3xl font-bold">→</span>
              <span className="font-nunito text-neon text-xs mt-2 text-center">Mutual<br />Accept</span>
            </div>

            {/* After Match Card */}
            <div className="bg-zinc-900 border-2 border-neon shadow-neo-neon p-6 w-full max-w-[200px]">
              <div className="mb-4">
                <span className="inline-block px-2 py-1 bg-green-600 text-white text-xs font-jakarta font-bold rounded mb-3">
                  ✅ Connected
                </span>
              </div>
              <div className="space-y-3">
                <div>
                  <p className="font-jakarta font-bold text-white text-lg">Varun D</p>
                  <p className="font-nunito text-sm text-gray-300">Fashion Creator</p>
                </div>
                <div>
                  <p className="font-nunito text-xs text-gray-500">Handle</p>
                  <p className="font-nunito text-sm text-neon">@varunn</p>
                </div>
                <div>
                  <p className="font-nunito text-xs text-gray-500">Stats</p>
                  <p className="font-nunito text-sm text-white">18.2K followers</p>
                  <p className="font-nunito text-sm text-white">4.3% engagement</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
