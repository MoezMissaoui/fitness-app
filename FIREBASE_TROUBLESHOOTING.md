# Firebase Troubleshooting Guide

## Error: "Unable to establish connection on channel"

This error typically occurs when Firebase is not properly configured on the native side. Follow these steps:

### Step 1: Verify Configuration Files

1. **Check `google-services.json`**:
   - Location: `android/app/google-services.json`
   - Must be downloaded from Firebase Console
   - Must match your app's package name: `com.example.fitness_app`

2. **Check `firebase_options.dart`**:
   - Location: `lib/core/firebase/firebase_options.dart`
   - Must contain real values (not placeholders like `YOUR_ANDROID_API_KEY`)
   - Values should match your Firebase project

### Step 2: Clean and Rebuild

Run these commands in order:

```bash
# 1. Clean Flutter build
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Clean Android build (if on Windows, use gradlew.bat)
cd android
./gradlew clean
cd ..

# 4. Rebuild the app
flutter run
```

### Step 3: Verify Gradle Configuration

1. **Check `android/build.gradle.kts`** (project-level):
   ```kotlin
   buildscript {
       dependencies {
           classpath("com.google.gms:google-services:4.4.2")
       }
   }
   ```

2. **Check `android/app/build.gradle.kts`** (app-level):
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   
   defaultConfig {
       minSdk = 21  // Firebase requires at least 21
   }
   ```

### Step 4: Verify Firebase Initialization

Check `lib/main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase must be initialized FIRST
  await initializeFirebase();
  
  // Then other services
  await ServiceLocator.instance.init();
  
  runApp(const MyApp());
}
```

### Step 5: Check Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `fitness-app-4f62a`
3. Go to **Project Settings** → **Your apps**
4. Verify Android app is registered with package name: `com.example.fitness_app`
5. Verify Authentication is enabled (Authentication → Sign-in method)

### Step 6: Common Issues and Solutions

#### Issue: "google-services.json not found"
**Solution:**
- Make sure the file is in `android/app/` (not `android/`)
- Download a fresh copy from Firebase Console
- Verify the package name matches

#### Issue: "DefaultFirebaseOptions have not been configured"
**Solution:**
- Run `flutterfire configure` OR
- Manually update `firebase_options.dart` with values from Firebase Console

#### Issue: "minSdkVersion too low"
**Solution:**
- Set `minSdk = 21` in `android/app/build.gradle.kts`
- Firebase requires Android API level 21 (Android 5.0) or higher

#### Issue: "Build fails after adding Google Services"
**Solution:**
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

#### Issue: "App crashes on startup"
**Solution:**
- Check that Firebase is initialized BEFORE other services
- Verify `firebase_options.dart` has correct values
- Check logcat for detailed error messages:
  ```bash
  flutter run --verbose
  ```

### Step 7: Verify Firebase Options

Your `firebase_options.dart` should look like this (with YOUR values):

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...',  // From google-services.json
  appId: '1:1014304523758:android:...',  // From google-services.json
  messagingSenderId: '1014304523758',  // project_number
  projectId: 'fitness-app-4f62a',  // project_id
  storageBucket: 'fitness-app-4f62a.firebasestorage.app',  // storage_bucket
);
```

### Step 8: Test Firebase Connection

After fixing the configuration, test with:

```dart
// In your app, try:
final authService = ServiceLocator.instance.authService;
print('Auth service available: ${authService != null}');
print('Current user: ${authService.currentUser?.email ?? 'Not logged in'}');
```

### Still Not Working?

1. **Check Android Logcat**:
   ```bash
   flutter run --verbose
   ```
   Look for Firebase-related errors

2. **Verify Internet Connection**:
   - Firebase requires internet for initialization
   - Check device/emulator has network access

3. **Try on a Physical Device**:
   - Sometimes emulators have network issues
   - Test on a real Android device

4. **Check Firebase Project Status**:
   - Go to Firebase Console
   - Verify project is active
   - Check for any warnings or errors

5. **Re-run FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This will regenerate `firebase_options.dart` with correct values

### Quick Fix Checklist

- [ ] `google-services.json` is in `android/app/`
- [ ] `firebase_options.dart` has real values (not placeholders)
- [ ] `minSdk = 21` in `android/app/build.gradle.kts`
- [ ] Google Services plugin added to both Gradle files
- [ ] Firebase initialized in `main.dart` BEFORE other services
- [ ] Ran `flutter clean` and `flutter pub get`
- [ ] Ran `./gradlew clean` in android folder
- [ ] Authentication enabled in Firebase Console
- [ ] Internet connection available

If all items are checked and it still doesn't work, the issue might be with the Firebase project itself. Try creating a new Firebase project and reconfiguring.

