import { cert, getApps, initializeApp } from 'firebase-admin/app'
import { getMessaging } from 'firebase-admin/messaging'

import { createServiceClient } from '@/lib/supabase/service'

type PushPayload = {
  userId: string
  title: string
  body: string
  data?: Record<string, string | number | boolean | null | undefined>
}

function getFirebaseAdminApp() {
  if (getApps().length > 0) {
    return getApps()[0]
  }

  const projectId = process.env.FIREBASE_PROJECT_ID
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n')

  if (!projectId || !clientEmail || !privateKey) {
    throw new Error('Missing Firebase Admin credentials')
  }

  return initializeApp({
    credential: cert({
      projectId,
      clientEmail,
      privateKey,
    }),
  })
}

export async function sendPushNotification({
  userId,
  title,
  body,
  data = {},
}: PushPayload) {
  if (!userId) return

  const supabase = createServiceClient()

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('fcm_token')
    .eq('id', userId)
    .maybeSingle()

  if (profileError || !profile?.fcm_token) {
    return
  }

  const app = getFirebaseAdminApp()

  try {
    await getMessaging(app).send({
      token: profile.fcm_token,
      notification: {
        title,
        body,
      },
      data: Object.entries(data).reduce<Record<string, string>>((acc, [key, value]) => {
        if (value == null) return acc
        acc[key] = String(value)
        return acc
      }, {}),
    })
  } catch (error: any) {
    const code = error?.code?.toString() ?? ''
    const invalidToken =
      code.includes('registration-token-not-registered') ||
      code.includes('invalid-registration-token')

    if (invalidToken) {
      await supabase
        .from('profiles')
        .update({ fcm_token: null })
        .eq('id', userId)
    }
  }
}
