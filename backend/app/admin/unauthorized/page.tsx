import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function AdminUnauthorizedPage() {
  return (
    <div className="dark flex min-h-screen items-center justify-center bg-zinc-950 p-4">
      <div className="max-w-md rounded-xl border border-zinc-200 bg-white p-8 text-center shadow-sm dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-100">
        <p className="text-4xl">🚫</p>
        <h1 className="mt-2 text-2xl font-bold">Access Denied</h1>
        <p className="mt-3 text-sm text-zinc-600 dark:text-zinc-400">You do not have super-admin access for this page.</p>
        <Link href="/admin/dashboard" className="mt-5 inline-block">
          <Button variant="outline">Back to Dashboard</Button>
        </Link>
      </div>
    </div>
  )
}
