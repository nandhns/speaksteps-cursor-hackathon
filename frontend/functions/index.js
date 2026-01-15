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

function buildPatientEmailContent(message, patientName, patientEmail, tempPassword, assignedModules) {
  const defaultSubject = 'Welcome to SpeakSteps | Selamat Datang ke SpeakSteps';
  const moduleNames = Array.isArray(assignedModules) ? assignedModules.join(', ') : assignedModules;
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
      h3 { margin:0 0 8px 0; color:#1a1d2a; }
      ol { margin:8px 0; padding-left:20px; }
      ul { margin:8px 0; padding-left:20px; }
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
          <div class="header">Welcome to SpeakSteps!</div>
          <div class="section">
            <p><strong>Hello ${patientName},</strong></p>
            <p>Your therapist has set up a SpeakSteps account for you! SpeakSteps is a speech therapy app designed to help you practice and improve your communication skills.</p>
            <div class="card">
              <h3>Your Login Credentials</h3>
              <p><strong>Email:</strong> ${patientEmail}</p>
              <p><strong>Temporary Password:</strong> ${tempPassword}</p>
              <p><em>Please change your password after your first login.</em></p>
            </div>
            
            <div class="card">
              <h3>Assigned Modules</h3>
              <p>Your therapist has assigned you the following therapy modules:</p>
              <p><strong>${moduleNames}</strong></p>
            </div>
            
            <h3>How to Get Started</h3>
            <p><strong>On Web:</strong></p>
            <p><a href="https://speaksteps-cursor.web.app" style="background:#0f5fff; color:white; padding:12px 24px; text-decoration:none; border-radius:8px; display:inline-block;">Open SpeakSteps Web App</a></p>
            
            <p><strong>On Mobile:</strong></p>
            <ol>
              <li>Download "SpeakSteps" from the App Store (iOS) or Google Play (Android)</li>
              <li>Open the app and sign in with your credentials above</li>
              <li>Start practicing your assigned modules!</li>
            </ol>
            
            <h3>Tips for Success</h3>
            <ul>
              <li>Practice daily for best results</li>
              <li>Take your time with each exercise</li>
              <li>Use the cue/hint buttons when you need help</li>
              <li>Your progress is tracked automatically</li>
            </ul>
            
            <p>If you have any questions, please contact your therapist.</p>
            
            <div class="divider"></div>
            <p style="font-size:14px; margin-top:20px;">
              <strong>Bahasa Melayu:</strong><br>
              Selamat datang ke SpeakSteps! Ahli terapi anda telah menyediakan akaun untuk anda. Sila gunakan butiran log masuk di atas untuk memulakan. Tukarkan kata laluan sementara anda selepas log masuk pertama.
            </p>
          </div>
          <div class="foot">
            <p>This email was sent by SpeakSteps: Aphasia Rehabilitation Platform</p>
            <p>If you didn't expect this email, please ignore it.</p>
          </div>
        </div>
      </td></tr>
    </table>
  </body>
  </html>`;

  return {
    subject: message.subject || defaultSubject,
    text: message.text || 'Welcome to SpeakSteps. Your login credentials are included in this email.',
    html: message.html || html,
  };
}

function buildCaregiverEmailContent(message) {
  const defaultSubject = 'Welcome to SpeakSteps Caregiver Portal | Selamat Datang ke Portal Penjaga SpeakSteps';
  const html = `
  <!doctype html>
  <html lang="en">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      body { margin:0; padding:0; background:#f5f7fb; font-family: Arial, sans-serif; }
      .wrapper { width:100%; }
      .container { max-width:600px; width:100%; margin:0 auto; background:#ffffff; border-radius:10px; overflow:hidden; box-shadow:0 4px 18px rgba(0,0,0,0.06); }
      .header { padding:20px 24px; background:#0f5fff; color:#ffffff; font-size:20px; font-weight:700; text-align:center; }
      .section { padding:20px 24px; color:#1a1d2a; line-height:1.5; }
      .pill { display:inline-block; padding:6px 12px; border-radius:999px; background:#eef3ff; color:#0f5fff; font-size:13px; font-weight:600; margin-bottom:12px; }
      .card { background:#f8fafc; border:1px solid #e6ebf5; border-radius:10px; padding:14px 16px; margin:12px 0; }
      .divider { height:1px; background:#e6ebf5; margin:16px 0; }
      .foot { font-size:12px; color:#6b7280; text-align:center; padding:12px 16px 20px; }
      ol { margin:8px 0; padding-left:20px; }
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
          <div class="header">SpeakSteps: Caregiver Support</div>
          <div class="section">
            <div class="pill">For the caregiver • Untuk penjaga</div>
            <p><strong>Hi caregiver,</strong> thank you for supporting your loved one's speech therapy journey with SpeakSteps. Here's how you can help:</p>
            
            <div class="card">
              <strong>Your Role (English)</strong>
              <ol>
                <li>Open the app and sign in with the email we registered.</li>
                <li>Assist your loved one with changing their password.</li>
                <li>Supervise their exercises during practice sessions.</li>
                <li>When cues appear, make sure they notice and use the cues to guide their responses.</li>
              </ol>
            </div>
            
            <div class="card">
              <strong>Peranan Anda (Bahasa Melayu)</strong>
              <ol>
                <li>Buka aplikasi dan log masuk dengan emel yang didaftarkan.</li>
                <li>Bantu orang tersayang menukar kata laluan mereka.</li>
                <li>Awasi latihan mereka semasa sesi amalan.</li>
                <li>Apabila isyarat muncul, pastikan mereka menyedarinya dan menggunakannya untuk memandu respons mereka.</li>
              </ol>
            </div>
            
            <div class="divider"></div>
            <p><strong>Tips for Success:</strong> Be patient and encouraging. Celebrate small progress. Keep practice sessions calm and positive. Reach out to the therapist if you have questions.</p>
            <p><strong>Petua Kejayaan:</strong> Bersabarlah dan beri galakan. Rayakan kemajuan kecil. Pastikan sesi amalan tenang dan positif. Hubungi ahli terapi jika anda mempunyai soalan.</p>
          </div>
          <div class="foot">
            <p>Questions? Reply to this email and we'll help. | Ada soalan? Balas emel ini dan kami akan membantu.</p>
            <p>This email was sent by SpeakSteps: Aphasia Rehabilitation Platform</p>
          </div>
        </div>
      </td></tr>
    </table>
  </body>
  </html>`;

  return {
    subject: message.subject || defaultSubject,
    text: message.text || 'Welcome to SpeakSteps Caregiver Portal. Instructions for supporting your loved one are included in this email.',
    html: message.html || html,
  };
}

exports.sendOnboardingEmail = onDocumentCreated('mail/{mailId}', async (event) => {
  const data = event.data.data();
  const to = data.to;
  const emailType = data.emailType || 'patient'; // 'patient' or 'caregiver'
  const message = data.message || {};

  console.log(`📧 Processing email - type: ${emailType}, to: ${to}`);

  if (!to) {
    console.error('❌ Missing recipient (to)');
    return null;
  }

  let content;
  if (emailType === 'caregiver') {
    console.log('📧 Building caregiver email...');
    content = buildCaregiverEmailContent(message);
  } else {
    console.log('📧 Building patient email...');
    console.log('   Patient Name:', data.patientName || 'Patient');
    console.log('   Patient Email:', data.patientEmail || to);
    console.log('   Assigned Modules:', data.assignedModules);
    content = buildPatientEmailContent(
      message,
      data.patientName || 'Patient',
      data.patientEmail || to,
      data.tempPassword || 'TempPass',
      data.assignedModules || []
    );
  }

  const mailOptions = {
    from: message.from || 'no-reply@speaksteps.com',
    to,
    subject: content.subject,
    text: content.text,
    html: content.html,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log(`✅ Onboarding email (${emailType}) sent to ${to}`, info.messageId);
    return null;
  } catch (err) {
    console.error('❌ Error sending onboarding email', err);
    // Persist error details for debugging
    await event.data.ref.set({ error: err.message, sentAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return null;
  }
});