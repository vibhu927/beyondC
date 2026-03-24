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
  const { data: creator, error: readError } = await service
    .from('creator_profiles')
    .select('wallet_balance')
    .eq('id', params.id)
    .single()

  if (readError || !creator) return apiError('Creator not found', 404)

  const nextBalance = (creator.wallet_balance ?? 0) + amount

  const { error: updateError } = await service
    .from('creator_profiles')
    .update({ wallet_balance: nextBalance })
    .eq('id', params.id)

  if (updateError) return apiError(updateError.message)

  const { data: tx, error: txError } = await service
    .from('wallet_transactions')
    .insert({
      creator_id: params.id,
      type: amount > 0 ? 'topup' : 'deduct',
      amount: Math.abs(amount),
      reason: amount > 0 ? 'wallet_topup' : 'collab_fee_deducted',
      balance_after: nextBalance,
    })
    .select()
    .single()

  if (txError) return apiError(txError.message)

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'adjust_wallet',
    targetType: 'user',
    targetId: params.id,
    details: { amount, reason, nextBalance },
  })

  return apiSuccess({ balance: nextBalance, transaction: tx })
}
