type StepProgressProps = {
  currentStep: number
  totalSteps?: number
}

export default function StepProgress({ currentStep, totalSteps = 3 }: StepProgressProps) {
  return (
    <div className="w-full max-w-md mx-auto" aria-label="Signup progress">
      <div className="flex items-center justify-between">
        {Array.from({ length: totalSteps }).map((_, index) => {
          const step = index + 1
          const isActive = step <= currentStep
          const isLast = step === totalSteps

          return (
            <div key={step} className="flex items-center flex-1">
              <div
                className={`h-4 w-4 rounded-full border-2 border-ink ${
                  isActive ? 'bg-neon shadow-[2px_2px_0_#0D0D0D]' : 'bg-white'
                }`}
              />
              {!isLast && (
                <div
                  className={`h-[2px] flex-1 mx-2 ${
                    step < currentStep ? 'bg-neon' : 'bg-ink/30'
                  }`}
                />
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}
