# Firebase Setup Guide for Real-Time Chat

## Overview
Your app now uses Firebase Realtime Database for cross-device messaging. Messages sent from one device will instantly appear on another device.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select an existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "health-tracker-chat")
   - Enable/disable Google Analytics (optional)
   - Click "Create project"

## Step 2: Add Android App to Firebase

1. In Firebase Console, click **"Add app"** → Select **Android** icon
2. Fill in the details:
   - **Android package name**: `com.example.flutter_application_1` (check your `android/app/build.gradle`)
   - **App nickname**: Health Tracker Chat
   - **Debug signing certificate SHA-1**: (optional for now)
3. Click **"Register app"**
4. Download `google-services.json` file
5. Place it in: `android/app/` directory

## Step 3: Add iOS App to Firebase (if needed)

1. Click **"Add app"** → Select **iOS** icon
2. Fill in:
   - **iOS bundle ID**: (check your iOS config)
   - **App nickname**: Health Tracker Chat iOS
3. Click **"Register app"**
4. Download `GoogleService-Info.plist`
5. Place it in: `ios/Runner/` directory (requires Xcode)

## Step 4: Enable Realtime Database

1. In Firebase Console, go to **"Realtime Database"** (left sidebar)
2. Click **"Create database"**
3. Choose location (select closest to your users)
4. Set security rules:
   - Start in **TEST MODE** (for development only)
   - Security rules should be:
   ```json
   {
     "rules": {
       ".read": true,
       ".write": true
     }
   }
   ```
   ⚠️ **Warning**: This allows anyone to read/write. For production, implement proper authentication and rules.

## Step 5: Get Configuration Data

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **"Your apps"** section
3. Copy these values:
   - **apiKey**
   - **appId**
   - **messagingSenderId**
   - **projectId**
   - **databaseURL** (from Realtime Database)

## Step 6: Update main.dart

Open `lib/main.dart` and replace the Firebase configuration:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_ACTUAL_API_KEY',
    appId: 'YOUR_ACTUAL_APP_ID',
    messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
    projectId: 'YOUR_ACTUAL_PROJECT_ID',
    databaseURL: 'YOUR_ACTUAL_DATABASE_URL',
  ),
);
```

## Step 7: Install Dependencies

Run:
```bash
flutter pub get
```

## Step 8: Install Firebase Android Dependencies

1. Open `android/build.gradle` (project-level)
2. Add to `dependencies`:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```

3. Open `android/app/build.gradle`
4. Add at the bottom:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## Step 9: Test the Chat

1. Run your app: `flutter run`
2. Navigate to the chat section
3. Select a friend to chat with
4. Send a message
5. **On another device**: Open the app and you'll see the message appear!
   (Or use Firebase Console to verify messages are being saved)

## How It Works

- **Messages**: Stored in `messages/{conversationId}/`
- **Conversations**: Metadata in `conversations/{conversationId}/`
- **Real-time**: Firebase automatically syncs changes across all devices
- **Conversation ID**: Format: `conversation_{userId1}_{userId2}` (ordered)

## Database Structure

```
{
  "messages": {
    "conversation_1_2": {
      "messageId123": {
        "senderId": "1",
        "receiverId": "2",
        "content": "Hello!",
        "timestamp": 1234567890,
        "isRead": false
      }
    }
  },
  "conversations": {
    "conversation_1_2": {
      "lastMessage": "Hello!",
      "lastMessageTime": 1234567890,
      "user1": "1",
      "user2": "2"
    }
  }
}
```

## Troubleshooting

### Error: "PlatformException(channel-error)"
- Make sure `google-services.json` is in `android/app/`
- Run: `flutter clean` then `flutter pub get`

### Messages not syncing
- Check Firebase Console → Realtime Database
- Verify security rules allow read/write
- Check internet connection

### App crashes on startup
- Ensure Firebase configuration in `main.dart` is correct
- Check logs: `flutter run` and look for Firebase errors

## Production Security Rules (Important!)

For production, implement proper security rules:

```json
{
  "rules": {
    "messages": {
      "$conversationId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    },
    "conversations": {
      "$conversationId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Guide](https://firebase.flutter.dev/)
- [Firebase Realtime Database Guide](https://firebase.google.com/docs/database/flutter/start)

---

**✅ Once setup is complete, your chat will work in real-time across all devices!**
