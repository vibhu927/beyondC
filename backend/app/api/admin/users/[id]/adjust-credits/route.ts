import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'
import { parseRequestBody } from '@/lib/admin/request'

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const payload = await parseRequestBody(request)
  const amount = Number(payload.amount ?? 0)
  const reason = String(payload.reason ?? 'admin_adjustment')

  if (!Number.isFinite(amount) || amount === 0) {
    return apiError('Amount is required and cannot be zero')
  }

  const service = createServiceClient()
  const { data: brand, error: readError } = await service
    .from('brand_profiles')
    .select('credit_balance')
    .eq('id', params.id)
    .single()

  if (readError || !brand) return apiError('Brand not found', 404)

  const nextBalance = (brand.credit_balance ?? 0) + amount

  const { error: updateError } = await service
    .from('brand_profiles')
    .update({ credit_balance: nextBalance })
    .eq('id', params.id)

  if (updateError) return apiError(updateError.message)

  const { data: tx, error: txError } = await service
    .from('credit_transactions')
    .insert({
      brand_id: params.id,
      type: amount > 0 ? 'topup' : 'deduct',
      amount: Math.abs(amount),
      reason: amount > 0 ? 'credit_pack_purchase' : 'refund',
      balance_after: nextBalance,
    })
    .select()
    .single()

  if (txError) return apiError(txError.message)

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'adjust_credits',
    targetType: 'user',
    targetId: params.id,
    details: { amount, reason, nextBalance },
  })

  return apiSuccess({ balance: nextBalance, transaction: tx })
}
