type ForgotPasswordEmailProps = {
  firstName: string
  resetLink: string
}

export function ForgotPasswordEmail({ firstName, resetLink }: ForgotPasswordEmailProps) {
  return (
    <html>
      <body style={{ fontFamily: 'sans-serif', background: '#f7f7f7', padding: '40px 0' }}>
        <div
          style={{
            maxWidth: '480px',
            margin: '0 auto',
            background: '#ffffff',
            border: '2px solid #0D0D0D',
            borderRadius: '16px',
            boxShadow: '4px 4px 0px #C8FF00',
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
            <p style={{ fontSize: '22px', fontWeight: 700, color: '#0D0D0D', margin: '0 0 8px' }}>
              Hey {firstName} 👋
            </p>
            <p style={{ fontSize: '16px', color: '#6B6B6B', margin: '0 0 32px' }}>
              We received a request to reset your BeyondC password. Click the button below to set a new one.
            </p>

            <a
              href={resetLink}
              style={{
                display: 'block',
                textAlign: 'center',
                background: '#C8FF00',
                color: '#0D0D0D',
                fontSize: '16px',
                fontWeight: 700,
                padding: '14px 24px',
                borderRadius: '12px',
                border: '2px solid #0D0D0D',
                boxShadow: '4px 4px 0px #0D0D0D',
                textDecoration: 'none',
                marginBottom: '24px',
              }}
            >
              Reset My Password →
            </a>

            <p style={{ fontSize: '13px', color: '#6B6B6B', margin: 0 }}>
              This link expires in <strong>1 hour</strong>. If you did not request this, ignore this email and your account will remain safe.
            </p>
          </div>

          <div style={{ background: '#f7f7f7', padding: '16px 24px', textAlign: 'center' }}>
            <p style={{ fontSize: '12px', color: '#888888', margin: 0 }}>© 2025 BeyondC · Made with love in India</p>
          </div>
        </div>
      </body>
    </html>
  )
}
