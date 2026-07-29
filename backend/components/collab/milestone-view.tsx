'use client'

import type { CollabDetail } from '@/lib/api/collab'

const milestoneSteps = [
  { key: 'brief_shared', label: 'Brief Shared', description: 'Brand shares the campaign brief', role: 'brand' as const },
  { key: 'draft_submitted', label: 'Draft Submitted', description: 'Creator submits first draft', role: 'creator' as const },
  { key: 'draft_approved', label: 'Draft Approved', description: 'Brand approves the draft', role: 'brand' as const },
  { key: 'content_posted', label: 'Content Posted', description: 'Creator publishes content', role: 'creator' as const },
]

function getCurrentIndex(milestoneStatus: string | null): number {
  if (!milestoneStatus) return -1
  const idx = milestoneSteps.findIndex((s) => s.key === milestoneStatus)
  return idx
}

export function MilestoneView({
  collab,
  collabId,
  role,
  accentColor = '#C8FF00',
  onMarkMilestone,
  isMarking,
}: {
  collab: CollabDetail
  collabId: string
  role: 'creator' | 'brand'
  accentColor?: string
  onMarkMilestone?: (milestone: string) => void
  isMarking?: boolean
}) {
  const currentIndex = getCurrentIndex(collab.milestone_status)

  return (
    <div className="border-2 border-ink bg-white shadow-[4px_4px_0_#0D0D0D]">
      <div className="border-b-2 border-ink bg-ink/5 px-5 py-3">
        <h3 className="font-space text-xs font-bold uppercase text-ink">Milestone Progress</h3>
      </div>
      <div className="p-5">
        <div className="relative">
          {milestoneSteps.map((step, i) => {
            const isCompleted = i <= currentIndex
            const isCurrent = i === currentIndex + 1
            const canMark = isCurrent && role === step.role && collab.status === 'in_progress'

            return (
              <div key={step.key} className="flex items-start gap-4 pb-6 last:pb-0 relative">
                {i < milestoneSteps.length - 1 && (
                  <div className={`absolute left-[11px] top-7 w-0.5 h-8 ${isCompleted ? 'bg-neon' : 'bg-gray-200'}`} />
                )}
                <div
                  className={`w-6 h-6 rounded-full border-2 border-ink flex items-center justify-center font-space text-xs font-bold shrink-0 ${
                    isCompleted ? 'bg-neon text-ink' : isCurrent ? 'bg-ink text-neon animate-pulse' : 'bg-white text-muted'
                  }`}
                >
                  {i + 1}
                </div>
                <div className="flex-1 min-w-0 pt-0.5">
                  <div className="flex items-center justify-between">
                    <p className={`font-nunito text-sm font-semibold ${isCompleted ? 'text-ink' : 'text-muted'}`}>
                      {step.label}
                    </p>
                    {canMark && onMarkMilestone && (
                      <button
                        onClick={() => onMarkMilestone(step.key)}
                        disabled={isMarking}
                        className="border-2 border-ink bg-neon px-3 py-1 font-space text-[9px] font-bold uppercase text-ink disabled:opacity-50"
                      >
                        Mark Done
                      </button>
                    )}
                  </div>
                  <p className="font-nunito text-xs text-muted">{step.description}</p>
                  <span className="font-space text-[9px] uppercase text-muted/60">{step.role}</span>
                  {isCompleted && <span className="ml-2 text-neon text-xs">✓</span>}
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}
