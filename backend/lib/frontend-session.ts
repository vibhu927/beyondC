export type FrontendSession = {
  firstName: string
  fullName: string
  email: string
  role: 'creator' | 'brand'
  createdAt: string
}

const FRONTEND_SESSION_KEY = 'beyondc_frontend_session'
const FRONTEND_SESSION_EVENT = 'beyondc:frontend-session-changed'

export function getFrontendSession(): FrontendSession | null {
  if (typeof window === 'undefined') return null

  try {
    const raw = window.localStorage.getItem(FRONTEND_SESSION_KEY)
    if (!raw) return null

    const parsed = JSON.parse(raw) as FrontendSession
    if (!parsed?.firstName || !parsed?.email || !parsed?.role) {
      return null
    }

    return parsed
  } catch {
    return null
  }
}

export function setFrontendSession(payload: Omit<FrontendSession, 'createdAt'>) {
  if (typeof window === 'undefined') return

  const session: FrontendSession = {
    ...payload,
    createdAt: new Date().toISOString(),
  }

  window.localStorage.setItem(FRONTEND_SESSION_KEY, JSON.stringify(session))
  window.dispatchEvent(new Event(FRONTEND_SESSION_EVENT))
}

export function clearFrontendSession() {
  if (typeof window === 'undefined') return
  window.localStorage.removeItem(FRONTEND_SESSION_KEY)
  window.dispatchEvent(new Event(FRONTEND_SESSION_EVENT))
}

export function onFrontendSessionChange(listener: () => void) {
  if (typeof window === 'undefined') return () => {}

  const wrapped = () => listener()
  window.addEventListener('storage', wrapped)
  window.addEventListener(FRONTEND_SESSION_EVENT, wrapped)

  return () => {
    window.removeEventListener('storage', wrapped)
    window.removeEventListener(FRONTEND_SESSION_EVENT, wrapped)
  }
}
