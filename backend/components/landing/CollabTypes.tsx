export default function CollabTypes() {
  const types = [
    {
      icon: '💵',
      title: 'Paid',
      description: 'Cash collabs from ₹100. Real money for real content.',
      shadow: 'neo-neon',
      hoverClass: 'neo-card-neon',
    },
    {
      icon: '📦',
      title: 'Barter',
      description: 'Get brand products in exchange for your content.',
      shadow: 'neo-pink',
      hoverClass: 'neo-card-pink',
    },
    {
      icon: '🤝',
      title: 'Hybrid',
      description: 'Mix of cash + products. Best of both worlds.',
      shadow: 'neo-blue',
      hoverClass: 'neo-card-blue',
    },
    {
      icon: '🎟️',
      title: 'Event Invite',
      description: 'Get invited to brand launches, parties & press meets. Your ticket lives in the app.',
      shadow: 'neo-purple',
      hoverClass: 'neo-card-purple',
    },
  ]

  return (
    <section className="bg-white py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Headline */}
        <div className="text-center mb-16">
          <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-extrabold text-ink">
            Every collab type.<br />Every budget.
          </h2>
        </div>

        {/* Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {types.map((type, index) => (
            <div
              key={index}
              className={`bg-white border-2 border-ink shadow-${type.shadow} p-6 neo-card ${type.hoverClass} transition-all`}
            >
              <div className="text-5xl mb-4">{type.icon}</div>
              <h3 className="font-jakarta text-2xl font-bold text-ink mb-3">
                {type.title}
              </h3>
              <p className="font-nunito text-base text-muted leading-relaxed">
                {type.description}
              </p>
            </div>
          ))}
        </div>

        {/* Coming Soon */}
        <div className="text-center">
          <p className="font-nunito text-sm text-purple">
            + Affiliate & revenue share collabs coming soon
          </p>
        </div>
      </div>
    </section>
  )
}
