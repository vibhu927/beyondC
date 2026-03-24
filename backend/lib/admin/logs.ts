import { createServiceClient } from '@/lib/supabase/service'

type LogInput = {
  adminId: string
  action: string
  targetType?: string | null
  targetId?: string | null
  details?: Record<string, unknown> | null
}

export async function writeAdminLog(input: LogInput) {
  const service = createServiceClient()

  await service.from('admin_logs').insert({
    admin_id: input.adminId,
    action: input.action,
    target_type: input.targetType ?? null,
    target_id: input.targetId ?? null,
    details: input.details ?? null,
  })
}
