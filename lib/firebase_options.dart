// File generated for Firebase (diyetsel-platform).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCklLr5hnXjZMeWqNHikrWpdUquVsYFf_s',
    appId: '1:760739483719:android:edbae48ec9c0133b672162',
    messagingSenderId: '760739483719',
    projectId: 'diyetsel-platform',
    storageBucket: 'diyetsel-platform.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVAot-kPGZRsyobcT8FbPPVryJNXgeyx4',
    appId: '1:760739483719:ios:d4e9e235eee9decc672162',
    messagingSenderId: '760739483719',
    projectId: 'diyetsel-platform',
    storageBucket: 'diyetsel-platform.firebasestorage.app',
    iosBundleId: 'com.diyetsel.diyetsel',
    iosClientId:
        '760739483719-lf80i1804fdn6lm907d39sgom4orjtoh.apps.googleusercontent.com',
  );

  static const String googleWebClientId =
      '760739483719-msnpl8hj6utpdj4uho68vsbk3m641kcc.apps.googleusercontent.com';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4OVPv93mvVZNyoRyqmPmJ7GnUPZ6g8D4',
    appId: '1:760739483719:web:235db5d3b790733d672162',
    messagingSenderId: '760739483719',
    projectId: 'diyetsel-platform',
    authDomain: 'diyetsel-platform.firebaseapp.com',
    storageBucket: 'diyetsel-platform.firebasestorage.app',
  );

  static const FirebaseOptions windows = web;
}
