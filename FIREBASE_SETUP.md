# Firebase Setup Guide for ToothyMate

## What's Already Done (Code Changes)

1. Firebase dependencies added to `pubspec.yaml`
2. `FirebaseService` created in `lib/services/firebase_service.dart`
3. `main.dart` updated to initialize Firebase
4. `home_screen.dart` updated to sync user data to Firebase
5. `chat_provider.dart` updated to save chat history to Firebase
6. `android/settings.gradle.kts` updated with Google Services plugin
7. `android/app/build.gradle.kts` updated to apply Google Services plugin

## Manual Steps Required (Only 4 Steps!)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Name it: `toothymate-app`
4. Disable Google Analytics (not needed)
5. Click **Create Project**

---

### Step 2: Add Android App

1. In Firebase Console, click **"Add app"** > Select **Android**
2. Enter package name: `com.example.toothymate_app_4`
3. App nickname: `ToothyMate Android`
4. Click **Register app**
5. **Download `google-services.json`**
6. Place it in: `android/app/google-services.json`

---

### Step 3: Enable Firestore Database

1. In Firebase Console, go to **Build > Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select location: `asia-southeast1` (Malaysia)
5. Click **Enable**

---

### Step 4: Enable Anonymous Authentication

1. Go to **Build > Authentication**
2. Click **Get started**
3. Enable **Anonymous** sign-in
4. Click **Save**

This allows each user to have a unique ID without requiring login.

---

### Step 5: Run the App

```bash
flutter pub get
flutter clean
flutter run
```

---

## Firestore Data Structure

```
users/
  └── {anonymousUserId}/
      ├── userName: "Hero"
      ├── xp: 120
      ├── streak: 5
      ├── morningBrush: true
      ├── nightBrush: false
      ├── lastBrushDate: "2024-01-15"
      ├── completedLessons: ["1", "2", "3"]
      ├── lastUpdated: Timestamp
      └── chatHistory/
          └── {messageId}/
              ├── sender: "user"
              ├── text: "Hello"
              └── timestamp: Timestamp
```

---

## How It Works

- **No login required**: Users are automatically signed in anonymously
- **Data syncs to cloud**: User progress is saved to Firestore
- **Offline support**: SharedPreferences still works as local cache
- **Lesson content stays local**: JSON files for lessons remain as assets (fast loading, bilingual support)

---

## For Production (Later)

Update Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
