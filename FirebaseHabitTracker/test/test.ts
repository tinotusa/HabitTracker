import {
    assertFails,
    assertSucceeds,
    initializeTestEnvironment,
    RulesTestEnvironment,
} from "@firebase/rules-unit-testing"
import * as firestore from "firebase/firestore";
import { getDoc, setDoc, updateDoc } from "firebase/firestore";
import * as fs from "fs"

let testEnv: RulesTestEnvironment;
const user = {
    id: "user",
    firstName: "test name",
    lastName: "test last name",
    email: "test@test.com",
    birthday: new Date()
}

const habit = {
    id: "habit",
    createdBy: "user",
    name: "habit name",
    isQuittingHabit: true,
    isStartingHabit: false,
    occurrenceTime: new Date(),
    occurrenceDays: [{ dontKnow: "test" }],
    durationHours: 0,
    durationMinutes: 10,
    activities: [
        { name: "activity name", id: "activity name"}
    ],
    reason: "some reason",
    localNotificationID: "localnoti",
    localReminderNotificationID: "localReminderNoti"
}

const journalEntry = {
    id: "journalEntry",
    habitID: "habit",
    createdBy: "user",
    habitName: "habit name",
    entry: "some entry",
    activities: [{ name: "name", isCompleted: false }],
    rating: 3,
    dateCreated: new Date()
}

beforeAll(async () => {
    testEnv = await initializeTestEnvironment({
        projectId: "habit-tracker-f4143",
        firestore: {
            host: "localhost",
            port: 8080,
            rules: fs.readFileSync("../firestore.rules", "utf8"),
        },
    });
})

afterAll(async () => {
    await testEnv.clearFirestore()
    await testEnv.cleanup()
})

describe("Firestore user security rules", () => {
    it("Add authenticated user to firestore", async () => {
        const context = testEnv.authenticatedContext(user.id)
        
        const docRef = context.firestore().collection("users").doc(user.id)

        await assertSucceeds(firestore.setDoc(docRef, user))
    })

    it("Read user", async () => {
        const context = testEnv.authenticatedContext(user.id)
        const docRef = context.firestore().collection("users").doc(user.id)
        await assertSucceeds(getDoc(docRef))
    })

    it("Edit user in firestore", async () => {
        const context = testEnv.authenticatedContext(user.id)
        const docRef = context.firestore().collection("users").doc(user.id)
        await assertSucceeds(firestore.updateDoc(docRef, { firstName: "new name" }))
    })
})

describe("Firestore habit security rules", () => {
    it("Add authenticated habit to firestore", async () => {
        const context = testEnv.authenticatedContext(user.id)
        const docRef = context.firestore()
            .collection("habits")
            .doc(user.id)
            .collection("habits")
            .doc(habit.id)

        await assertSucceeds(firestore.setDoc(docRef, habit))
    })

    it("Edit a habit in firestore", async () => {
        const context = testEnv.authenticatedContext(user.id)
        const docRef = context.firestore()
            .collection("habits")
            .doc(user.id)
            .collection("habits")
            .doc(habit.id)

        await assertSucceeds(updateDoc(docRef, { name: "new name", isStartingHabit: true }))
    })

    it("List habits in firestore", async () => {
        const context = testEnv.authenticatedContext(user.id)
        const docRef = context.firestore()
            .collectionGroup("habits")
            .where("createdBy", "==", user.id)
            .limit(20)
            .get()
        let docs = (await docRef).docs
        await assertSucceeds(getDoc(docs[0].ref))
        
    })
})

describe("Firestore journal entries security rules", () => {
    it("Add journal entry to firestore", async () => {
        const context = testEnv.authenticatedContext(user.id)
        const docRef = context.firestore()
            .collection("journalEntries")
            .doc(user.id)
            .collection("journalEntries")
            .doc(journalEntry.id)
            

        await assertSucceeds(setDoc(docRef, journalEntry))
    })

    it("Get journal entry from firestore", async() => {
        const context = testEnv.authenticatedContext(user.id)
        const docRef = context.firestore()
            .collection("journalEntries")
            .doc(user.id)
            .collection("journalEntries")
            .doc(journalEntry.id)

        await assertSucceeds(getDoc(docRef))
    })

    it("List journal entires in firestore", async () => {
        const context = testEnv.authenticatedContext(user.id)
        const snapshot = context.firestore()
            .collectionGroup("journalEntries")
            .where("createdBy", "==", user.id)
            .limit(50)
            .get()
        
        let docs = (await snapshot).docs
        await assertSucceeds(getDoc(docs[0].ref))
    })

    it("Edit journal entry in firebase", async () => {
        const context = testEnv.authenticatedContext(user.id)
        const docRef = context.firestore()
            .collection("journalEntries")
            .doc(user.id)
            .collection("journalEntries")
            .doc(journalEntry.id)

        await assertSucceeds(updateDoc(docRef, { entry: "new entry" }))
    })
})