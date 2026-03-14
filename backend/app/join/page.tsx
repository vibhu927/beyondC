import Link from 'next/link'
import Navbar from '@/components/landing/Navbar'

const creatorTags = ['Nano', 'Micro', 'Macro']
const brandTags = ['Startup', 'D2C', 'Big Brand']

function RoleCard({
  href,
  badge,
  badgeClass,
  title,
  description,
  tags,
  shadow,
  buttonClass,
  buttonText,
}: {
  href: string
  badge: string
  badgeClass: string
  title: string
  description: string
  tags: string[]
  shadow: string
  buttonClass: string
  buttonText: string
}) {
  return (
    <Link
      href={href}
      className={`neo-card block bg-white border-2 border-ink p-6 md:p-8 ${shadow} hover:-translate-y-1 transition-all`}
    >
      <div className="space-y-5">
        <span className={`inline-flex items-center rounded-full px-4 py-1 text-sm font-space font-bold border-2 border-ink ${badgeClass}`}>
          {badge}
        </span>

        <h2 className="font-jakarta text-3xl md:text-4xl font-extrabold text-ink">
          {title}
        </h2>

        <p className="font-nunito text-lg text-ink/80 leading-relaxed">{description}</p>

        <div className="flex flex-wrap gap-2">
          {tags.map((tag) => (
            <span
              key={tag}
              className="rounded-full border-2 border-ink bg-white px-3 py-1 text-xs font-space font-bold text-ink"
            >
              {tag}
            </span>
          ))}
        </div>

        <div className={`inline-flex items-center justify-center border-2 border-ink px-5 py-3 text-sm font-space font-bold ${buttonClass}`}>
          {buttonText}
        </div>
      </div>
    </Link>
  )
}

export default function JoinPage() {
  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      <section className="px-4 pb-20 pt-28 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-6xl">
          <h1 className="text-center font-jakarta text-[40px] font-extrabold leading-tight text-ink md:text-[56px]">
            I am a...
          </h1>

          <div className="mt-10 grid grid-cols-1 gap-8 lg:grid-cols-2">
            <RoleCard
              href="/join/creator"
              badge="🎨 For Creators"
              badgeClass="bg-neon text-ink"
              title="Content Creator"
              description="Get paid to create. Collabs starting at ₹100."
              tags={creatorTags}
              shadow="shadow-[6px_6px_0_#C8FF00]"
              buttonClass="bg-ink text-neon"
              buttonText="Join as Creator →"
            />

            <RoleCard
              href="/join/brand"
              badge="🏢 For Brands"
              badgeClass="bg-pink text-white"
              title="Brand / Startup"
              description="Find creators for campaigns and events."
              tags={brandTags}
              shadow="shadow-[6px_6px_0_#FF2D78]"
              buttonClass="bg-pink text-white"
              buttonText="Join as Brand →"
            />
          </div>

          <p className="mt-10 text-center font-nunito text-base text-ink/80">
            Already have an account?{' '}
            <Link href="/login" className="font-bold text-pink underline underline-offset-4">
              Log in
            </Link>
          </p>
        </div>
      </section>
    </main>
  )
}
