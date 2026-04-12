'use client'

import { useEffect } from 'react'

const AUTH_HASH_KEYS = [
  'access_token',
  'refresh_token',
  'token_type',
  'expires_in',
  'expires_at',
  'type',
  'error',
  'error_code',
  'error_description',
  'code',
]

export default function RecoveryHashRedirect() {
  useEffect(() => {
    const hash = window.location.hash.replace(/^#/, '')
    if (!hash) {
      return
    }

    const hashParams = new URLSearchParams(hash)
    const hasAuthParams = AUTH_HASH_KEYS.some((key) => hashParams.has(key))

    if (!hasAuthParams) {
      return
    }

    const target = new URL('/reset-password', window.location.origin)
    hashParams.forEach((value, key) => {
      if (value) {
        target.searchParams.set(key, value)
      }
    })

    if (!target.searchParams.has('flow')) {
      target.searchParams.set('flow', 'recovery')
    }

    window.location.replace(target.toString())
  }, [])

  return null
}