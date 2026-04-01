import Link from 'next/link'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export const dynamic = 'force-dynamic'
export const revalidate = 0

const PAGE_SIZE = 20

export default async function AdminUsersPage({
  searchParams,
}: {
  searchParams: {
    tab?: string
    q?: string
    tier?: string
    niche?: string
    status?: string
    page?: string
  }
}) {
  const tab = searchParams.tab === 'brands' ? 'brands' : 'creators'
  const query = searchParams.q ?? ''
  const page = Number(searchParams.page ?? '1') || 1
  const from = (page - 1) * PAGE_SIZE
  const to = from + PAGE_SIZE - 1
  const creatorsTabHref = `/admin/users?tab=creators${query ? `&q=${encodeURIComponent(query)}` : ''}`
  const brandsTabHref = `/admin/users?tab=brands${query ? `&q=${encodeURIComponent(query)}` : ''}`

  const service = createServiceClient()

  let creatorQuery = service
    .from('profiles')
    .select('id,full_name,email,created_at,is_suspended,creator_profiles(tier,follower_count,wallet_balance,niche,total_collabs)', {
      count: 'exact',
    })
    .eq('role', 'creator')
    .order('created_at', { ascending: false })
    .range(from, to)

  if (query) {
    creatorQuery = creatorQuery.or(`full_name.ilike.%${query}%,email.ilike.%${query}%`)
  }

  let brandQuery = service
    .from('profiles')
    .select('id,full_name,email,created_at,is_suspended,brand_profiles(brand_name,credit_balance,is_brand_verified,total_collabs)', {
      count: 'exact',
    })
    .eq('role', 'brand')
    .order('created_at', { ascending: false })
    .range(from, to)

  if (query) {
    brandQuery = brandQuery.or(`full_name.ilike.%${query}%,email.ilike.%${query}%`)
  }

  const [creatorsResult, brandsResult] = await Promise.all([creatorQuery, brandQuery])

  const creators = creatorsResult.data ?? []
  const brands = brandsResult.data ?? []

  return (
    <PermissionGate page="users" action="can_view">
      <Card>
        <CardHeader>
          <CardTitle>Users</CardTitle>
          <form className="mt-3 flex flex-wrap gap-2">
            <input type="hidden" name="tab" value={tab} />
            <Input name="q" defaultValue={query} placeholder="Search users by name or email" className="max-w-sm" />
            <Button type="submit" variant="outline">Search</Button>
          </form>
        </CardHeader>
        <CardContent>
          <Tabs value={tab}>
            <TabsList>
              <TabsTrigger value="creators" asChild><Link href={creatorsTabHref}>Creators</Link></TabsTrigger>
              <TabsTrigger value="brands" asChild><Link href={brandsTabHref}>Brands</Link></TabsTrigger>
            </TabsList>

            <TabsContent value="creators">
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Name</TableHead>
                      <TableHead>Email</TableHead>
                      <TableHead>Tier</TableHead>
                      <TableHead>Followers</TableHead>
                      <TableHead>Wallet</TableHead>
                      <TableHead>Collabs</TableHead>
                      <TableHead>Joined</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {creators.map((user: any) => {
                      const creator = Array.isArray(user.creator_profiles)
                        ? user.creator_profiles[0]
                        : user.creator_profiles

                      return (
                        <TableRow key={user.id}>
                          <TableCell>{user.full_name || 'Unnamed'}</TableCell>
                          <TableCell>{user.email}</TableCell>
                          <TableCell>{creator?.tier || '-'}</TableCell>
                          <TableCell>{creator?.follower_count || 0}</TableCell>
                          <TableCell>Rs {(creator?.wallet_balance || 0).toLocaleString()}</TableCell>
                          <TableCell>{creator?.total_collabs || 0}</TableCell>
                          <TableCell>{new Date(user.created_at).toLocaleDateString()}</TableCell>
                          <TableCell>
                            <Badge className={user.is_suspended ? 'border-red-300 text-red-600' : 'border-green-300 text-green-700'}>
                              {user.is_suspended ? 'Suspended' : 'Active'}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <div className="flex gap-2">
                              <Link href={`/admin/users/${user.id}`}><Button size="sm" variant="outline">View</Button></Link>
                              <form action={`/api/admin/users/${user.id}/suspend`} method="post">
                                <Button size="sm" variant="outline">{user.is_suspended ? 'Unsuspend' : 'Suspend'}</Button>
                              </form>
                            </div>
                          </TableCell>
                        </TableRow>
                      )
                    })}
                  </TableBody>
                </Table>
              </div>
            </TabsContent>

            <TabsContent value="brands">
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Name</TableHead>
                      <TableHead>Email</TableHead>
                      <TableHead>Brand</TableHead>
                      <TableHead>Credits</TableHead>
                      <TableHead>Collabs</TableHead>
                      <TableHead>Joined</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {brands.map((user: any) => {
                      const brand = Array.isArray(user.brand_profiles)
                        ? user.brand_profiles[0]
                        : user.brand_profiles

                      return (
                        <TableRow key={user.id}>
                          <TableCell>{user.full_name || 'Unnamed'}</TableCell>
                          <TableCell>{user.email}</TableCell>
                          <TableCell>{brand?.brand_name || '-'}</TableCell>
                          <TableCell>{brand?.credit_balance || 0}</TableCell>
                          <TableCell>{brand?.total_collabs || 0}</TableCell>
                          <TableCell>{new Date(user.created_at).toLocaleDateString()}</TableCell>
                          <TableCell>
                            <Badge className={user.is_suspended ? 'border-red-300 text-red-600' : 'border-green-300 text-green-700'}>
                              {user.is_suspended ? 'Suspended' : 'Active'}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <div className="flex gap-2">
                              <Link href={`/admin/users/${user.id}`}><Button size="sm" variant="outline">View</Button></Link>
                              <form action={`/api/admin/users/${user.id}/verify`} method="post">
                                <Button size="sm" variant="outline">{brand?.is_brand_verified ? 'Unverify' : 'Verify'}</Button>
                              </form>
                            </div>
                          </TableCell>
                        </TableRow>
                      )
                    })}
                  </TableBody>
                </Table>
              </div>
            </TabsContent>
          </Tabs>

          <div className="mt-4 flex items-center justify-between text-sm text-zinc-600 dark:text-zinc-400">
            <p>
              Showing page {page}. Creators: {creatorsResult.count ?? 0}, Brands: {brandsResult.count ?? 0}
            </p>
            <div className="flex gap-2">
              {page > 1 && (
                <Link href={`/admin/users?tab=${tab}&q=${encodeURIComponent(query)}&page=${page - 1}`}>
                  <Button variant="outline" size="sm">Previous</Button>
                </Link>
              )}
              <Link href={`/admin/users?tab=${tab}&q=${encodeURIComponent(query)}&page=${page + 1}`}>
                <Button variant="outline" size="sm">Next</Button>
              </Link>
            </div>
          </div>
        </CardContent>
      </Card>
    </PermissionGate>
  )
}
