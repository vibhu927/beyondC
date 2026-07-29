'use client'

import { useState } from 'react'
import Navbar from '@/components/landing/Navbar'
import Footer from '@/components/landing/Footer'

export default function ContactPage() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [message, setMessage] = useState('')
  const [submitted, setSubmitted] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const subject = encodeURIComponent(`Contact from ${name}`)
    const body = encodeURIComponent(`Name: ${name}\nEmail: ${email}\n\n${message}`)
    window.location.href = `mailto:beyond.content01@gmail.com?subject=${subject}&body=${body}`
    setSubmitted(true)
  }

  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      <section className="mx-auto max-w-2xl px-4 py-20 sm:px-6 lg:px-8 mt-5">
        <h1 className="mb-2 text-center font-jakarta text-4xl font-extrabold text-ink md:text-5xl mt-5">
          Contact Us
        </h1>
        <p className="mb-10 text-center font-nunito text-base text-muted">
          Have a question or need help? Send us a message.
        </p>

        {submitted ? (
          <div className="border-2 border-ink bg-neon p-8 text-center shadow-[6px_6px_0_#0D0D0D]">
            <p className="font-jakarta text-2xl font-extrabold text-ink">Message sent! 🎉</p>
            <p className="mt-2 font-nunito text-base text-ink/80">
              We&apos;ll get back to you as soon as possible.
            </p>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label className="mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
                Name
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-base text-ink outline-none transition focus:shadow-[4px_4px_0_#C8FF00]"
                placeholder="Your name"
              />
            </div>
            <div>
              <label className="mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
                Email
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-base text-ink outline-none transition focus:shadow-[4px_4px_0_#C8FF00]"
                placeholder="you@example.com"
              />
            </div>
            <div>
              <label className="mb-2 block font-space text-xs font-bold uppercase tracking-[0.08em] text-ink">
                Message
              </label>
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                required
                rows={5}
                className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-base text-ink outline-none transition focus:shadow-[4px_4px_0_#C8FF00]"
                placeholder="How can we help?"
              />
            </div>
            <button
              type="submit"
              className="w-full border-2 border-ink bg-ink px-6 py-3 font-space text-sm font-bold uppercase tracking-[0.08em] text-neon shadow-[4px_4px_0_#C8FF00] hover:shadow-[6px_6px_0_#C8FF00] hover:-translate-y-0.5 transition-all"
            >
              Send Message →
            </button>
          </form>
        )}
      </section>
      <Footer />
    </main>
  )
}
