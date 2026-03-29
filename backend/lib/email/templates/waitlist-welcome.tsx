function escapeHtml(value: string) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

type WaitlistWelcomeHtmlArgs = {
  firstName: string
}

export function buildWaitlistWelcomeHtml({ firstName }: WaitlistWelcomeHtmlArgs) {
  const safeFirstName = escapeHtml(firstName)

  return `
<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="color-scheme" content="light dark" />
  <meta name="supported-color-schemes" content="light dark" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <title>You're on the BeyondC waitlist!</title>
  <!--[if mso]>
  <noscript><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript>
  <![endif]-->
  <style type="text/css">
    :root { color-scheme: light dark; }

    * { box-sizing: border-box; }

    body, #body-table {
      margin: 0 !important;
      padding: 0 !important;
      width: 100% !important;
      background-color: #F7F7F7;
      font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      -webkit-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
    }

    table {
      border-collapse: collapse;
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
    }

    img {
      border: 0;
      outline: none;
      text-decoration: none;
      -ms-interpolation-mode: bicubic;
    }

    /* ── MOBILE ── */
    @media only screen and (max-width: 480px) {
      .outer-td    { padding: 20px 8px !important; }
      .main-card   { width: 100% !important; border-radius: 14px !important; }
      .inner-pad   { padding-left: 16px !important; padding-right: 16px !important; }
      .hdr-pad     { padding: 18px 16px !important; }
      .headline    { font-size: 24px !important; line-height: 1.2 !important; }
      .hero-emoji  { font-size: 40px !important; }
      .body-text   { font-size: 14px !important; }
      .stat-wrap   { display: block !important; width: 100% !important; }
      .stat-cell   { display: block !important; width: 100% !important; padding: 0 0 10px 0 !important; }
      .stat-spacer { display: none !important; }
      .stat-card   { width: 100% !important; padding: 12px !important; }
      .stat-value  { font-size: 18px !important; }
      /* Pills - stack vertically */
      .pill-row    { display: block !important; }
      .pill-cell   { display: block !important; padding: 0 0 8px 0 !important; width: 100% !important; }
      .pill-span   { display: block !important; width: 100% !important; text-align: center !important; padding: 8px 14px !important; }
      /* Footer */
      .footer-logo-cell { display: none !important; width: 0 !important; overflow: hidden !important; }
      .footer-text-cell { width: 100% !important; }
    }

    /* ── DARK MODE ── */
    @media (prefers-color-scheme: dark) {
      body, #body-table, .outer-td-bg { background-color: #0D0D0D !important; }
      .main-card   { background-color: #1A1A1A !important; border-color: #333333 !important; }
      .card-hdr    { background-color: #111111 !important; }
      .headline    { color: #F5F5F5 !important; }
      .neon-line   { background-color: #C8FF00 !important; }
      .body-text   { color: #AAAAAA !important; }
      .section-lbl { color: #555555 !important; }
      .step-text   { color: #AAAAAA !important; }
      .step-strong { color: #F5F5F5 !important; }
      .stat-card   { background-color: #111111 !important; border-color: #333333 !important; }
      .stat-value  { color: #F5F5F5 !important; }
      .stat-label  { color: #666666 !important; }
      .divider-hr  { border-top-color: #2A2A2A !important; }
      .tip-box     { background-color: #111111 !important; border-color: #333333 !important; }
      .tip-text    { color: #888888 !important; }
      .tip-strong  { color: #F5F5F5 !important; }
      .footer-bar  { background-color: #111111 !important; }
      .footer-txt  { color: #444444 !important; }
      .footer-lnk  { color: #555555 !important; }
    }
  </style>
</head>

<body style="margin:0;padding:0;background-color:#F7F7F7;">
<!-- Outer wrapper table — forces full width on all clients -->
<table id="body-table" width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation">
  <tr>
    <td class="outer-td outer-td-bg" align="center" style="padding:40px 16px;background-color:#F7F7F7;">

      <!-- ══ MAIN CARD ══ -->
      <table class="main-card" width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation"
        style="max-width:520px;width:100%;background-color:#FFFFFF;border:2px solid #0D0D0D;border-radius:18px;box-shadow:5px 5px 0px #C8FF00;overflow:hidden;">

        <!-- ── HEADER ── -->
        <tr>
          <td class="card-hdr hdr-pad" style="background-color:#0D0D0D;padding:22px 24px;border-bottom:2px solid #0D0D0D;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td>
                  <span style="font-size:24px;font-weight:800;color:#FFFFFF;letter-spacing:-0.5px;font-family:Helvetica,Arial,sans-serif;">Beyond</span><!--
                  --><span style="font-size:24px;font-weight:800;color:#0D0D0D;background-color:#C8FF00;padding:2px 8px;border-radius:6px;margin-left:2px;letter-spacing:-0.5px;font-family:Helvetica,Arial,sans-serif;">C</span>
                </td>
                <td align="right" style="white-space:nowrap;">
                  <span style="font-size:10px;font-weight:700;color:#0D0D0D;background-color:#C8FF00;padding:4px 11px;border-radius:100px;letter-spacing:0.8px;text-transform:uppercase;font-family:Helvetica,Arial,sans-serif;">Waitlist ✓</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- ── HERO ── -->
        <tr>
          <td class="inner-pad" style="padding:30px 24px 0;">
            <div class="hero-emoji" style="font-size:48px;line-height:1;margin-bottom:14px;">🎉</div>
            <h1 class="headline" style="font-size:28px;font-weight:800;color:#0D0D0D;margin:0;line-height:1.2;letter-spacing:-0.5px;font-family:Helvetica,Arial,sans-serif;">
              You're in, ${safeFirstName}!
            </h1>
            <div class="neon-line" style="width:56px;height:4px;background-color:#C8FF00;border-radius:2px;margin:10px 0 16px;"></div>
            <p class="body-text" style="font-size:15px;color:#555555;line-height:1.65;margin:0 0 24px;font-family:Helvetica,Arial,sans-serif;">
              Welcome to the BeyondC waitlist — India's creator&nbsp;×&nbsp;brand collab network.
              You'll be among the <strong style="color:#0D0D0D;">first to get in</strong> when we launch. 🚀
            </p>
          </td>
        </tr>

        <!-- ── STATS — stack on mobile ── -->
        <tr>
          <td class="inner-pad" style="padding:0 24px 24px;">
            <table class="stat-wrap" width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <!-- Stat 1 -->
                <td class="stat-cell" valign="top" style="width:32%;">
                  <div class="stat-card" style="background:#F7F7F7;border:2px solid #0D0D0D;border-radius:10px;padding:12px 8px;text-align:center;box-shadow:3px 3px 0 #C8FF00;">
                    <div class="stat-value" style="font-size:19px;font-weight:800;color:#0D0D0D;font-family:Helvetica,Arial,sans-serif;">₹100</div>
                    <div class="stat-label" style="font-size:10px;color:#888888;margin-top:3px;font-weight:600;font-family:Helvetica,Arial,sans-serif;">min collab</div>
                  </div>
                </td>
                <td class="stat-spacer" width="3%"></td>
                <!-- Stat 2 -->
                <td class="stat-cell" valign="top" style="width:32%;">
                  <div class="stat-card" style="background:#F7F7F7;border:2px solid #0D0D0D;border-radius:10px;padding:12px 8px;text-align:center;box-shadow:3px 3px 0 #FF2D78;">
                    <div class="stat-value" style="font-size:19px;font-weight:800;color:#0D0D0D;font-family:Helvetica,Arial,sans-serif;">2-sided</div>
                    <div class="stat-label" style="font-size:10px;color:#888888;margin-top:3px;font-weight:600;font-family:Helvetica,Arial,sans-serif;">marketplace</div>
                  </div>
                </td>
                <td class="stat-spacer" width="3%"></td>
                <!-- Stat 3 -->
                <td class="stat-cell" valign="top" style="width:32%;">
                  <div class="stat-card" style="background:#F7F7F7;border:2px solid #0D0D0D;border-radius:10px;padding:12px 8px;text-align:center;box-shadow:3px 3px 0 #9B5DE5;">
                    <div class="stat-value" style="font-size:19px;font-weight:800;color:#0D0D0D;">🔒</div>
                    <div class="stat-label" style="font-size:10px;color:#888888;margin-top:3px;font-weight:600;font-family:Helvetica,Arial,sans-serif;">privacy first</div>
                  </div>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- ── DIVIDER ── -->
        <tr>
          <td class="inner-pad" style="padding:0 24px;">
            <hr class="divider-hr" style="border:none;border-top:1.5px solid #E5E5E5;margin:0 0 24px;" />
          </td>
        </tr>

        <!-- ── WHAT'S NEXT ── -->
        <tr>
          <td class="inner-pad" style="padding:0 24px 24px;">
            <p class="section-lbl" style="font-size:11px;font-weight:700;color:#888888;letter-spacing:1.2px;text-transform:uppercase;margin:0 0 16px;font-family:Helvetica,Arial,sans-serif;">What happens next</p>

            <!-- Step 1 -->
            <table width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-bottom:12px;">
              <tr>
                <td width="36" valign="top" style="padding-right:10px;">
                  <div style="width:26px;height:26px;background:#C8FF00;border:2px solid #0D0D0D;border-radius:7px;text-align:center;line-height:24px;font-size:12px;font-weight:800;color:#0D0D0D;font-family:Helvetica,Arial,sans-serif;">1</div>
                </td>
                <td valign="top">
                  <p class="step-text" style="font-size:14px;color:#444444;margin:2px 0 0;line-height:1.55;font-family:Helvetica,Arial,sans-serif;">
                    <strong class="step-strong" style="color:#0D0D0D;">We'll email you</strong> the moment early access opens — you're on the priority list.
                  </p>
                </td>
              </tr>
            </table>

            <!-- Step 2 -->
            <table width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-bottom:12px;">
              <tr>
                <td width="36" valign="top" style="padding-right:10px;">
                  <div style="width:26px;height:26px;background:#FF2D78;border:2px solid #0D0D0D;border-radius:7px;text-align:center;line-height:24px;font-size:12px;font-weight:800;color:#FFFFFF;font-family:Helvetica,Arial,sans-serif;">2</div>
                </td>
                <td valign="top">
                  <p class="step-text" style="font-size:14px;color:#444444;margin:2px 0 0;line-height:1.55;font-family:Helvetica,Arial,sans-serif;">
                    <strong class="step-strong" style="color:#0D0D0D;">Download the app</strong> on iOS or Android and log in with this email.
                  </p>
                </td>
              </tr>
            </table>

            <!-- Step 3 -->
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td width="36" valign="top" style="padding-right:10px;">
                  <div style="width:26px;height:26px;background:#9B5DE5;border:2px solid #0D0D0D;border-radius:7px;text-align:center;line-height:24px;font-size:12px;font-weight:800;color:#FFFFFF;font-family:Helvetica,Arial,sans-serif;">3</div>
                </td>
                <td valign="top">
                  <p class="step-text" style="font-size:14px;color:#444444;margin:2px 0 0;line-height:1.55;font-family:Helvetica,Arial,sans-serif;">
                    <strong class="step-strong" style="color:#0D0D0D;">Start collabing</strong> — brands meet creators, deals get done. Privately.
                  </p>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- ── TIP BOX ── -->
        <tr>
          <td class="inner-pad" style="padding:0 24px 24px;">
            <div class="tip-box" style="background:#F7F7F7;border:2px solid #0D0D0D;border-radius:12px;padding:16px 18px;box-shadow:3px 3px 0 #C8FF00;">
              <p class="tip-text" style="font-size:13px;color:#555555;margin:0;line-height:1.6;font-family:Helvetica,Arial,sans-serif;">
                💡 <strong class="tip-strong" style="color:#0D0D0D;">Early member perk</strong> — first <strong class="tip-strong" style="color:#0D0D0D;">500 users</strong> get
                <span style="color:#0D0D0D;background:#C8FF00;padding:1px 6px;border-radius:4px;font-weight:700;font-size:12px;">3 free credits</span>
                on signup. Don't sleep on it.
              </p>
            </div>
          </td>
        </tr>

        <!-- ── PILLS — stack on mobile ── -->
        <tr>
          <td class="inner-pad" style="padding:0 24px 28px;">
            <table class="pill-row" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td class="pill-cell" style="padding-right:8px;white-space:nowrap;">
                  <span class="pill-span" style="display:inline-block;font-size:12px;font-weight:700;color:#0D0D0D;background:#C8FF00;border:2px solid #0D0D0D;border-radius:100px;padding:5px 14px;font-family:Helvetica,Arial,sans-serif;">Brands 🏢</span>
                </td>
                <td class="pill-cell" style="padding-right:8px;white-space:nowrap;">
                  <span class="pill-span" style="display:inline-block;font-size:12px;font-weight:700;color:#FFFFFF;background:#FF2D78;border:2px solid #0D0D0D;border-radius:100px;padding:5px 14px;font-family:Helvetica,Arial,sans-serif;">Creators 🎨</span>
                </td>
                <td class="pill-cell" style="white-space:nowrap;">
                  <span class="pill-span" style="display:inline-block;font-size:12px;font-weight:700;color:#FFFFFF;background:#9B5DE5;border:2px solid #0D0D0D;border-radius:100px;padding:5px 14px;font-family:Helvetica,Arial,sans-serif;">Collabs 🤝</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- ── FOOTER ── -->
        <tr>
          <td class="footer-bar" style="background-color:#0D0D0D;padding:18px 24px;border-top:2px solid #0D0D0D;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td class="footer-text-cell" valign="middle">
                  <p class="footer-txt" style="font-size:11px;color:#555555;margin:0;line-height:1.7;font-family:Helvetica,Arial,sans-serif;">
                    © 2026 BeyondC · Made with 🖤 in India<br/>
                    <a href="#" class="footer-lnk" style="color:#555555;text-decoration:underline;font-size:10px;">Unsubscribe</a>
                    &nbsp;·&nbsp;
                    <a href="#" class="footer-lnk" style="color:#555555;text-decoration:underline;font-size:10px;">Privacy Policy</a>
                  </p>
                </td>
                <td class="footer-logo-cell" align="right" valign="middle" style="padding-left:12px;white-space:nowrap;">
                  <span style="font-size:15px;font-weight:800;color:#FFFFFF;font-family:Helvetica,Arial,sans-serif;">Beyond</span><!--
                  --><span style="font-size:15px;font-weight:800;color:#0D0D0D;background-color:#C8FF00;padding:1px 6px;border-radius:4px;margin-left:2px;font-family:Helvetica,Arial,sans-serif;">C</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

      </table>
      <!-- /MAIN CARD -->

    </td>
  </tr>
</table>
</body>
</html>`.trim()
}