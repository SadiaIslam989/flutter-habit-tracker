
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUhLWst7NeAsMcXQmoi-l8RZ0tJe8Qz9E',
    appId: '1:961401462510:web:03905f7d4655f7c1a5ddff',
    messagingSenderId: '961401462510',
    projectId: 'habit-tracker-2-691fc',
    authDomain: 'habit-tracker-2-691fc.firebaseapp.com',
    storageBucket: 'habit-tracker-2-691fc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCymXyosUc6qKEXeibl3Ew2Iqw-7m7xMYs',
    appId: '1:961401462510:android:123268a7ea056413a5ddff',
    messagingSenderId: '961401462510',
    projectId: 'habit-tracker-2-691fc',
    storageBucket: 'habit-tracker-2-691fc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAX3FZQhO0ityo22eAnjM80ue_SSk4JvWs',
    appId: '1:961401462510:ios:9ad7c9f12b1b44c6a5ddff',
    messagingSenderId: '961401462510',
    projectId: 'habit-tracker-2-691fc',
    storageBucket: 'habit-tracker-2-691fc.firebasestorage.app',
    iosBundleId: 'com.example.habitTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAX3FZQhO0ityo22eAnjM80ue_SSk4JvWs',
    appId: '1:961401462510:ios:9ad7c9f12b1b44c6a5ddff',
    messagingSenderId: '961401462510',
    projectId: 'habit-tracker-2-691fc',
    storageBucket: 'habit-tracker-2-691fc.firebasestorage.app',
    iosBundleId: 'com.example.habitTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDUhLWst7NeAsMcXQmoi-l8RZ0tJe8Qz9E',
    appId: '1:961401462510:web:03905f7d4655f7c1a5ddff',
    messagingSenderId: '961401462510',
    projectId: 'habit-tracker-2-691fc',
    authDomain: 'habit-tracker-2-691fc.firebaseapp.com',
    storageBucket: 'habit-tracker-2-691fc.firebasestorage.app',
  );

}