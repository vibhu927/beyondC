import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        neon: '#C8FF00',
        pink: '#FF2D78',
        blue: '#3D5BFF',
        purple: '#9B5DE5',
        orange: '#FF6B00',
        ink: '#0D0D0D',
        muted: '#6B6B6B',
      },
      boxShadow: {
        'neo': '4px 4px 0px #0D0D0D',
        'neo-neon': '4px 4px 0px #C8FF00',
        'neo-pink': '4px 4px 0px #FF2D78',
        'neo-blue': '4px 4px 0px #3D5BFF',
        'neo-purple': '4px 4px 0px #9B5DE5',
      },
      fontFamily: {
        jakarta: ['var(--font-jakarta)'],
        space: ['var(--font-space)'],
        nunito: ['var(--font-nunito)'],
      },
      animation: {
        'float': 'float 4s ease-in-out infinite',
        'float-delayed': 'float 4s ease-in-out 1s infinite',
        'marquee': 'marquee 30s linear infinite',
        'marquee-reverse': 'marquee-reverse 30s linear infinite',
        'fade-in-up': 'fadeInUp 0.6s ease-out forwards',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-12px)' },
        },
        marquee: {
          '0%': { transform: 'translateX(0%)' },
          '100%': { transform: 'translateX(-100%)' },
        },
        'marquee-reverse': {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(0%)' },
        },
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
}
export default config
