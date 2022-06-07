import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
const firebaseTools = require("firebase-tools");

admin.initializeApp();

// Gets the habit collection ids
exports.getAllHabitIDs = functions
    .region("australia-southeast1")
    .https.onCall(async (data, context) => {
      if (!context.auth) {
        throw new functions.https.HttpsError("failed-precondition",
            "The function must be called while authenticated.");
      }

      const collectionName = "journalEntries";
      const userID = context.auth?.uid;
      const collections = await admin.firestore()
          .collection(collectionName)
          .doc(userID)
          .listCollections();

      const collectionIDS = collections.map((col) => col.id);
      functions.logger.log(
          `collection ids for user id: ${userID}: ${collectionIDS}`);
      return {
        collections: collectionIDS,
      };
    });

// Deletes the habit from the database.
exports.deleteHabit = functions
    .region("australia-southeast1")
    .runWith({
      timeoutSeconds: 540,
      memory: "2GB",
    })
    .https
    .onCall(async (data, context) => {
      // Is the caller authenticated?
      if (!context.auth) {
        throw new functions.https.HttpsError(
            "permission-denied",
            "Must be authenticated to delete a habit."
        );
      }

      // Is the caller the creator of the habit?
      if (context.auth?.uid != data.userID) {
        throw new functions.https.HttpsError(
            "permission-denied",
            "Must be the creator of the habit in order to delete."
        );
      }

      const userID = context.auth?.uid;
      const habitPath = data.habitPath;
      const journalPath = data.journalPath;

      functions.logger.log(
          `User ${userID} has requested to delete path ${habitPath}.`);

      await firebaseTools.firestore
          .delete(habitPath, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });

      await firebaseTools.firestore
          .delete(journalPath, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });

      return {
        habitPath: habitPath,
        journalPath: journalPath,
      };
    });

// Deletes the user from the database.
exports.deleteUser = functions
    .region("australia-southeast1")
    .runWith({
      timeoutSeconds: 540,
      memory: "2GB",
    })
    .https
    .onCall(async (data, context) => {
      if (!context.auth) {
        throw new functions.https.HttpsError("permission-denied",
            "Must be authenticated in order to delete a user.");
      }

      const userID = data.userID;
      if (userID != context.auth?.uid) {
        throw new functions.https.HttpsError("permission-denied",
            "Must be the account creator in order to delete.");
      }
      functions.logger.log(`Deleting user ${userID}`);

      await firebaseTools.firestore
          .delete(`users/${userID}`, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });

      functions.logger.log(`Deleting habits for user ${userID}`);
      await firebaseTools.firestore
          .delete(`habits/${userID}`, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });

      functions.logger.log(`Deleting journal entries for user ${userID}`);
      await firebaseTools.firestore
          .delete(`journalEntries/${userID}`, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });

      return {
        userID: userID,
      };
    });
