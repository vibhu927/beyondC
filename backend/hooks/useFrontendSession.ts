'use client'

import { useEffect, useState } from 'react'
import { FrontendSession, getFrontendSession, onFrontendSessionChange } from '@/lib/frontend-session'

export function useFrontendSession() {
  const [session, setSession] = useState<FrontendSession | null>(null)

  useEffect(() => {
    setSession(getFrontendSession())
    return onFrontendSessionChange(() => {
      setSession(getFrontendSession())
    })
  }, [])

  return {
    session,
    hasSession: Boolean(session),
  }
}
