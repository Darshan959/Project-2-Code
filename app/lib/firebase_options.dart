// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyAq1u7BL-7DBkCcFFfY4qG_EuXJwWen9Zc',
    appId: '1:634072828494:web:33739d3cb26b2cf3e7d11f',
    messagingSenderId: '634072828494',
    projectId: 'travel-project-darsh',
    authDomain: 'travel-project-darsh.firebaseapp.com',
    storageBucket: 'travel-project-darsh.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-WfNOB2LsWePOUWzHwr9cG4OhRwLg_0o',
    appId: '1:634072828494:android:eceaaab7e39ff6ebe7d11f',
    messagingSenderId: '634072828494',
    projectId: 'travel-project-darsh',
    storageBucket: 'travel-project-darsh.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAg_o0neB9TePO0K41n7WzvWxBrfKqovh0',
    appId: '1:634072828494:ios:210b6edb4492992ae7d11f',
    messagingSenderId: '634072828494',
    projectId: 'travel-project-darsh',
    storageBucket: 'travel-project-darsh.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAg_o0neB9TePO0K41n7WzvWxBrfKqovh0',
    appId: '1:634072828494:ios:210b6edb4492992ae7d11f',
    messagingSenderId: '634072828494',
    projectId: 'travel-project-darsh',
    storageBucket: 'travel-project-darsh.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAq1u7BL-7DBkCcFFfY4qG_EuXJwWen9Zc',
    appId: '1:634072828494:web:a03014f18ecf81c9e7d11f',
    messagingSenderId: '634072828494',
    projectId: 'travel-project-darsh',
    authDomain: 'travel-project-darsh.firebaseapp.com',
    storageBucket: 'travel-project-darsh.firebasestorage.app',
  );
}