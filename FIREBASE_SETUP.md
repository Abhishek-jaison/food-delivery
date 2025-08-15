# Firebase Authentication Setup Guide

This guide will walk you through setting up Firebase Authentication for your Flutter food delivery app.

## Prerequisites

- Flutter SDK installed
- Android Studio / Xcode (for platform-specific setup)
- Firebase account

## Step 1: Firebase Console Setup

### 1.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or select an existing project
3. Enter a project name (e.g., "food-delivery-app")
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

### 1.2 Enable Authentication

1. In the Firebase Console, click on "Authentication" in the left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication:
   - Click on "Email/Password"
   - Toggle "Enable" to ON
   - Click "Save"
5. Optionally enable other sign-in methods:
   - Google Sign-in
   - Phone Number
   - Anonymous

### 1.3 Enable Firestore Database

1. Click on "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location closest to your users
5. Click "Done"

## Step 2: Android Configuration

### 2.1 Add Android App

1. In Firebase Console, click the gear icon → "Project settings"
2. Scroll down to "Your apps" section
3. Click the Android icon (</>) to add an Android app
4. Enter your package name: `com.example.food_delivery`
5. Enter app nickname: "Food Delivery Android"
6. Click "Register app"

### 2.2 Download Configuration File

1. Download the `google-services.json` file
2. Place it in the `android/app/` directory of your Flutter project

### 2.3 Update Gradle Files

The following files have already been updated:

- `android/build.gradle.kts` - Added Google Services classpath
- `android/app/build.gradle.kts` - Added Google Services plugin

## Step 3: iOS Configuration (if needed)

### 3.1 Add iOS App

1. In Firebase Console, click the gear icon → "Project settings"
2. Scroll down to "Your apps" section
3. Click the iOS icon (</>) to add an iOS app
4. Enter your bundle ID: `com.example.foodDelivery`
5. Enter app nickname: "Food Delivery iOS"
6. Click "Register app"

### 3.2 Download Configuration File

1. Download the `GoogleService-Info.plist` file
2. Add it to your iOS project using Xcode:
   - Open your iOS project in Xcode
   - Right-click on your project in the navigator
   - Select "Add Files to [ProjectName]"
   - Choose the downloaded `GoogleService-Info.plist`
   - Make sure "Copy items if needed" is checked
   - Click "Add"

### 3.3 Update iOS Deployment Target

Ensure your iOS deployment target is set to iOS 12.0 or higher in Xcode.

## Step 4: Web Configuration (if needed)

### 4.1 Add Web App

1. In Firebase Console, click the gear icon → "Project settings"
2. Scroll down to "Your apps" section
3. Click the web icon (</>) to add a web app
4. Enter app nickname: "Food Delivery Web"
5. Click "Register app"

### 4.2 Copy Configuration

Copy the Firebase configuration object and use it in your web app if needed.

## Step 5: Test the Setup

### 5.1 Run the App

```bash
flutter run
```

### 5.2 Test Authentication

1. The app should start with the login screen
2. Try creating a new account using the signup screen
3. Test signing in with the created account
4. Verify that you can sign out and return to the login screen

## Step 6: Security Rules (Firestore)

### 6.1 Update Firestore Rules

In Firebase Console → Firestore Database → Rules, update the rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Add more rules for other collections as needed
    match /{document=**} {
      allow read, write: if false; // Default deny
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **"google-services.json not found"**

   - Ensure the file is in `android/app/` directory
   - Check that the package name matches exactly

2. **"Firebase not initialized"**

   - Ensure `Firebase.initializeApp()` is called before `runApp()`
   - Check that all Firebase dependencies are properly added

3. **Authentication not working**

   - Verify that Email/Password authentication is enabled in Firebase Console
   - Check that the app is properly registered in Firebase

4. **Build errors**
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check Gradle sync in Android Studio

### Debug Mode

Enable debug logging by adding this to your main.dart:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable debug mode
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

## Next Steps

1. **Add more authentication methods**: Google Sign-in, Phone, etc.
2. **Implement password reset functionality**
3. **Add email verification**
4. **Create user profile management**
5. **Add role-based access control**
6. **Implement social login**

## Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Flutter Provider Documentation](https://pub.dev/packages/provider)

## Support

If you encounter issues:

1. Check the Firebase Console for error logs
2. Verify your configuration files are in the correct locations
3. Ensure all dependencies are properly installed
4. Check Flutter and Firebase version compatibility
