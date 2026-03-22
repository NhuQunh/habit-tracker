import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0aHx2kofLFBGkTx8XqoXnbqp8py_CJ3E',
    appId: '1:768159940383:android:d177e90fe5a4b36083fa2a',
    messagingSenderId: '768159940383',
    projectId: 'habittracker-2bda8',
    storageBucket: 'habittracker-2bda8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'habittracker-2bda8',
    storageBucket: 'habittracker-2bda8.firebasestorage.app',
    iosBundleId: 'com.example.habitTracker',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyADAofHrhIqcleu6UqTyBYBA8yXk3nx7pU",
    authDomain: "habittracker-2bda8.firebaseapp.com",
    projectId: "habittracker-2bda8",
    storageBucket: "habittracker-2bda8.firebasestorage.app",
    messagingSenderId: "768159940383",
    appId: "1:768159940383:web:d39fb9858a36ef0c83fa2a",
    measurementId: "G-5P60R1F34M"
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'habittracker-2bda8',
    storageBucket: 'habittracker-2bda8.firebasestorage.app',
    iosBundleId: 'com.example.habitTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'habittracker-2bda8',
    authDomain: 'habittracker-2bda8.firebaseapp.com',
    storageBucket: 'habittracker-2bda8.firebasestorage.app',
  );
}