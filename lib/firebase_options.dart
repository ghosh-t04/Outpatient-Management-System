import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: "AIzaSyD3SkVLv3M-cnOIDObFtPqMbuX32ecXHQg",
      authDomain: "patient-7a77f.firebaseapp.com",
      projectId: "patient-7a77f",
      storageBucket: "patient-7a77f.appspot.com",
      messagingSenderId: "995776881642",
      appId: "1:995776881642:web:a25eb0510921149c728893",
      measurementId: "G-RVX43WNLER", // Only for web
    );
  }
}
