'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { collabApi, type Message } from '@/lib/api/collab'
import { useFrontendSession } from '@/hooks/useFrontendSession'
import { useState, useRef, useEffect } from 'react'

export function ChatWindow({ collabId, accentColor = '#C8FF00' }: { collabId: string; accentColor?: string }) {
  const { session } = useFrontendSession()
  const queryClient = useQueryClient()
  const [text, setText] = useState('')
  const bottomRef = useRef<HTMLDivElement>(null)

  const { data, isLoading } = useQuery({
    queryKey: ['collab-messages', collabId],
    queryFn: () => collabApi.getMessages(collabId),
    refetchInterval: 5000,
  })

  const sendMutation = useMutation({
    mutationFn: (content: string) => collabApi.sendMessage(collabId, content),
    onSuccess: () => {
      setText('')
      queryClient.invalidateQueries({ queryKey: ['collab-messages', collabId] })
    },
  })

  const messages = data?.messages || []

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages.length])

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault()
    if (!text.trim() || sendMutation.isPending) return
    sendMutation.mutate(text.trim())
  }

  if (isLoading) {
    return (
      <div className="border-2 border-ink bg-white p-6 shadow-[4px_4px_0_#0D0D0D]">
        <div className="animate-pulse space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="flex gap-3">
              <div className="w-8 h-8 rounded-full bg-gray-200" />
              <div className="flex-1 h-10 bg-gray-200 rounded" />
            </div>
          ))}
        </div>
      </div>
    )
  }

  const userId = session?.id || ''

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#0D0D0D]">
      <div className="border-b-2 border-ink bg-ink px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-neon">Chat</h3>
      </div>

      <div className="h-80 overflow-y-auto p-4 space-y-3">
        {messages.length === 0 && (
          <p className="font-nunito text-sm text-muted text-center pt-8">No messages yet. Start the conversation!</p>
        )}
        {messages.map((msg: Message) => {
          const isMine = msg.sender_id === userId
          return (
            <div key={msg.id} className={`flex ${isMine ? 'justify-end' : 'justify-start'}`}>
              <div
                className={`max-w-[75%] border-2 border-ink px-4 py-2.5 shadow-[2px_2px_0_#0D0D0D] ${
                  isMine ? 'bg-ink text-neon' : 'bg-white text-ink'
                }`}
              >
                {!isMine && (
                  <p className="font-space text-[9px] font-bold uppercase text-muted mb-0.5">{msg.sender_name}</p>
                )}
                <p className="font-nunito text-sm">{msg.content}</p>
                <p className={`font-nunito text-[10px] mt-0.5 text-right ${isMine ? 'text-neon/60' : 'text-muted'}`}>
                  {new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </p>
              </div>
            </div>
          )
        })}
        <div ref={bottomRef} />
      </div>

      <form onSubmit={handleSend} className="border-t-2 border-ink flex items-stretch">
        <input
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Type a message..."
          className="flex-1 px-4 py-3 font-nunito text-sm border-none outline-none text-ink placeholder:text-muted"
          disabled={sendMutation.isPending}
        />
        <button
          type="submit"
          disabled={!text.trim() || sendMutation.isPending}
          className="border-l-2 border-ink bg-ink px-5 font-space text-xs font-bold uppercase text-neon disabled:opacity-40 hover:shadow-[inset_3px_3px_0_#C8FF00] transition-all"
        >
          Send
        </button>
      </form>
    </div>
  )
}
