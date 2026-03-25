import { NextRequest, NextResponse } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'
import { parseRequestBody } from '@/lib/admin/request'

function redirectWithMessage(request: NextRequest, type: 'success' | 'error', message: string) {
  const url = new URL('/admin/wallets', request.url)
  url.searchParams.set(type, message)
  return NextResponse.redirect(url)
}

export async function POST(request: NextRequest) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) {
    return redirectWithMessage(request, 'error', auth.error)
  }

  const payload = await parseRequestBody(request)
  const targetType = String(payload.targetType ?? '')
  const targetId = String(payload.targetId ?? '')
  const amount = Number(payload.amount ?? 0)
  const adminReason = String(payload.reason ?? 'admin_manual_topup')

  if (!(targetType === 'brand' || targetType === 'creator')) {
    return redirectWithMessage(request, 'error', 'Invalid target type')
  }

  if (!targetId) {
    return redirectWithMessage(request, 'error', 'Target user is required')
  }

  if (!Number.isFinite(amount) || amount <= 0) {
    return redirectWithMessage(request, 'error', 'Amount must be greater than zero')
  }

  const service = createServiceClient()

  if (targetType === 'creator') {
    const { data: creator, error: readError } = await service
      .from('creator_profiles')
      .select('wallet_balance')
      .eq('id', targetId)
      .single()

    if (readError || !creator) {
      return redirectWithMessage(request, 'error', 'Creator not found')
    }

    const nextBalance = (creator.wallet_balance ?? 0) + amount

    const { error: updateError } = await service
      .from('creator_profiles')
      .update({ wallet_balance: nextBalance })
      .eq('id', targetId)

    if (updateError) {
      return redirectWithMessage(request, 'error', updateError.message)
    }

    const { error: txError } = await service.from('wallet_transactions').insert({
      creator_id: targetId,
      type: 'topup',
      amount,
      reason: 'wallet_topup',
      balance_after: nextBalance,
    })

    if (txError) {
      return redirectWithMessage(request, 'error', txError.message)
    }

    await writeAdminLog({
      adminId: auth.context.userId,
      action: 'admin_manual_wallet_topup',
      targetType: 'user',
      targetId,
      details: { targetType, amount, adminReason, nextBalance },
    })

    return redirectWithMessage(request, 'success', `Creator wallet topped up by ${amount}`)
  }

  let { data: brand, error: readError } = await service
    .from('brand_profiles')
    .select('credit_balance')
    .eq('id', targetId)
    .maybeSingle()

  if (readError) {
    return redirectWithMessage(request, 'error', readError.message)
  }

  if (!brand) {
    const { data: profile, error: profileError } = await service
      .from('profiles')
      .select('role,full_name,email')
      .eq('id', targetId)
      .maybeSingle()

    if (profileError) {
      return redirectWithMessage(request, 'error', profileError.message)
    }

    if (!profile) {
      return redirectWithMessage(request, 'error', 'User not found')
    }

    if (profile.role !== 'brand') {
      return redirectWithMessage(request, 'error', 'Selected user is not a brand')
    }

    const fallbackBrandName =
      (profile.full_name && profile.full_name.trim()) ||
      (profile.email && profile.email.split('@')[0]) ||
      'Brand'

    const { data: createdBrand, error: createBrandError } = await service
      .from('brand_profiles')
      .insert({
        id: targetId,
        brand_name: fallbackBrandName,
        credit_balance: 0,
      })
      .select('credit_balance')
      .single()

    if (createBrandError) {
      return redirectWithMessage(request, 'error', createBrandError.message)
    }

    brand = createdBrand
  }

  const nextBalance = (brand.credit_balance ?? 0) + amount

  const { error: updateError } = await service
    .from('brand_profiles')
    .update({ credit_balance: nextBalance })
    .eq('id', targetId)

  if (updateError) {
    return redirectWithMessage(request, 'error', updateError.message)
  }

  const { error: txError } = await service.from('credit_transactions').insert({
    brand_id: targetId,
    type: 'topup',
    amount,
    reason: 'credit_pack_purchase',
    balance_after: nextBalance,
  })

  if (txError) {
    return redirectWithMessage(request, 'error', txError.message)
  }

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'admin_manual_credit_topup',
    targetType: 'user',
    targetId,
    details: { targetType, amount, adminReason, nextBalance },
  })

  return redirectWithMessage(request, 'success', `Brand credits topped up by ${amount}`)
}
