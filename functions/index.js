const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Function triggered when a new notification is created
// This automatically sends a push notification to the user
exports.sendNotificationOnCreate = functions.firestore
  .document('user_notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    try {
      const notification = snap.data();
      const userId = notification.userId;
      
      console.log('📬 New notification created for user:', userId);
      console.log('📬 Title:', notification.title);
      console.log('📬 Message:', notification.message);

      // Get user's FCM token from Firestore
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        console.log('❌ User not found:', userId);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.log('❌ No FCM token for user:', userId);
        return null;
      }

      console.log('✅ Found FCM token, sending notification...');

      // Prepare FCM message
      const message = {
        token: fcmToken,
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          type: notification.type || 'general',
          eventId: notification.eventId || '',
          eventTitle: notification.eventTitle || '',
          notificationId: context.params.notificationId,
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'diu_events_notifications',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      };

      // Send the message using Firebase Admin SDK
      const response = await admin.messaging().send(message);
      console.log('✅ Successfully sent notification:', response);
      
      return response;
    } catch (error) {
      console.error('❌ Error sending notification:', error);
      return null;
    }
  });

/**
 * Cloud Function to send push notification when a new user notification is created
 * Triggers on: /user_notifications/{notificationId}
 */
exports.sendPushNotificationOnCreate = functions.firestore
    .document("user_notifications/{notificationId}")
    .onCreate(async (snap, context) => {
      try {
        const notification = snap.data();
        const userId = notification.userId;

        // Get user's FCM token from users collection
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          console.log(`User ${userId} not found`);
          return null;
        }

        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;

        if (!fcmToken) {
          console.log(`No FCM token for user ${userId}`);
          return null;
        }

        // Prepare the notification payload
        const payload = {
          notification: {
            title: notification.title || "DIU Events",
            body: notification.message || "",
          },
          data: {
            notificationId: snap.id,
            type: notification.type || "general",
            eventId: notification.eventId || "",
            eventTitle: notification.eventTitle || "",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
          token: fcmToken,
        };

        // Add Android-specific configuration
        payload.android = {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "diu_events_notifications",
          },
        };

        // Add iOS-specific configuration
        payload.apns = {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        };

        // Send the notification
        const response = await admin.messaging().send(payload);
        console.log(`Successfully sent notification to ${userId}: ${response}`);

        return response;
      } catch (error) {
        console.error("Error sending push notification:", error);
        return null;
      }
    });

/**
 * Cloud Function to send push notification to multiple users
 * Can be called from the app via HTTP
 */
exports.sendBulkPushNotification = functions.https.onCall(
    async (data, context) => {
      // Verify the user is authenticated and is an admin
      if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User must be authenticated to send notifications"
        );
      }

      // Check if user is admin
      const adminDoc = await admin.firestore()
          .collection("users")
          .doc(context.auth.uid)
          .get();

      if (!adminDoc.exists || adminDoc.data().role !== "admin") {
        throw new functions.https.HttpsError(
            "permission-denied",
            "Only admins can send bulk notifications"
        );
      }

      const {userIds, title, message, type, eventId, eventTitle} = data;

      if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "userIds must be a non-empty array"
        );
      }

      try {
        // Get FCM tokens for all users
        const tokens = [];
        const userPromises = userIds.map((userId) =>
          admin.firestore().collection("users").doc(userId).get()
        );

        const userDocs = await Promise.all(userPromises);

        userDocs.forEach((doc) => {
          if (doc.exists && doc.data().fcmToken) {
            tokens.push(doc.data().fcmToken);
          }
        });

        if (tokens.length === 0) {
          return {success: false, message: "No valid FCM tokens found"};
        }

        // Prepare the multicast message
        const message = {
          notification: {
            title: title || "DIU Events",
            body: message || "",
          },
          data: {
            type: type || "general",
            eventId: eventId || "",
            eventTitle: eventTitle || "",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
          tokens: tokens,
        };

        // Send to all tokens
        const response = await admin.messaging().sendMulticast(message);

        console.log(
            `Sent ${response.successCount} notifications successfully`
        );
        console.log(`Failed to send ${response.failureCount} notifications`);

        return {
          success: true,
          successCount: response.successCount,
          failureCount: response.failureCount,
        };
      } catch (error) {
        console.error("Error sending bulk notifications:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Failed to send bulk notifications"
        );
      }
    }
);

/**
 * Clean up invalid FCM tokens
 * Runs daily to remove expired or invalid tokens
 */
exports.cleanupInvalidTokens = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
      try {
        const usersSnapshot = await admin.firestore()
            .collection("users")
            .where("fcmToken", "!=", null)
            .get();

        const batch = admin.firestore().batch();
        let cleanupCount = 0;

        for (const doc of usersSnapshot.docs) {
          const fcmToken = doc.data().fcmToken;
          const tokenUpdatedAt = doc.data().fcmTokenUpdatedAt;

          // Check if token is older than 90 days
          if (tokenUpdatedAt) {
            const daysSinceUpdate = (Date.now() - tokenUpdatedAt.toDate()) /
              (1000 * 60 * 60 * 24);

            if (daysSinceUpdate > 90) {
              batch.update(doc.ref, {
                fcmToken: admin.firestore.FieldValue.delete(),
                fcmTokenUpdatedAt: admin.firestore.FieldValue.delete(),
              });
              cleanupCount++;
            }
          }
        }

        if (cleanupCount > 0) {
          await batch.commit();
          console.log(`Cleaned up ${cleanupCount} old FCM tokens`);
        }

        return null;
      } catch (error) {
        console.error("Error cleaning up tokens:", error);
        return null;
      }
    });
