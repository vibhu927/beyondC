export default function Pricing() {
  const brandPacks = [
    {
      name: 'Starter',
      credits: '3 credits',
      price: '₹149',
      shadow: 'neo-neon',
      hoverClass: 'neo-card-neon',
      popular: false,
    },
    {
      name: 'Growth',
      credits: '7 credits',
      price: '₹299',
      shadow: 'neo-pink',
      hoverClass: 'neo-card-pink',
      popular: true,
    },
    {
      name: 'Pro',
      credits: '12 credits',
      price: '₹499',
      shadow: 'neo-blue',
      hoverClass: 'neo-card-blue',
      popular: false,
    },
  ]

  const creatorTiers = [
    {
      brandSize: 'Micro Brand',
      fee: '₹10–₹20',
      shadow: 'neo-neon',
      hoverClass: 'neo-card-neon',
    },
    {
      brandSize: 'Mid Brand',
      fee: '₹50–₹70',
      shadow: 'neo-purple',
      hoverClass: 'neo-card-purple',
      popular: true,
    },
    {
      brandSize: 'Big Brand',
      fee: '₹100–₹150',
      shadow: 'neo-pink',
      hoverClass: 'neo-card-pink',
    },
  ]

  const agencyPacks = [
    {
      name: 'Starter',
      credits: '5 credits',
      price: '₹199',
      shadow: 'neo-neon',
      hoverClass: 'neo-card-neon',
      popular: false,
    },
    {
      name: 'Growth',
      credits: '12 credits',
      price: '₹399',
      shadow: 'neo-pink',
      hoverClass: 'neo-card-pink',
      popular: true,
    },
    {
      name: 'Pro',
      credits: '20 credits',
      price: '₹699',
      shadow: 'neo-blue',
      hoverClass: 'neo-card-blue',
      popular: false,
    },
  ]

  return (
    <section id="pricing" className="bg-white py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Headline */}
        <div className="text-center mb-16">
          <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-extrabold text-ink">
            Pricing that doesn&apos;t <span className="text-pink">sting</span>.
          </h2>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12 mb-12">
          {/* Left - For Brands */}
          <div>
            <h3 className="font-jakarta text-3xl font-bold text-ink mb-8 text-center lg:text-left">
              For Brands: Credit Packs
            </h3>
            <div className="space-y-6">
              {brandPacks.map((pack, index) => (
                <div
                  key={index}
                  className={`relative bg-white border-2 border-ink shadow-${pack.shadow} p-6 neo-card ${pack.hoverClass} transition-all`}
                >
                  {pack.popular && (
                    <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                      <span className="inline-block px-3 py-1 bg-pink text-white text-xs font-jakarta font-bold rounded-full">
                        ⭐ Most Popular
                      </span>
                    </div>
                  )}
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className="font-jakarta text-2xl font-bold text-ink mb-1">
                        {pack.name}
                      </h4>
                      <p className="font-nunito text-muted">{pack.credits}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-space text-3xl font-bold text-ink">{pack.price}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Middle - For Creators */}
          <div>
            <h3 className="font-jakarta text-3xl font-bold text-ink mb-8 text-center lg:text-left">
              For Creators: Wallet Tiers
            </h3>
            <div className="space-y-6">
              {creatorTiers.map((tier, index) => (
                <div
                  key={index}
className={`bg-white border-2 border-ink shadow-${tier.shadow} p-6 neo-card ${tier.hoverClass} transition-all`}                >
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className="font-jakarta text-2xl font-bold text-ink mb-1">
                        {tier.brandSize}
                      </h4>
                      <p className="font-nunito text-muted">Collab Fee</p>
                    </div>
                    <div className="text-right">
                      <p className="font-space text-3xl font-bold text-ink">{tier.fee}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Right - For Agencies */}
          <div>
            <h3 className="font-jakarta text-3xl font-bold text-ink mb-8 text-center lg:text-left">
              For Agencies: Credit Packs
            </h3>
            <div className="space-y-6">
              {agencyPacks.map((pack, index) => (
                <div
                  key={index}
className={`relative bg-white border-2 border-ink shadow-${pack.shadow} p-6 neo-card ${pack.hoverClass} transition-all`}                >
                  {pack.popular && (
                    <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                      <span className="inline-block px-3 py-1 bg-pink text-white text-xs font-jakarta font-bold rounded-full">
                        ⭐ Most Popular
                      </span>
                    </div>
                  )}
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className="font-jakarta text-2xl font-bold text-ink mb-1">
                        {pack.name}
                      </h4>
                      <p className="font-nunito text-muted">{pack.credits}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-space text-3xl font-bold text-ink">{pack.price}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Bottom Note */}
        <div className="text-center">
          <p className="font-jakarta text-xl font-bold text-ink">
            Fee only when you ACCEPT. Browsing & bidding = always free. 🙌
          </p>
        </div>
      </div>
    </section>
  )
}
