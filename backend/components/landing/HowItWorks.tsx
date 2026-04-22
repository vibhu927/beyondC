'use client'

import { useState } from 'react'

export default function HowItWorks() {
  const [activeTab, setActiveTab] = useState<'creators' | 'brands' | 'agencies'>('creators')

  const creatorSteps = [
    {
      number: '1',
      title: 'Build Your Profile',
      description: 'Set your niche, content type, reach and starting price',
      color: 'neon',
    },
    {
      number: '2',
      title: 'Browse & Bid',
      description: 'See brand campaigns, place your bid with deliverables + price',
      color: 'pink',
    },
    {
      number: '3',
      title: 'Get Matched',
      description: "Brand picks you → both accept → full details revealed. Let's go!",
      color: 'blue',
    },
  ]

  const brandSteps = [
    {
      number: '1',
      title: 'Discover Creators',
      description: 'Browse by niche, reach and budget. Only first name + stats visible',
      color: 'neon',
    },
    {
      number: '2',
      title: 'Post a Campaign',
      description: 'Share your brief + budget. Watch creators pitch YOU',
      color: 'pink',
    },
    {
      number: '3',
      title: 'Pick & Collab',
      description: 'Accept a bid → details unlock → chat in-app and start the collab',
      color: 'blue',
    },
  ]

  const agencySteps = [
    {
      number: '1',
      title: 'Create Agency Profile',
      description: 'Set agency name, niche, and portfolio to attract brands',
      color: 'neon',
    },
    {
      number: '2',
      title: 'Add Creators',
      description: 'Invite and manage creators in your roster, track pitches',
      color: 'pink',
    },
    {
      number: '3',
      title: 'Pitch Brands',
      description: 'Proactively pitch creators to brand campaigns and close deals',
      color: 'blue',
    },
  ]

  const steps =
    activeTab === 'creators'
      ? creatorSteps
      : activeTab === 'brands'
      ? brandSteps
      : agencySteps

  return (
    <section id="how-it-works" className="bg-white py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Headline */}
        <div className="text-center mb-12">
          <h2 className="font-jakarta text-5xl sm:text-6xl lg:text-7xl font-extrabold text-ink mb-3">
            How it works.
          </h2>
          <p className="font-jakarta text-4xl sm:text-5xl lg:text-6xl font-extrabold text-purple">
            Simple as that.
          </p>
        </div>

        {/* Tab Switcher */}
        <div className="flex justify-center gap-4 mb-16">
          <button
            onClick={() => setActiveTab('creators')}
            className={`px-8 py-4 font-jakarta font-bold text-lg border-2 border-ink transition-all ${
              activeTab === 'creators'
                ? 'bg-ink text-neon'
                : 'bg-white text-ink hover:shadow-neo'
            }`}
          >
            For Creators 🎨
          </button>
          <button
            onClick={() => setActiveTab('brands')}
            className={`px-8 py-4 font-jakarta font-bold text-lg border-2 border-ink transition-all ${
              activeTab === 'brands'
                ? 'bg-ink text-neon'
                : 'bg-white text-ink hover:shadow-neo'
            }`}
          >
            For Brands 🏢
          </button>
          <button
            onClick={() => setActiveTab('agencies')}
            className={`px-8 py-4 font-jakarta font-bold text-lg border-2 border-ink transition-all ${
              activeTab === 'agencies'
                ? 'bg-ink text-neon'
                : 'bg-white text-ink hover:shadow-neo'
            }`}
          >
            For Agencies 🏢
          </button>
        </div>

        {/* Steps */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {steps.map((step, index) => (
            <div
              key={index}
              className={`bg-white border-2 border-ink p-8 neo-card transition-all ${
                step.color === 'neon' ? 'shadow-neo-neon neo-card-neon' :
                step.color === 'pink' ? 'shadow-neo-pink neo-card-pink' :
                'shadow-neo-blue neo-card-blue'
              }`}
            >
              <div
                className={`w-16 h-16 rounded-full flex items-center justify-center mb-6 ${
                  step.color === 'neon' ? 'bg-neon' :
                  step.color === 'pink' ? 'bg-pink' :
                  'bg-blue'
                }`}
              >
                <span className="font-space text-3xl font-bold text-ink">
                  {step.number}
                </span>
              </div>
              <h3 className="font-jakarta text-2xl font-bold text-ink mb-3">
                {step.title}
              </h3>
              <p className="font-nunito text-base text-muted leading-relaxed">
                {step.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
