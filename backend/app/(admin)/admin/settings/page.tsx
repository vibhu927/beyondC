import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminSettingsPage() {
  const service = createServiceClient()
  const { data: settings } = await service.from('platform_settings').select('*').order('key', { ascending: true })

  const byKey = new Map((settings ?? []).map((row) => [row.key, row]))

  return (
    <PermissionGate page="settings" action="can_view">
      <div className="space-y-4">
        {['credit_packs', 'collab_fees', 'wallet_topups', 'maintenance_mode', 'featured_creators'].map((key) => {
          const row = byKey.get(key)
          return (
            <Card key={key}>
              <CardHeader><CardTitle>{row?.label || key}</CardTitle></CardHeader>
              <CardContent>
                <form action="/api/admin/settings" method="post" className="space-y-3">
                  <input type="hidden" name="key" value={key} />
                  <Input name="label" defaultValue={row?.label || ''} placeholder="Display label" />
                  <Textarea name="value" defaultValue={JSON.stringify(row?.value ?? {}, null, 2)} className="min-h-[180px] font-mono text-xs" />
                  <Button type="submit">Save Changes</Button>
                </form>
              </CardContent>
            </Card>
          )
        })}
      </div>
    </PermissionGate>
  )
}
