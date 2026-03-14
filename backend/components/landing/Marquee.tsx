export default function Marquee() {
  const creators = [
    'Fashion Creators',
    'Food Creators',
    'Travel Vloggers',
    'Tech Reviewers',
    'Beauty Creators',
    'Comedy Creators',
    'Fitness Creators',
    'Gaming Creators',
  ]

  const brands = [
    'D2C Startups',
    'Health Brands',
    'Fashion Labels',
    'Tech Products',
    'Food Brands',
    'Skincare Brands',
    'EdTech Startups',
    'SaaS Companies',
  ]

  return (
    <section className="bg-ink py-8 overflow-hidden">
      {/* Row 1 - Left Scroll */}
      <div className="marquee-container mb-4">
        <div className="flex animate-marquee">
          {[...creators, ...creators, ...creators].map((item, index) => (
            <span 
              key={index} 
              className="font-space text-neon text-sm sm:text-base uppercase tracking-wide mx-4 whitespace-nowrap"
            >
              {item} ✦
            </span>
          ))}
        </div>
      </div>

      {/* Row 2 - Right Scroll */}
      <div className="marquee-container">
        <div className="flex animate-marquee-reverse" style={{ animationDirection: 'reverse' }}>
          {[...brands, ...brands, ...brands].map((item, index) => (
            <span 
              key={index} 
              className="font-space text-pink text-sm sm:text-base uppercase tracking-wide mx-4 whitespace-nowrap"
            >
              {item} ✦
            </span>
          ))}
        </div>
      </div>
    </section>
  )
}
