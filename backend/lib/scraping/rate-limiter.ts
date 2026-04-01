const scrapeCache = new Map<string, { timestamp: number; data: unknown }>()

const CACHE_TTL_MS = 10 * 60 * 1000

export function getCachedStats<T = unknown>(username: string): T | null {
  const key = username.trim().toLowerCase()
  const cached = scrapeCache.get(key)
  if (!cached) return null

  if (Date.now() - cached.timestamp > CACHE_TTL_MS) {
    scrapeCache.delete(key)
    return null
  }

  return cached.data as T
}

export function setCachedStats(username: string, data: unknown) {
  scrapeCache.set(username.trim().toLowerCase(), {
    timestamp: Date.now(),
    data,
  })
}
