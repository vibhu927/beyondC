'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { creatorApi, type WalletData } from '@/lib/api/creator'
import { useState, useCallback } from 'react'

const topupAmounts = [500, 1000, 2000, 5000]

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

export default function CreatorWalletPage() {
  const queryClient = useQueryClient()
  const [customAmount, setCustomAmount] = useState('')
  const [topupError, setTopupError] = useState('')
  const [successMsg, setSuccessMsg] = useState('')
  const [isProcessing, setIsProcessing] = useState(false)

  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'wallet'],
    queryFn: () => creatorApi.getWallet(),
  })

  const verifyMutation = useMutation({
    mutationFn: (params: { razorpay_order_id: string; razorpay_payment_id: string; razorpay_signature: string }) =>
      creatorApi.verifyTopup(params.razorpay_order_id, params.razorpay_payment_id, params.razorpay_signature),
    onSuccess: () => {
      setSuccessMsg('Wallet top-up successful!')
      setCustomAmount('')
      setTimeout(() => setSuccessMsg(''), 4000)
      queryClient.invalidateQueries({ queryKey: ['creator', 'wallet'] })
    },
    onError: (e: Error) => {
      setTopupError(e.message)
      setTimeout(() => setTopupError(''), 6000)
    },
  })

  const MIN_AMOUNT_INR = 100

  const handleTopup = useCallback(async (amountInr: number) => {
    setTopupError('')
    setSuccessMsg('')
    setIsProcessing(true)

    if (amountInr < MIN_AMOUNT_INR) {
      setTopupError(`Minimum top-up amount is ₹${MIN_AMOUNT_INR}.`)
      setIsProcessing(false)
      return
    }

    try {
      const loaded = await loadRazorpayScript()
      if (!loaded) {
        setTopupError('Failed to load payment gateway. Please try again.')
        setIsProcessing(false)
        return
      }

      const order = await creatorApi.createTopup(amountInr * 100)

      const options = {
        key: order.key_id,
        amount: order.amount,
        currency: order.currency,
        name: 'BeyondC',
        description: `Wallet top-up (₹${amountInr})`,
        order_id: order.order_id,
        handler: function (response: any) {
          verifyMutation.mutate({
            razorpay_order_id: response.razorpay_order_id,
            razorpay_payment_id: response.razorpay_payment_id,
            razorpay_signature: response.razorpay_signature,
          })
        },
        modal: {
          ondismiss: function () {
            setTopupError('Payment cancelled.')
            setIsProcessing(false)
          },
        },
        prefill: {
          contact: '',
          email: '',
        },
        theme: {
          color: '#C8FF00',
        },
      }

      const rzp = new window.Razorpay(options)
      rzp.on('payment.failed', function (response: any) {
        setTopupError(response.error.description || 'Payment failed. Please try again.')
        setIsProcessing(false)
      })
      rzp.open()
    } catch (e: any) {
      const msg = e.message || ''
      if (msg.includes('greater than') || msg.includes('10000') || msg.includes('minimum')) {
        setTopupError(`Minimum top-up amount is ₹${MIN_AMOUNT_INR}.`)
      } else {
        setTopupError(msg)
      }
      setIsProcessing(false)
    }
  }, [verifyMutation])

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Wallet</h1>
        <p className="mt-1 font-nunito text-base text-muted">Manage your earnings and top-ups.</p>
      </div>

      {successMsg && (
        <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">
          {successMsg}
        </div>
      )}
      {topupError && (
        <div className="border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
          {topupError}
        </div>
      )}

      <div className="border-2 border-ink bg-ink p-6 sm:p-8 shadow-[6px_6px_0_#C8FF00]">
        <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-neon/70">Balance</p>
        <p className="font-jakarta text-4xl font-extrabold text-neon mt-1">
          ₹{((data?.balance || 0) / 100).toLocaleString()}
        </p>
      </div>

      <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#0D0D0D]">
        <h2 className="font-jakarta text-lg font-bold text-ink mb-4">Quick Top-up</h2>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          {topupAmounts.map((amount) => (
            <button
              key={amount}
              onClick={() => handleTopup(amount)}
              disabled={isProcessing}
              className="border-2 border-ink bg-white px-4 py-3 font-jakarta text-base font-bold text-ink hover:shadow-[3px_3px_0_#C8FF00] transition-all disabled:opacity-50"
            >
              ₹{amount}
            </button>
          ))}
        </div>
        <div className="mt-4 flex gap-3">
          <input
            type="number"
            value={customAmount}
            onChange={(e) => setCustomAmount(e.target.value)}
            placeholder="Custom amount"
            className="flex-1 border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none"
          />
          <button
            onClick={() => handleTopup(Number(customAmount))}
            disabled={isProcessing || !customAmount || Number(customAmount) <= 0}
            className="border-2 border-ink bg-ink px-6 py-3 font-space text-xs font-bold uppercase text-neon disabled:opacity-50"
          >
            {isProcessing ? 'Processing...' : 'Add'}
          </button>
        </div>
      </div>

      <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#C8FF00]">
        <div className="p-6">
          <h2 className="font-jakarta text-lg font-bold text-ink mb-4">Transaction History</h2>
          {!data?.transactions?.length ? (
            <p className="font-nunito text-sm text-muted">No transactions yet.</p>
          ) : (
            <div className="space-y-2">
              {data.transactions.map((tx: WalletData['transactions'][0]) => (
                <div key={tx.id} className="flex items-center justify-between border-2 border-ink bg-white px-4 py-3">
                  <div>
                    <p className="font-nunito text-sm font-semibold text-ink capitalize">{tx.type}</p>
                    <p className="font-nunito text-xs text-muted">{tx.reason.replace(/_/g, ' ')}</p>
                  </div>
                  <span className={`font-jakarta text-sm font-bold ${tx.amount > 0 ? 'text-green-600' : 'text-pink'}`}>
                    {tx.amount > 0 ? '+' : ''}₹{(tx.amount / 100).toLocaleString()}
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
