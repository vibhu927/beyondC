import { createServiceClient } from '@/lib/supabase/service'
import { NotificationsClient } from '@/app/(admin)/admin/notifications/notifications-client'

export default async function AdminNotificationsPage() {
  const service = createServiceClient()

  const { data: pushHistory } = await service
    .from('admin_logs')
    .select('id,action,details,admin_id,created_at')
    .eq('action', 'send_notification')
    .order('created_at', { ascending: false })
    .limit(20)

  const { data: emailHistory } = await service
    .from('admin_logs')
    .select('id,action,details,admin_id,created_at')
    .eq('action', 'sent_promotional_email')
    .order('created_at', { ascending: false })
    .limit(50)

  return <NotificationsClient pushHistory={pushHistory ?? []} emailHistory={emailHistory ?? []} />
}
