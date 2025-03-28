// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAr0r2132tnR-13TyEsN9jrwwY6zIp1NLk',
    appId: '1:600820095452:android:b1885e6559f750f51d9719',
    messagingSenderId: '600820095452',
    projectId: 'foodkie',
    storageBucket: 'foodkie.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAr0r2132tnR-13TyEsN9jrwwY6zIp1NLk',
    appId: '1:600820095452:android:b1885e6559f750f51d9719',
    messagingSenderId: '600820095452',
    projectId: 'foodkie',
    storageBucket: 'foodkie.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAr0r2132tnR-13TyEsN9jrwwY6zIp1NLk',
    appId: '1:600820095452:android:b1885e6559f750f51d9719',
    messagingSenderId: '600820095452',
    projectId: 'foodkie',
    storageBucket: 'foodkie.firebasestorage.app',
    iosClientId: '', // Not provided in your JSON
    iosBundleId: 'com.infinite.foodkie.foodkie',
  );
}