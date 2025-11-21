# Firebase Authentication Setup Guide

This guide will help you configure Firebase Authentication for your Fitness App.

## ✅ What's Already Done

- ✅ Firebase packages added to `pubspec.yaml` (`firebase_core`, `firebase_auth`, `cloud_firestore`)
- ✅ Android build files configured with Google Services plugin
- ✅ Firebase initialization code added to `main.dart`
- ✅ `AuthService` implemented with all authentication methods
- ✅ `AuthService` added to `ServiceLocator`

## 📋 Step-by-Step Configuration

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select an existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "Fitness App")
   - Enable/disable Google Analytics (optional)
   - Click **"Create project"**
4. Wait for the project to be created

### Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Get started**
2. Click **Sign-in method** tab
3. Enable **Email/Password**:
   - Click on **Email/Password**
   - Toggle **Enable** to ON
   - Click **Save**
4. (Optional) Enable other providers:
   - **Google Sign-In**: For Google authentication
   - **Apple Sign-In**: For iOS users
   - **Phone**: For phone number authentication

### Step 3: Add Android App to Firebase

1. In Firebase Console, click the **Android icon** (or go to **Project Settings** → **Add app**)
2. Register your Android app:
   - **Android package name**: `com.example.fitness_app`
     - You can verify this in `android/app/build.gradle.kts` (look for `applicationId`)
   - **App nickname**: "Fitness App Android" (optional)
   - **Debug signing certificate SHA-1**: (optional, only needed for Google Sign-In)
     - To get SHA-1: Run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
3. Click **Register app**
4. Download `google-services.json`
5. **Replace** the existing file at: `android/app/google-services.json`
   - ⚠️ **Important**: Make sure the file is in `android/app/` (not `android/`)

### Step 4: Configure Firebase Options (Using FlutterFire CLI - Recommended)

The easiest way to configure Firebase is using the FlutterFire CLI:

1. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Login to Firebase** (if not already logged in):
   ```bash
   firebase login
   ```

3. **Configure Firebase**:
   ```bash
   flutterfire configure
   ```
   
   This command will:
   - Detect your Firebase projects
   - Ask you to select your project
   - Ask you to select platforms (Android, iOS, etc.)
   - Automatically update `lib/core/firebase/firebase_options.dart` with your project's configuration
   - Verify that `google-services.json` is in the correct location

4. **Verify the configuration**:
   - Check that `lib/core/firebase/firebase_options.dart` has been updated with your Firebase project values
   - The file should contain real values (not `YOUR_ANDROID_API_KEY`, etc.)

### Step 5: Manual Configuration (Alternative Method)

If you prefer to configure manually or FlutterFire CLI doesn't work:

1. **Get your Firebase configuration**:
   - Go to Firebase Console → **Project Settings** (gear icon)
   - Scroll down to **Your apps** section
   - Click on your Android app
   - You'll see your configuration values

2. **Update `lib/core/firebase/firebase_options.dart`**:
   - Open `lib/core/firebase/firebase_options.dart`
   - Replace the placeholder values in the `android` section:
     ```dart
     static const FirebaseOptions android = FirebaseOptions(
       apiKey: 'YOUR_API_KEY_HERE',           // From Firebase Console
       appId: 'YOUR_APP_ID_HERE',             // From Firebase Console
       messagingSenderId: 'YOUR_SENDER_ID',   // From Firebase Console
       projectId: 'YOUR_PROJECT_ID',           // From Firebase Console
       storageBucket: 'YOUR_STORAGE_BUCKET',  // From Firebase Console
     );
     ```

3. **For iOS** (if needed):
   - Add iOS app in Firebase Console
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/GoogleService-Info.plist`
   - Update the `ios` section in `firebase_options.dart` similarly

### Step 6: Verify Configuration

1. **Check Android configuration**:
   - ✅ `android/app/google-services.json` exists and is from your Firebase project
   - ✅ `android/build.gradle.kts` has Google Services classpath
   - ✅ `android/app/build.gradle.kts` has Google Services plugin

2. **Check Flutter configuration**:
   - ✅ `lib/core/firebase/firebase_options.dart` has real values (not placeholders)
   - ✅ `lib/main.dart` initializes Firebase
   - ✅ `lib/di/service_locator.dart` includes `AuthService`

### Step 7: Test the Setup

1. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Check the console**:
   - You should see: `✅ Firebase initialisé avec succès`
   - If you see an error, check the troubleshooting section below

## 🔧 Using Authentication in Your App

The `AuthService` is already implemented and available through `ServiceLocator`. Here's how to use it:

```dart
// Get the auth service
final authService = ServiceLocator.instance.authService;

// Sign up
final result = await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
);

// Sign in
final result = await authService.signIn(
  email: 'user@example.com',
  password: 'password123',
);

// Check if user is authenticated
if (authService.isAuthenticated) {
  final user = authService.currentUser;
  print('User: ${user?.email}');
}

// Update profile
final result = await authService.updateProfile(
  displayName: 'Jane Doe',
  photoUrl: 'https://example.com/photo.jpg',
);

// Change password
final result = await authService.changePassword(
  currentPassword: 'oldPassword',
  newPassword: 'newPassword',
);

// Sign out
await authService.signOut();

// Listen to auth state changes
authService.authStateChanges.listen((User? user) {
  if (user != null) {
    print('User signed in: ${user.email}');
  } else {
    print('User signed out');
  }
});
```

## 🐛 Troubleshooting

### Android Issues

**Error: "google-services.json not found"**
- Make sure `google-services.json` is in `android/app/` (not `android/`)
- Verify the file was downloaded from Firebase Console
- Run `flutter clean` and rebuild

**Error: "DefaultFirebaseOptions have not been configured"**
- Run `flutterfire configure` or manually update `firebase_options.dart`
- Make sure the file has real values, not placeholders

**Error: "minSdkVersion" issues**
- Check that `minSdkVersion` is at least 21 in `android/app/build.gradle.kts`
- Update if necessary: `minSdk = 21`

**Build errors after adding Google Services**
- Run `flutter clean`
- Delete `android/.gradle` folder
- Run `flutter pub get`
- Rebuild the app

### iOS Issues (if applicable)

**Error: "GoogleService-Info.plist not found"**
- Make sure the file is in `ios/Runner/GoogleService-Info.plist`
- Add it to Xcode project: Right-click `Runner` → Add Files to "Runner"

**Pod installation errors**
- Run `cd ios && pod install && cd ..`
- If that doesn't work: `cd ios && pod deintegrate && pod install && cd ..`

### General Issues

**Firebase initialization fails**
- Verify `firebase_options.dart` has correct values
- Check that Authentication is enabled in Firebase Console
- Ensure internet connection is available
- Check Firebase Console for any project issues

**Authentication methods not working**
- Verify Email/Password is enabled in Firebase Console → Authentication → Sign-in method
- Check that the email format is valid
- Ensure password meets Firebase requirements (minimum 6 characters)

**"User not found" or "Wrong password" errors**
- These are expected errors when credentials are incorrect
- Make sure you're using the correct email/password
- Check Firebase Console → Authentication → Users to see registered users

## 📚 Next Steps

After Firebase is configured, you can:

1. **Create login/register UI pages**:
   - Create `lib/features/auth/pages/login_page.dart`
   - Create `lib/features/auth/pages/register_page.dart`
   - Create `lib/features/auth/pages/profile_page.dart` for updating user info

2. **Add authentication state management**:
   - Use `StreamBuilder` with `authService.authStateChanges` to listen to auth state
   - Redirect users to login if not authenticated
   - Show different UI based on auth state

3. **Implement user profile management**:
   - Use `authService.updateProfile()` to update user information
   - Use `authService.changePassword()` for password changes
   - Store additional user data in Firestore

## 📱 Ajouter iOS Plus Tard

Si vous développez uniquement pour Android maintenant, vous pouvez ajouter iOS plus tard. Consultez le guide détaillé :

👉 **[FIREBASE_IOS_SETUP_GUIDE.md](FIREBASE_IOS_SETUP_GUIDE.md)** - Guide complet pour ajouter iOS à Firebase

**Résumé rapide** :
1. Ajouter l'app iOS dans Firebase Console
2. Télécharger `GoogleService-Info.plist`
3. L'ajouter au projet Xcode
4. Exécuter `flutterfire configure` (sélectionner Android + iOS)
5. Exécuter `pod install` dans `ios/`

## 🔗 Useful Links

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

## ✅ Checklist

Before you start using authentication, make sure:

- [ ] Firebase project created
- [ ] Authentication enabled (Email/Password)
- [ ] Android app added to Firebase
- [ ] `google-services.json` downloaded and placed correctly
- [ ] `flutterfire configure` run successfully (or manual configuration done)
- [ ] `firebase_options.dart` has real values (not placeholders)
- [ ] App runs without Firebase errors
- [ ] Console shows "✅ Firebase initialisé avec succès"

Once all items are checked, you're ready to use Firebase Authentication! 🎉
