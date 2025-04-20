// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCMDIjpgMK3TdKKnPFGziRxGCRD3qeH_jw",
    authDomain: "elder-life-45a2e.firebaseapp.com",
    projectId: "elder-life-45a2e",
    storageBucket: "elder-life-45a2e.firebasestorage.app",
    messagingSenderId: "714129458266",
    appId: "1:714129458266:web:978d6820257514eac0c463",
    measurementId: "G-JGENF936RJ",
    databaseURL: "https://elder-life-45a2e.firebaseio.com", // Add this line
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBe_Q6JdSWXixZ096nnyFUsipal23888xo",
    appId: "1:714129458266:android:ae879f3ecf48a106c0c463",
    messagingSenderId: "714129458266",
    projectId: "elder-life-45a2e",
    storageBucket: "elder-life-45a2e.firebasestorage.app",
    databaseURL: "https://elder-life-45a2e.firebaseio.com", // Add this line
  );
}
