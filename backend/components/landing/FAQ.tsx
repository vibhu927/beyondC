'use client'

import { useState } from 'react'

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  const faqs = [
    {
      question: 'Is BeyondC free to join?',
      answer: 'Yes! Joining, browsing, and bidding on collabs is 100% free. Creators pay a small fee (₹10-₹300) only when accepting a collab. Brands buy credit packs that are used only when a match happens.',
    },
    {
      question: 'How does the privacy protection actually work?',
      answer: 'Before a match, brands only see your first name, follower range, niche, and content type. Your Instagram handle, full name, and contact details stay hidden. Full info unlocks only after BOTH parties accept the collab.',
    },
    {
  question: "What if a creator doesn't deliver after a collab?",
  answer: "We have a dispute resolution system. If deliverables aren't met, brands can flag the collab. After review, credits may be refunded and the creator's account may be flagged or suspended.",
},
    {
      question: 'Can I join BeyondC if I have less than 1,000 followers?',
      answer: 'Absolutely! BeyondC welcomes nano creators with as few as 500 followers. Many brands specifically look for micro and nano creators for authentic, affordable collabs.',
    },
    {
      question: 'How do brands verify their identity on BeyondC?',
      answer: 'All brands go through a verification process where we check business documents, social media presence, and legitimacy before they can post campaigns or contact creators.',
    },
    {
      question: 'How do event invites and digital tickets work?',
      answer: 'Brands can invite creators to physical or virtual events directly through the app. Once accepted, creators receive a digital entry pass with a QR code that lives in the app. No printing needed!',
    },
    {
      question: 'When is the BeyondC app launching?',
      answer: 'We\'re launching soon on iOS and Android! Join the waitlist to get early access, 3 free credits, and be among the first to start collaborating.',
    },
  ]

  return (
    <section className="bg-ink py-20 sm:py-32">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Headline */}
        <div className="text-center mb-16">
          <h2 className="font-jakarta text-5xl sm:text-6xl font-extrabold text-white mb-3">
            You've got questions.
          </h2>
          <p className="font-jakarta text-4xl sm:text-5xl font-extrabold text-neon">
            We've got answers.
          </p>
        </div>

        {/* Accordion */}
        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <div
              key={index}
              className="bg-transparent border border-gray-700 overflow-hidden"
            >
              <button
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full flex items-center justify-between p-6 text-left hover:bg-white/5 transition-colors"
              >
                <h3 className="font-jakarta text-lg sm:text-xl font-bold text-white pr-4">
                  {faq.question}
                </h3>
                <span className={`text-neon text-2xl flex-shrink-0 transition-transform ${
                  openIndex === index ? 'rotate-45' : ''
                }`}>
                  +
                </span>
              </button>
              <div
                className={`accordion-content ${openIndex === index ? 'open' : ''}`}
              >
                <div className="px-6 pb-6">
                  <p className="font-nunito text-base text-gray-300 leading-relaxed">
                    {faq.answer}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
