import Link from 'next/link'

type PageProps = {
  searchParams: {
    status?: string
    username?: string
  }
}

export default function InstagramConnectPage({ searchParams }: PageProps) {
  const status = searchParams.status
  const username = searchParams.username
  const isSuccess = status === 'success'

  return (
    <main className="min-h-screen bg-white px-4 py-16">
      <div className="mx-auto max-w-lg border-2 border-ink bg-white p-8 shadow-[6px_6px_0_#C8FF00]">
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Instagram Connection</h1>
        <p className="mt-3 font-nunito text-base text-ink/80">
          {isSuccess
            ? `Your Instagram account${username ? ` @${username}` : ''} is verified. Stats are being fetched.`
            : 'Instagram connection failed. Please try again from your creator dashboard.'}
        </p>

        <div className="mt-8">
          <Link
            href="/login"
            className="inline-flex border-2 border-ink bg-neon px-4 py-2 font-space text-xs font-bold uppercase tracking-[0.08em] text-ink shadow-[4px_4px_0_#0D0D0D]"
          >
            Return to App
          </Link>
        </div>
      </div>
    </main>
  )
}
