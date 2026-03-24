import { NextRequest } from 'next/server'

export async function parseRequestBody(request: NextRequest): Promise<Record<string, any>> {
  const contentType = request.headers.get('content-type') || ''

  if (contentType.includes('application/json')) {
    return await request.json()
  }

  if (contentType.includes('application/x-www-form-urlencoded') || contentType.includes('multipart/form-data')) {
    const formData = await request.formData()
    const out: Record<string, any> = {}
    formData.forEach((value, key) => {
      out[key] = typeof value === 'string' ? value : value.name
    })
    return out
  }

  return {}
}
