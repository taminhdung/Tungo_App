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
    apiKey: 'AIzaSyB6Lc0uiWjRkjyhJkT5to_VdzdXHkfn_VE',
    appId: '1:186655741107:web:20008f6c1a1272724bccc6',
    messagingSenderId: '186655741107',
    projectId: 'tungo-firebase',
    authDomain: 'tungo-firebase.firebaseapp.com',
    storageBucket: 'tungo-firebase.firebasestorage.app',
    measurementId: 'G-3VYQG9RZS5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB89YKb-U9_CKN4afK75Bi7CPG9Vx-neHc',
    appId: '1:186655741107:android:a9bb89b7cc603c784bccc6',
    messagingSenderId: '186655741107',
    projectId: 'tungo-firebase',
    storageBucket: 'tungo-firebase.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCPy6mvtbmPORm3Q_lCKlRop7ASt6eR8y8',
    appId: '1:186655741107:ios:3aeb494b4de76a954bccc6',
    messagingSenderId: '186655741107',
    projectId: 'tungo-firebase',
    storageBucket: 'tungo-firebase.firebasestorage.app',
    iosBundleId: 'com.example.tungoApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCPy6mvtbmPORm3Q_lCKlRop7ASt6eR8y8',
    appId: '1:186655741107:ios:3aeb494b4de76a954bccc6',
    messagingSenderId: '186655741107',
    projectId: 'tungo-firebase',
    storageBucket: 'tungo-firebase.firebasestorage.app',
    iosBundleId: 'com.example.tungoApplication',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB6Lc0uiWjRkjyhJkT5to_VdzdXHkfn_VE',
    appId: '1:186655741107:web:39411cb40bdca6684bccc6',
    messagingSenderId: '186655741107',
    projectId: 'tungo-firebase',
    authDomain: 'tungo-firebase.firebaseapp.com',
    storageBucket: 'tungo-firebase.firebasestorage.app',
    measurementId: 'G-H1QQRTJH7Z',
  );
}
