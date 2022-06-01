import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp()

// Gets the habit collection ids
exports.getAllHabitIDs = functions
  .region("australia-southeast1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.")
    }

    const collectionName = "journalEntries"
    const userID = context.auth!.uid
    const collections = await admin.firestore()
      .collection(collectionName)
      .doc(userID)
      .listCollections()

    const collectionIDS = collections.map(col => col.id)
    functions.logger.log(`collection ids for user id: ${userID}: ${collectionIDS}`)
    return { collections: collectionIDS }
  })