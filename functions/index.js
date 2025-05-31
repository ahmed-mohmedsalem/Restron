const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationOnRequest = functions.firestore
  .document("notification_requests/{docId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    const toUserId = data.toUserId;
    const fromUserName = data.fromUserName || "Someone";

    try {
      // Get FCM token from the user's Firestore document
      const userDoc = await admin.firestore().collection("users").doc(toUserId).get();

      if (!userDoc.exists) {
        console.log("User not found:", toUserId);
        return null;
      }

      const fcmToken = userDoc.data().fcmToken;

      if (!fcmToken) {
        console.log("No FCM token for user:", toUserId);
        return null;
      }

      const message = {
        notification: {
          title: `${fromUserName} sent you a request`,
          body: "Tap to view the invitation.",
        },
        token: fcmToken,
      };

      const response = await admin.messaging().send(message);
      console.log("Notification sent successfully:", response);
    } catch (error) {
      console.error("Error sending notification:", error);
    }

    return null;
  });