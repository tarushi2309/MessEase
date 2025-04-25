/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin     = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// ─── CONFIGURE YOUR SMTP ──────────────────────────────────────────────────────────
// e.g. a Gmail “App password”:
const SMTP_USER = functions.config().email.user;
const SMTP_PASS = functions.config().email.pass;

const transporter = nodemailer.createTransport({
    service: 'gmail', 
    auth: {
        user: SMTP_USER,
        pass: SMTP_PASS
    }
});

exports.sendMail = functions.https.onCall(async (data, context) => {
    const to = data.to;      // array of strings
    const subject = data.subject; // string
    const body = data.body;    // string

    if (!Array.isArray(to) || to.length === 0) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            '`to` must be a non-empty array of email addresses'
        );
    }

    const mailOptions = {
        from: SMTP_USER,
        to:   to.join(','),
        subject,
        text: body,
    };

    try {
        await transporter.sendMail(mailOptions);
        return { success: true };
    } catch (err) {
        console.error('Error sending email:', err);
        throw new functions.https.HttpsError('internal', 'Failed to send email');
    }
});


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
