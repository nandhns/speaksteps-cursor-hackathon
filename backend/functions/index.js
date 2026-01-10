const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

// Initialize only once
if (!admin.apps.length) {
  admin.initializeApp();
}

// Transport uses runtime config: firebase functions:config:set smtp.host=... smtp.port=... smtp.user=... smtp.pass=...
const transporter = nodemailer.createTransport({
  host: functions.config().smtp.host,
  port: Number(functions.config().smtp.port || 2525),
  auth: {
    user: functions.config().smtp.user,
    pass: functions.config().smtp.pass,
  },
});

exports.sendOnboardingEmail = functions.firestore
  .document('mail/{mailId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const to = data.to;
    const message = data.message || {};

    if (!to) {
      console.error('Missing recipient (to)');
      return null;
    }

    const mailOptions = {
      from: message.from || 'no-reply@speaksteps.com',
      to,
      subject: message.subject || 'Welcome to SpeakSteps',
      text: message.text || '',
      html: message.html || message.text || '',
    };

    try {
      const info = await transporter.sendMail(mailOptions);
      console.log('Onboarding email sent', info.messageId);
      return null;
    } catch (err) {
      console.error('Error sending onboarding email', err);
      // Persist error details for debugging
      await snap.ref.set({ error: err.message, sentAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      return null;
    }
  });
