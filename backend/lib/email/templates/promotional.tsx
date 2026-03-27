type PromotionalEmailProps = {
  firstName: string
  bodyHtml: string
  ctaText?: string
  ctaLink?: string
}

export function PromotionalEmail({ firstName, bodyHtml, ctaText, ctaLink }: PromotionalEmailProps) {
  return (
    <html>
      <body style={{ fontFamily: 'sans-serif', background: '#f7f7f7', padding: '40px 0' }}>
        <div
          style={{
            maxWidth: '560px',
            margin: '0 auto',
            background: '#ffffff',
            border: '2px solid #0D0D0D',
            borderRadius: '16px',
            overflow: 'hidden',
          }}
        >
          <div style={{ background: '#0D0D0D', padding: '24px', textAlign: 'center' }}>
            <span style={{ color: '#ffffff', fontSize: '24px', fontWeight: 800 }}>Beyond</span>
            <span
              style={{
                background: '#C8FF00',
                color: '#0D0D0D',
                fontSize: '24px',
                fontWeight: 800,
                padding: '2px 8px',
                borderRadius: '6px',
                marginLeft: '2px',
              }}
            >
              C
            </span>
          </div>

          <div style={{ padding: '32px 24px' }}>
            <p style={{ fontSize: '18px', fontWeight: 700, color: '#0D0D0D', margin: '0 0 16px' }}>Hey {firstName}! 👋</p>
            <div
              style={{ fontSize: '15px', color: '#444444', lineHeight: '1.6' }}
              dangerouslySetInnerHTML={{ __html: bodyHtml }}
            />
            {ctaText && ctaLink ? (
              <a
                href={ctaLink}
                style={{
                  display: 'block',
                  textAlign: 'center',
                  background: '#FF2D78',
                  color: '#ffffff',
                  fontSize: '15px',
                  fontWeight: 700,
                  padding: '14px 24px',
                  borderRadius: '12px',
                  border: '2px solid #0D0D0D',
                  textDecoration: 'none',
                  margin: '24px 0 0',
                }}
              >
                {ctaText} →
              </a>
            ) : null}
          </div>

          <div style={{ background: '#f7f7f7', padding: '16px 24px', textAlign: 'center' }}>
            <p style={{ fontSize: '12px', color: '#888888', margin: 0 }}>© 2025 BeyondC · Made with love in India</p>
          </div>
        </div>
      </body>
    </html>
  )
}
