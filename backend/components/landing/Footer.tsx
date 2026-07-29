import Image from 'next/image'

export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-ink border-t border-neon py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Top Section */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
          {/* Left - Logo & Tagline */}
          <div>
            <a href="#" className="relative inline-flex h-10 w-10 items-center overflow-visible mb-3">
              <span className="pointer-events-none absolute left-1/2 top-1/2 h-16 w-16 -translate-x-1/2 -translate-y-1/2">
                <Image
                  src="/assets/logo.png"
                  alt="BeyondC logo"
                  fill
                  sizes="64px"
                  className="rounded-full object-cover border-2 border-neon"
                />
              </span>
            </a>
            <p className="font-jakarta text-lg font-semibold text-neon">
              Collabs, but make it Beyond.
            </p>
          </div>

          {/* Right - Links */}
          <div className="flex flex-col sm:flex-row gap-6 sm:gap-8 sm:justify-end">
            <div>
              <h4 className="font-jakarta font-bold text-white mb-3">Company</h4>
              <ul className="space-y-2">
                <li>
                  <a href="/privacy" className="font-nunito text-gray-400 hover:text-neon transition-colors">
                    Privacy Policy
                  </a>
                </li>
                <li>
                  <a href="/terms" className="font-nunito text-gray-400 hover:text-neon transition-colors">
                    Terms of Service
                  </a>
                </li>
                <li>
                  <a href="/contact" className="font-nunito text-gray-400 hover:text-neon transition-colors">
                    Contact
                  </a>
                </li>
              </ul>
            </div>
            <div>
              <h4 className="font-jakarta font-bold text-white mb-3">Social</h4>
              <ul className="space-y-2">
                <li>
                  <a href="#" className="font-nunito text-gray-400 hover:text-neon transition-colors">
                    Instagram
                  </a>
                </li>
                <li>
                  <a href="#" className="font-nunito text-gray-400 hover:text-neon transition-colors">
                    Twitter / X
                  </a>
                </li>
                <li>
                  <a href="#" className="font-nunito text-gray-400 hover:text-neon transition-colors">
                    LinkedIn
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* Download Section */}
        {/* <div className="py-8 border-t border-gray-800">
          <div className="flex flex-col items-center gap-4">
            <h4 className="font-jakarta font-bold text-white text-lg">Download the App</h4>
            <div className="flex flex-col sm:flex-row gap-4">
              <a 
                href="https://apps.apple.com" 
                target="_blank" 
                rel="noopener noreferrer"
                className="flex items-center gap-2 px-5 py-2.5 bg-white border-2 border-white hover:bg-neon hover:border-neon transition-all"
              >
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                </svg>
                <div className="text-left">
                  <p className="font-nunito text-[10px] text-ink leading-none">Download on</p>
                  <p className="font-jakarta font-bold text-sm text-ink leading-none">App Store</p>
                </div>
              </a>
              <a 
                href="https://play.google.com" 
                target="_blank" 
                rel="noopener noreferrer"
                className="flex items-center gap-2 px-5 py-2.5 bg-white border-2 border-white hover:bg-neon hover:border-neon transition-all"
              >
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                </svg>
                <div className="text-left">
                  <p className="font-nunito text-[10px] text-ink leading-none">GET IT ON</p>
                  <p className="font-jakarta font-bold text-sm text-ink leading-none">Google Play</p>
                </div>
              </a>
            </div>
          </div>
        </div> */}

        {/* Bottom Section */}
        <div className="pt-8 border-t border-gray-800 text-center">
          <p className="font-nunito text-gray-400">
            © {currentYear} BeyondC. Built with 🖤 in India.
          </p>
        </div>
      </div>
    </footer>
  )
}
