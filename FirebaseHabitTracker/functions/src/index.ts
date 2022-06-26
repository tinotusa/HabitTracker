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
      const habitID = data.habitID;
      const queryLimit = 50;

      functions.logger.log(
          `User ${userID} has requested to delete path ${habitPath}.`);

      deletePath(habitPath);

      const query = admin.firestore()
          .collectionGroup("journalEntries")
          .where("habitID", "==", habitID)
          .limit(queryLimit);

      const snapshot = query.get();
      let docs = (await snapshot).docs;

      docs.forEach(async (doc) => {
        const path = `journalEntries/${userID}/journalEntries/${doc.id}`;
        deletePath(path);
      });

      let lastDoc = docs[docs.length - 1];
      while (lastDoc != undefined && lastDoc.exists) {
        const nextQuery = admin.firestore()
            .collectionGroup("journalEntries")
            .where("habitID", "==", habitID)
            .startAfter(lastDoc)
            .limit(queryLimit);

        const nextSnapshot = nextQuery.get();
        docs = (await nextSnapshot).docs;
        docs.forEach(async (doc) => {
          const path = `journalEntries/${userID}/journalEntries/${doc.id}`;
          deletePath(path);
        });
        lastDoc = docs[docs.length - 1];
      }

      return {
        habitPath: habitPath,
      };
    });

/**
 * Deletes the given path from firestore.
 * @param {string} path The path to be deleted.
 */
async function deletePath(path: string) {
  await firebaseTools.firestore
      .delete(path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
        force: true,
      });
}

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
