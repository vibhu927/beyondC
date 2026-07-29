import { apiClient } from './client'

export interface Notification {
  id: string
  user_id: string
  title: string
  body: string
  type: string
  reference_type: string | null
  reference_id: string | null
  is_read: boolean
  created_at: string
}

export const notificationsApi = {
  getAll: (params?: { unread_only?: string; page?: string; limit?: string }) =>
    apiClient<{ notifications: Notification[]; pagination: { page: number; limit: number; total: number; totalPages: number } }>(
      '/api/notifications',
      { params }
    ),

  markRead: (id: string) =>
    apiClient<{ message: string }>(`/api/notifications/${id}`, {
      method: 'PUT',
    }),

  markAllRead: () =>
    apiClient<{ message: string }>('/api/notifications/read-all', {
      method: 'PUT',
    }),
}
