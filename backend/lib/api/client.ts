interface ApiOptions {
  method?: string
  body?: unknown
  params?: Record<string, string | undefined>
}

export class ApiError extends Error {
  status: number
  constructor(message: string, status: number) {
    super(message)
    this.status = status
  }
}

export async function apiClient<T>(path: string, options: ApiOptions = {}): Promise<T> {
  const { method = 'GET', body, params } = options

  const url = new URL(path, window.location.origin)
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== '') {
        url.searchParams.set(key, value)
      }
    })
  }

  const response = await fetch(url.toString(), {
    method,
    headers: {
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  })

  if (!response.ok) {
    const payload = await response.json().catch(() => ({}))
    throw new ApiError(payload.error || payload.message || 'Request failed', response.status)
  }

  return response.json()
}
