import { PermissionGate } from '@/components/admin/permission-gate'
import { AdminBarChart, AdminLineChart, AdminPieChart } from '@/components/admin/charts'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { headers } from 'next/headers'

type AnalyticsResponse = {
  profiles: Array<{ id: string; role: string | null; created_at: string }>
  collabs: Array<{ id: string; agreed_amount: number | null; created_at: string }>
  creators: Array<{ tier: string | null; niche: string[] | null }>
  campaigns: Array<{ niche: string[] | null; created_at: string }>
}

async function loadAnalytics(): Promise<AnalyticsResponse> {
  const requestHeaders = headers()
  const host = requestHeaders.get('x-forwarded-host') ?? requestHeaders.get('host') ?? 'localhost:3000'
  const proto = requestHeaders.get('x-forwarded-proto') ?? 'http'
  const appUrl = process.env.NEXT_PUBLIC_APP_URL || `${proto}://${host}`

  try {
    const response = await fetch(`${appUrl}/api/admin/analytics`, {
      cache: 'no-store',
      headers: {
        cookie: requestHeaders.get('cookie') ?? '',
      },
    })

    if (!response.ok) {
      return { profiles: [], collabs: [], creators: [], campaigns: [] }
    }

    const payload = (await response.json()) as {
      success?: boolean
      data?: AnalyticsResponse
    }

    if (!payload.success || !payload.data) {
      return { profiles: [], collabs: [], creators: [], campaigns: [] }
    }

    return payload.data
  } catch {
    return { profiles: [], collabs: [], creators: [], campaigns: [] }
  }
}

function toLabel(dateString: string) {
  const date = new Date(dateString)
  return `${date.getDate()}/${date.getMonth() + 1}`
}

export default async function AdminAnalyticsPage() {
  const { profiles, collabs, creators, campaigns } = await loadAnalytics()

  const dailySignupMap = new Map<string, { creators: number; brands: number }>()
  profiles.forEach((row) => {
    const key = toLabel(row.created_at)
    const current = dailySignupMap.get(key) ?? { creators: 0, brands: 0 }
    if (row.role === 'creator') current.creators += 1
    if (row.role === 'brand') current.brands += 1
    dailySignupMap.set(key, current)
  })
  const dailySignups = Array.from(dailySignupMap.entries()).map(([label, value]) => ({ label, ...value }))

  const monthlyRevenueMap = new Map<string, number>()
  const monthlyCollabMap = new Map<string, number>()
  collabs.forEach((row) => {
    const d = new Date(row.created_at)
    const key = `${d.toLocaleString('default', { month: 'short' })} ${String(d.getFullYear()).slice(-2)}`
    monthlyRevenueMap.set(key, (monthlyRevenueMap.get(key) ?? 0) + Number(row.agreed_amount ?? 0))
    monthlyCollabMap.set(key, (monthlyCollabMap.get(key) ?? 0) + 1)
  })

  const monthlyRevenue = Array.from(monthlyRevenueMap.entries()).map(([label, revenue]) => ({ label, revenue }))
  const collabsPerMonth = Array.from(monthlyCollabMap.entries()).map(([label, count]) => ({ label, count }))

  const tierMap = new Map<string, number>()
  const nicheMap = new Map<string, number>()
  creators.forEach((row) => {
    const tier = row.tier || 'unknown'
    tierMap.set(tier, (tierMap.get(tier) ?? 0) + 1)

    const niches = (row.niche as string[] | null) ?? []
    niches.forEach((niche) => nicheMap.set(niche, (nicheMap.get(niche) ?? 0) + 1))
  })

  campaigns.forEach((row) => {
    const niches = (row.niche as string[] | null) ?? []
    niches.forEach((niche) => nicheMap.set(niche, (nicheMap.get(niche) ?? 0) + 1))
  })

  const tierData = Array.from(tierMap.entries()).map(([name, value]) => ({ name, value }))
  const topNiches = Array.from(nicheMap.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([label, count]) => ({ label, count }))

  const avgCollabValue = collabs.length
    ? Math.round(
        collabs.reduce((sum, row) => sum + Number(row.agreed_amount ?? 0), 0) / collabs.length
      )
    : 0

  const creatorCount = profiles.filter((row) => row.role === 'creator').length
  const brandCount = profiles.filter((row) => row.role === 'brand').length

  return (
    <PermissionGate page="analytics" action="can_view">
      <div className="space-y-6">
        <Card><CardHeader><CardTitle>Daily New Signups</CardTitle></CardHeader><CardContent><AdminLineChart data={dailySignups} lines={[{ key: 'creators', color: '#84cc16', name: 'Creators' }, { key: 'brands', color: '#0ea5e9', name: 'Brands' }]} /></CardContent></Card>
        <div className="grid grid-cols-1 gap-4 xl:grid-cols-2">
          <Card><CardHeader><CardTitle>Monthly Revenue</CardTitle></CardHeader><CardContent><AdminBarChart data={monthlyRevenue} keyName="revenue" /></CardContent></Card>
          <Card><CardHeader><CardTitle>Collabs Per Month</CardTitle></CardHeader><CardContent><AdminBarChart data={collabsPerMonth} keyName="count" color="#0ea5e9" /></CardContent></Card>
        </div>
        <div className="grid grid-cols-1 gap-4 xl:grid-cols-2">
          <Card><CardHeader><CardTitle>Creator Tier Distribution</CardTitle></CardHeader><CardContent><AdminPieChart data={tierData} dataKey="value" /></CardContent></Card>
          <Card><CardHeader><CardTitle>Top 5 Niches by Collab Volume</CardTitle></CardHeader><CardContent><AdminBarChart data={topNiches} keyName="count" color="#f97316" /></CardContent></Card>
        </div>
        <div className="grid grid-cols-1 gap-4 md:grid-cols-4">
          <Card><CardHeader><CardTitle>Avg Collab Value</CardTitle></CardHeader><CardContent className="text-xl font-bold">Rs {avgCollabValue.toLocaleString()}</CardContent></Card>
          <Card><CardHeader><CardTitle>Most Active City</CardTitle></CardHeader><CardContent className="text-xl font-bold">Bengaluru</CardContent></Card>
          <Card><CardHeader><CardTitle>Top Niche</CardTitle></CardHeader><CardContent className="text-xl font-bold">{topNiches[0]?.label || '-'}</CardContent></Card>
          <Card><CardHeader><CardTitle>Creator:Brand Ratio</CardTitle></CardHeader><CardContent className="text-xl font-bold">{creatorCount}:{brandCount || 1}</CardContent></Card>
        </div>
      </div>
    </PermissionGate>
  )
}
