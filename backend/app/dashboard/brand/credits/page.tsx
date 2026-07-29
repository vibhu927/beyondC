'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type CreditData } from '@/lib/api/brand'
import { useState, useCallback } from 'react'

const creditPacks = [
  { credits: 3, price: 149, label: 'Starter', pack: 'starter' },
  { credits: 7, price: 299, label: 'Growth', popular: true, pack: 'growth' },
  { credits: 12, price: 499, label: 'Pro', pack: 'pro' },
]

declare global {
  interface Window {
    Razorpay: any
  }
}

function loadRazorpayScript(): Promise<boolean> {
  return new Promise((resolve) => {
    if (typeof window.Razorpay !== 'undefined') {
      resolve(true)
      return
    }
    const script = document.createElement('script')
    script.src = 'https://checkout.razorpay.com/v1/checkout.js'
    script.async = true
    script.onload = () => resolve(true)
    script.onerror = () => resolve(false)
    document.body.appendChild(script)
  })
}

export default function BrandCreditsPage() {
  const queryClient = useQueryClient()
  const [successMsg, setSuccessMsg] = useState('')
  const [error, setError] = useState('')
  const [isProcessing, setIsProcessing] = useState(false)

  const { data, isLoading } = useQuery({
    queryKey: ['brand', 'credits'],
    queryFn: () => brandApi.getCredits(),
  })

  const verifyMutation = useMutation({
    mutationFn: (params: { razorpay_order_id: string; razorpay_payment_id: string; razorpay_signature: string }) =>
      brandApi.verifyCredits(params.razorpay_order_id, params.razorpay_payment_id, params.razorpay_signature),
    onSuccess: () => {
      setSuccessMsg('Credits purchased successfully!')
      setTimeout(() => setSuccessMsg(''), 4000)
      queryClient.invalidateQueries({ queryKey: ['brand', 'credits'] })
    },
    onError: (e: Error) => {
      setError(e.message)
      setTimeout(() => setError(''), 6000)
    },
  })

  const handleBuy = useCallback(async (pack: string, price: number) => {
    setError('')
    setSuccessMsg('')
    setIsProcessing(true)

    try {
      const loaded = await loadRazorpayScript()
      if (!loaded) {
        setError('Failed to load payment gateway. Please try again.')
        setIsProcessing(false)
        return
      }

      const order = await brandApi.buyCredits(pack)

      const options = {
        key: order.key_id,
        amount: order.amount,
        currency: order.currency,
        name: 'BeyondC',
        description: `${pack.charAt(0).toUpperCase() + pack.slice(1)} Pack — ${order.credits} credits`,
        order_id: order.order_id,
        handler: function (response: any) {
          verifyMutation.mutate({
            razorpay_order_id: response.razorpay_order_id,
            razorpay_payment_id: response.razorpay_payment_id,
            razorpay_signature: response.razorpay_signature,
          })
          setIsProcessing(false)
        },
        modal: {
          ondismiss: function () {
            setError('Payment cancelled.')
            setIsProcessing(false)
          },
        },
        prefill: {
          contact: '',
          email: '',
        },
        theme: {
          color: '#FF2D78',
        },
      }

      const rzp = new window.Razorpay(options)
      rzp.on('payment.failed', function (response: any) {
        setError(response.error.description || 'Payment failed. Please try again.')
        setIsProcessing(false)
      })
      rzp.open()
    } catch (e: any) {
      setError(e.message || 'Failed to initiate payment')
      setIsProcessing(false)
    }
  }, [verifyMutation])

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Credits</h1>
        <p className="mt-1 font-nunito text-base text-muted">Buy credits for campaigns and collabs.</p>
      </div>

      {successMsg && <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">{successMsg}</div>}
      {error && <div className="border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">{error}</div>}

      <div className="border-2 border-ink bg-white p-6 shadow-[6px_6px_0_#FF2D78]">
        <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Credits</p>
        <p className="font-jakarta text-4xl font-extrabold text-ink mt-1">
          {isLoading ? '...' : `${data?.balance ?? 0}`}
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {creditPacks.map((pack) => (
          <div key={pack.label} className={`border-2 border-ink bg-white p-5 relative ${pack.popular ? 'shadow-[5px_5px_0_#FF2D78]' : 'shadow-[3px_3px_0_#0D0D0D]'}`}>
            {pack.popular && (
              <span className="absolute -top-3 right-3 bg-pink text-white px-3 py-0.5 font-space text-[9px] font-bold uppercase border-2 border-ink">
                Popular
              </span>
            )}
            <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">{pack.label}</p>
            <p className="font-jakarta text-3xl font-extrabold text-ink mt-1">{pack.credits}</p>
            <p className="font-jakarta text-lg font-bold text-muted mt-1">credits</p>
            <p className="font-jakarta text-2xl font-extrabold text-ink mt-3">₹{pack.price}</p>
            <button
              onClick={() => handleBuy(pack.pack, pack.price)}
              disabled={isProcessing}
              className={`mt-4 w-full border-2 border-ink px-4 py-3 font-space text-xs font-bold uppercase shadow-[3px_3px_0_#0D0D0D] disabled:opacity-50 ${
                pack.popular ? 'bg-pink text-white' : 'bg-ink text-neon'
              }`}
            >
              {isProcessing ? 'Processing...' : 'Buy'}
            </button>
          </div>
        ))}
      </div>

      <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#0D0D0D]">
        <div className="p-6">
          <h2 className="font-jakarta text-lg font-bold text-ink mb-4">Transaction History</h2>
          {!data?.transactions?.length ? (
            <p className="font-nunito text-sm text-muted">No transactions yet.</p>
          ) : (
            <div className="space-y-2">
              {data.transactions.map((tx: CreditData['transactions'][0]) => (
                <div key={tx.id} className="flex items-center justify-between border-2 border-ink bg-white px-4 py-3">
                  <div>
                    <p className="font-nunito text-sm font-semibold text-ink capitalize">{tx.type}</p>
                    <p className="font-nunito text-xs text-muted">{tx.reason}</p>
                  </div>
                  <span className={`font-jakarta text-sm font-bold ${tx.amount > 0 ? 'text-green-600' : 'text-pink'}`}>
                    {tx.amount > 0 ? '+' : ''}{tx.amount}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
