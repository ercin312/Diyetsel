const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.onBlogPublished = functions.firestore
  .document('blogPosts/{postId}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after || !after.published) return null;
    if (before && before.published === true) return null;
    return admin.messaging().send({
      topic: 'clients',
      notification: {
        title: 'Yeni Diyetsel yazısı',
        body: after.title || 'Yeni bir içerik yayınlandı',
      },
    });
  });

exports.appointmentReminders = functions.pubsub
  .schedule('every 15 minutes')
  .timeZone('Europe/Istanbul')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now().toDate();
    const inHour = new Date(now.getTime() + 60 * 60 * 1000);
    const inDay = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const snap = await admin.firestore().collection('appointments').where('status', '==', 'approved').get();
    const sends = [];
    snap.forEach((doc) => {
      const data = doc.data();
      const start = new Date(data.startAt);
      const diff = start.getTime() - now.getTime();
      const nearHour = Math.abs(diff - 60 * 60 * 1000) < 15 * 60 * 1000;
      const nearDay = Math.abs(diff - 24 * 60 * 60 * 1000) < 15 * 60 * 1000;
      if (nearHour || nearDay) {
        sends.push(
          admin.messaging().send({
            topic: 'clients',
            notification: {
              title: nearHour ? 'Randevuna 1 saat kaldı' : 'Yarın randevun var',
              body: `${data.clientName || 'Danışan'} • ${data.serviceTitle || 'Seans'}`,
            },
          }),
        );
      }
    });
    await Promise.all(sends);
    return null;
  });
