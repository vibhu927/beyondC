'use client'

import { useQuery } from '@tanstack/react-query'
import { notificationsApi, type Notification } from '@/lib/api/notifications'
import { useState } from 'react'

export default function NotificationsPage() {
  const [page, setPage] = useState(1)

  const { data, isLoading } = useQuery({
    queryKey: ['notifications', page],
    queryFn: () => notificationsApi.getAll({ page: String(page), limit: '20' }),
  })

  const notifications = data?.notifications || []
  const pagination = data?.pagination

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-jakarta text-3xl font-extrabold text-ink">Notifications</h1>
          <p className="mt-1 font-nunito text-base text-muted">Stay updated with your activity.</p>
        </div>
      </div>

      <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#FF2D78]">
        {isLoading ? (
          <div className="p-8 text-center">
            <p className="font-nunito text-muted">Loading notifications...</p>
          </div>
        ) : notifications.length === 0 ? (
          <div className="p-8 text-center">
            <p className="text-2xl mb-2">🔔</p>
            <p className="font-nunito text-muted">No notifications yet.</p>
          </div>
        ) : (
          <div className="divide-y-2 divide-ink">
            {notifications.map((notification: Notification) => (
              <div
                key={notification.id}
                className={`px-6 py-4 ${
                  !notification.is_read ? 'bg-pink/10' : ''
                }`}
              >
                <div className="flex items-start gap-3">
                  <div className={`mt-1 w-2 h-2 rounded-full flex-shrink-0 ${
                    !notification.is_read ? 'bg-pink' : 'bg-transparent'
                  }`} />
                  <div className="flex-1 min-w-0">
                    <p className="font-nunito text-sm font-semibold text-ink">{notification.title}</p>
                    <p className="font-nunito text-sm text-muted mt-0.5">{notification.body}</p>
                    <p className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted/60 mt-1">
                      {new Date(notification.created_at).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {pagination && pagination.totalPages > 1 && (
        <div className="flex items-center justify-center gap-3">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page === 1}
            className="border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink disabled:opacity-50"
          >
            ← Previous
          </button>
          <span className="font-nunito text-sm text-muted">
            Page {page} of {pagination.totalPages}
          </span>
          <button
            onClick={() => setPage((p) => Math.min(pagination.totalPages, p + 1))}
            disabled={page === pagination.totalPages}
            className="border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink disabled:opacity-50"
          >
            Next →
          </button>
        </div>
      )}
    </div>
  )
}
