import { NextRequest, NextResponse } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'
import { parseRequestBody } from '@/lib/admin/request'

function shouldReturnJson(request: NextRequest): boolean {
  const contentType = request.headers.get('content-type') || ''
  const accept = request.headers.get('accept') || ''
  return contentType.includes('application/json') || accept.includes('application/json')
}

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const payload = await parseRequestBody(request)
  const amount = Number(payload.amount ?? 0)
  const adminReason = String(payload.reason ?? 'admin_adjustment')

  if (!Number.isFinite(amount) || amount === 0) {
    return apiError('Amount is required and cannot be zero')
  }

  const service = createServiceClient()

  let { data: brand, error: readError } = await service
    .from('brand_profiles')
    .select('credit_balance')
    .eq('id', params.id)
    .maybeSingle()

  if (readError) return apiError(readError.message)

  if (!brand) {
    const { data: profile, error: profileError } = await service
      .from('profiles')
      .select('role,full_name,email')
      .eq('id', params.id)
      .maybeSingle()

    if (profileError) return apiError(profileError.message)
    if (!profile) return apiError('User not found', 404)
    if (profile.role !== 'brand') {
      return apiError('Selected user is not a brand', 400)
    }

    const fallbackBrandName =
      (profile.full_name && profile.full_name.trim()) ||
      (profile.email && profile.email.split('@')[0]) ||
      'Brand'

    const { data: createdBrand, error: createBrandError } = await service
      .from('brand_profiles')
      .insert({
        id: params.id,
        brand_name: fallbackBrandName,
        credit_balance: 0,
      })
      .select('credit_balance')
      .single()

    if (createBrandError) return apiError(createBrandError.message)
    brand = createdBrand
  }

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
    details: { amount, adminReason, nextBalance },
  })

  if (!shouldReturnJson(request)) {
    const url = new URL('/admin/users?tab=brands', request.url)
    return NextResponse.redirect(url, 303)
  }

  return apiSuccess({ balance: nextBalance, transaction: tx })
}
