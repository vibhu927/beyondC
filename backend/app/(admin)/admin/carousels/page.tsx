import Image from 'next/image'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { createServiceClient } from '@/lib/supabase/service'

export const dynamic = 'force-dynamic'

type PageProps = {
  searchParams?: Promise<{ status?: string; message?: string }>
}

export default async function AdminCarouselsPage({ searchParams }: PageProps) {
  const service = createServiceClient()
  const params = (await searchParams) ?? {}
  const pageStatus = params.status
  const pageMessage = params.message

  const { data: rows } = await service
    .from('home_carousels')
    .select('id,audience,media_url,caption,created_at')
    .eq('is_active', true)
    .order('created_at', { ascending: false })

  const creatorItems = (rows ?? []).filter((item) => item.audience === 'creator')
  const brandItems = (rows ?? []).filter((item) => item.audience === 'brand')

  const renderPanel = (audience: 'creator' | 'brand', items: typeof rows) => (
    <Card>
      <CardHeader>
        <CardTitle>{audience === 'creator' ? 'Creator Carousel' : 'Brand Carousel'}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="rounded-md border border-dashed p-3 text-xs text-zinc-600 dark:text-zinc-400">
          Recommended dimensions: <span className="font-semibold">1200 x 480 px</span> (ratio 2.5:1). Use JPG/PNG/WebP.
        </div>

        <form action="/api/admin/carousels" method="post" encType="multipart/form-data" className="space-y-3">
          <input type="hidden" name="audience" value={audience} />
          <label htmlFor={`file-${audience}`} className="text-sm font-medium">
            Upload Graphic
          </label>
          <Input id={`file-${audience}`} name="file" type="file" accept="image/*" required />
          <label htmlFor={`caption-${audience}`} className="text-sm font-medium">
            Caption (optional)
          </label>
          <Input id={`caption-${audience}`} name="caption" placeholder="Optional short text" />
          <Button type="submit">Upload to {audience === 'creator' ? 'Creator' : 'Brand'} Carousel</Button>
        </form>

        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
          {(items ?? []).map((item) => (
            <div key={item.id} className="rounded-md border p-2">
              <Image src={item.media_url} alt={item.caption || 'carousel media'} width={300} height={112} className="h-28 w-full rounded object-cover" />
              {item.caption ? <p className="mt-2 line-clamp-2 text-xs text-zinc-600 dark:text-zinc-400">{item.caption}</p> : null}
              <form action="/api/admin/carousels" method="post" className="mt-2">
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="id" value={item.id} />
                <Button type="submit" variant="outline" size="sm" className="w-full">
                  Delete
                </Button>
              </form>
            </div>
          ))}
          {(!items || items.length === 0) ? (
            <div className="col-span-full rounded-md border border-dashed p-5 text-center text-sm text-zinc-500">
              No media uploaded yet.
            </div>
          ) : null}
        </div>
      </CardContent>
    </Card>
  )

  return (
    <PermissionGate page="carousels" action="can_view">
      <div className="space-y-6">
        {pageStatus && pageMessage ? (
          <div
            className={`rounded-md border px-3 py-2 text-sm ${
              pageStatus === 'success'
                ? 'border-emerald-500 bg-emerald-50 text-emerald-900'
                : 'border-red-500 bg-red-50 text-red-900'
            }`}
          >
            {pageMessage}
          </div>
        ) : null}
        {renderPanel('brand', brandItems)}
        {renderPanel('creator', creatorItems)}
      </div>
    </PermissionGate>
  )
}
