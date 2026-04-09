type ForgotPasswordEmailProps = {
  firstName: string
  resetLink: string
}

export function ForgotPasswordEmail({ firstName, resetLink }: ForgotPasswordEmailProps) {
  return (
    <html>
      <body style={{ fontFamily: 'Helvetica, Arial, sans-serif', background: '#f7f7f7', padding: '40px 0' }}>
        <div
          style={{
            maxWidth: '520px',
            margin: '0 auto',
            background: '#ffffff',
            border: '2px solid #0D0D0D',
            borderRadius: '18px',
            boxShadow: '5px 5px 0px #C8FF00',
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
            <div style={{ marginTop: '12px' }}>
              <span
                style={{
                  fontSize: '10px',
                  fontWeight: 700,
                  letterSpacing: '0.8px',
                  textTransform: 'uppercase',
                  color: '#0D0D0D',
                  background: '#C8FF00',
                  borderRadius: '999px',
                  border: '2px solid #0D0D0D',
                  padding: '4px 10px',
                }}
              >
                Security Reset
              </span>
            </div>
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
              Change Password →
            </a>

            <div
              style={{
                background: '#F7F7F7',
                border: '2px solid #0D0D0D',
                borderRadius: '12px',
                boxShadow: '3px 3px 0 #9B5DE5',
                padding: '14px 16px',
              }}
            >
              <p style={{ fontSize: '13px', color: '#444444', margin: 0, lineHeight: 1.55 }}>
                This link is <strong style={{ color: '#0D0D0D' }}>unique</strong>, expires in <strong style={{ color: '#0D0D0D' }}>1 hour</strong>, and can be used only once.
                If opened after expiry or reuse, it will show as expired.
              </p>
            </div>

            <p style={{ fontSize: '12px', color: '#6B6B6B', margin: '16px 0 0' }}>
              If you did not request this, ignore this email and your account will remain safe.
            </p>
          </div>

          <div style={{ background: '#0D0D0D', padding: '16px 24px', textAlign: 'center' }}>
            <p style={{ fontSize: '12px', color: '#555555', margin: 0 }}>© 2026 BeyondC · Made with love in India</p>
          </div>
        </div>
      </body>
    </html>
  )
}
