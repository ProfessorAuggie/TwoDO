import 'package:firebase_core/firebase_core.dart';
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

      case TargetPlatform.macOS:
        return macos;

      case TargetPlatform.windows:
        return windows;

      case TargetPlatform.linux:
        return linux;

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not '
          'supported for this platform.',
        );
    }
  }

  // WEB
  static const FirebaseOptions web =
      FirebaseOptions(
    apiKey:
        'AIzaSyA6B9E4DNx6Sq-owbmYqeZlL4-HXmLM4nw',

    appId:
        '1:649131416303:web:4f9a518d27648e0c87d91a',

    messagingSenderId:
        '649131416303',

    projectId:
        'twodo-auggie',

    authDomain:
        'twodo-auggie.firebaseapp.com',

    storageBucket:
        'twodo-auggie.firebasestorage.app',

    measurementId:
        'G-CH2CZJ5GZ9',
  );

  // ANDROID
  static const FirebaseOptions android =
      FirebaseOptions(
    apiKey:
        'AIzaSyA6B9E4DNx6Sq-owbmYqeZlL4-HXmLM4nw',

    appId:
        '1:649131416303:android:4f9a518d27648e0c87d91a',

    messagingSenderId:
        '649131416303',

    projectId:
        'twodo-auggie',

    storageBucket:
        'twodo-auggie.firebasestorage.app',
  );

  // IOS
  static const FirebaseOptions ios =
      FirebaseOptions(
    apiKey:
        'AIzaSyA6B9E4DNx6Sq-owbmYqeZlL4-HXmLM4nw',

    appId:
        '1:649131416303:ios:4f9a518d27648e0c87d91a',

    messagingSenderId:
        '649131416303',

    projectId:
        'twodo-auggie',

    storageBucket:
        'twodo-auggie.firebasestorage.app',

    iosBundleId:
        'com.twodo.app',
  );

  // MACOS
  static const FirebaseOptions macos =
      FirebaseOptions(
    apiKey:
        'AIzaSyA6B9E4DNx6Sq-owbmYqeZlL4-HXmLM4nw',

    appId:
        '1:649131416303:ios:4f9a518d27648e0c87d91a',

    messagingSenderId:
        '649131416303',

    projectId:
        'twodo-auggie',

    storageBucket:
        'twodo-auggie.firebasestorage.app',

    iosBundleId:
        'com.twodo.app',
  );

  // WINDOWS
  static const FirebaseOptions windows =
      FirebaseOptions(
    apiKey:
        'AIzaSyA6B9E4DNx6Sq-owbmYqeZlL4-HXmLM4nw',

    appId:
        '1:649131416303:web:4f9a518d27648e0c87d91a',

    messagingSenderId:
        '649131416303',

    projectId:
        'twodo-auggie',

    authDomain:
        'twodo-auggie.firebaseapp.com',

    storageBucket:
        'twodo-auggie.firebasestorage.app',
  );

  // LINUX
  static const FirebaseOptions linux =
      FirebaseOptions(
    apiKey:
        'AIzaSyA6B9E4DNx6Sq-owbmYqeZlL4-HXmLM4nw',

    appId:
        '1:649131416303:web:4f9a518d27648e0c87d91a',

    messagingSenderId:
        '649131416303',

    projectId:
        'twodo-auggie',

    authDomain:
        'twodo-auggie.firebaseapp.com',

    storageBucket:
        'twodo-auggie.firebasestorage.app',
  );
}