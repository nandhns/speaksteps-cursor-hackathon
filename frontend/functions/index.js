const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

// Initialize only once
if (!admin.apps.length) {
  admin.initializeApp();
}

// Hardcoded SMTP config (Mailtrap sandbox)
const transporter = nodemailer.createTransport({
  host: 'sandbox.smtp.mailtrap.io',
  port: 2525,
  auth: {
    user: '387577c2503855',
    pass: 'e240e8275d03c9',
  },
});

function buildEmailContent(message) {
  // When no custom message provided, use bilingual caregiver-focused template.
  const defaultSubject = 'Welcome to SpeakSteps | Selamat Datang ke SpeakSteps';
  const html = `
  <!doctype html>
  <html lang="en">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      /* mobile-safe container */
      body { margin:0; padding:0; background:#f5f7fb; font-family: Arial, sans-serif; }
      .wrapper { width:100%; }
      .container { max-width:600px; width:100%; margin:0 auto; background:#ffffff; border-radius:10px; overflow:hidden; box-shadow:0 4px 18px rgba(0,0,0,0.06); }
      .header { padding:20px 24px; background:#0f5fff; color:#ffffff; font-size:20px; font-weight:700; text-align:center; }
      .section { padding:20px 24px; color:#1a1d2a; line-height:1.5; }
      .pill { display:inline-block; padding:6px 12px; border-radius:999px; background:#eef3ff; color:#0f5fff; font-size:13px; font-weight:600; margin-bottom:12px; }
      .card { background:#f8fafc; border:1px solid #e6ebf5; border-radius:10px; padding:14px 16px; margin:12px 0; }
      .divider { height:1px; background:#e6ebf5; margin:16px 0; }
      .foot { font-size:12px; color:#6b7280; text-align:center; padding:12px 16px 20px; }
      @media (max-width: 480px) {
        .header { font-size:18px; padding:16px 18px; }
        .section { padding:16px 18px; }
      }
    </style>
  </head>
  <body>
    <table class="wrapper" role="presentation" cellspacing="0" cellpadding="0">
      <tr><td>
        <div class="container">
          <div class="header">SpeakSteps Onboarding</div>
          <div class="section">
            <div class="pill">For the caregiver • Untuk penjaga</div>
            <p><strong>Hi caregiver,</strong> thanks for helping your child start with SpeakSteps. Here’s how to get them ready:</p>
            <div class="card">
              <strong>Steps (English)</strong>
              <ol>
                <li>Open the app and sign in with the email we registered.</li>
                <li>Complete the profile and confirm the child’s details.</li>
                <li>Practice the first cue set together; keep sessions short (5-10 mins).</li>
                <li>Mark exercises done so your therapist can review progress.</li>
              </ol>
            </div>
            <div class="card">
              <strong>Langkah (Bahasa Melayu)</strong>
              <ol>
                <li>Buka aplikasi dan log masuk dengan emel yang didaftarkan.</li>
                <li>Lengkapkan profil dan sahkan butiran anak.</li>
                <li>Latih set isyarat pertama bersama; sesi ringkas 5-10 minit.</li>
                <li>Tanda latihan selesai supaya ahli terapi boleh semak kemajuan.</li>
              </ol>
            </div>
            <div class="divider"></div>
            <p><strong>Tips:</strong> Stay positive, use simple praise, and keep a calm environment. Reach out to your therapist if anything feels unclear.</p>
            <p><strong>Petua:</strong> Kekal positif, beri pujian ringkas, dan pastikan suasana tenang. Hubungi ahli terapi jika ada yang kurang jelas.</p>
          </div>
          <div class="foot">Questions? Reply to this email and we’ll help.</div>
        </div>
      </td></tr>
    </table>
  </body>
  </html>`;

  return {
    subject: message.subject || defaultSubject,
    text: message.text || 'Welcome to SpeakSteps. Bilingual caregiver steps included in this email.',
    html: message.html || html,
  };
}

exports.sendOnboardingEmail = onDocumentCreated('mail/{mailId}', async (event) => {
  const data = event.data.data();
  const to = data.to;
  const message = data.message || {};

  if (!to) {
    console.error('Missing recipient (to)');
    return null;
  }

  const content = buildEmailContent(message);

  const mailOptions = {
    from: message.from || 'no-reply@speaksteps.com',
    to,
    subject: content.subject,
    text: content.text,
    html: content.html,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Onboarding email sent', info.messageId);
    return null;
  } catch (err) {
    console.error('Error sending onboarding email', err);
    // Persist error details for debugging
    await event.data.ref.set({ error: err.message, sentAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return null;
  }
});