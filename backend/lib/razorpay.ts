import Razorpay from 'razorpay'

function normalizeEnv(value?: string) {
  if (!value) return ''
  const trimmed = value.trim()
  if (
    (trimmed.startsWith('"') && trimmed.endsWith('"')) ||
    (trimmed.startsWith("'") && trimmed.endsWith("'"))
  ) {
    return trimmed.slice(1, -1).trim()
  }
  return trimmed
}

export function getRazorpay() {
  const keyId = normalizeEnv(process.env.RAZORPAY_KEY_ID || process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID)
  const keySecret = normalizeEnv(process.env.RAZORPAY_KEY_SECRET)

  if (!keyId || !keySecret) {
    throw new Error(
      'Razorpay keys are not configured. Set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in backend .env.local.',
    )
  }

  return new Razorpay({
    key_id: keyId,
    key_secret: keySecret,
  })
}
