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
    apiKey: 'AIzaSyDptRRqcI6PUBDcRR5FAURPt3Hco7NJe34',
    appId: '1:247947302918:web:e4afbc9b1060cf2b5c4b87', // Guessed/Standard placeholder
    messagingSenderId: '247947302918',
    projectId: 'restaurant-order-managem-ee699',
    authDomain: 'restaurant-order-managem-ee699.firebaseapp.com',
    databaseURL: 'https://restaurant-order-managem-ee699-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'restaurant-order-managem-ee699.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDptRRqcI6PUBDcRR5FAURPt3Hco7NJe34',
    appId: '1:247947302918:android:e4afbc9b1060cf2b5c4b87',
    messagingSenderId: '247947302918',
    projectId: 'restaurant-order-managem-ee699',
    databaseURL: 'https://restaurant-order-managem-ee699-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'restaurant-order-managem-ee699.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDptRRqcI6PUBDcRR5FAURPt3Hco7NJe34',
    appId: '1:247947302918:ios:e4afbc9b1060cf2b5c4b87', // Placeholder
    messagingSenderId: '247947302918',
    projectId: 'restaurant-order-managem-ee699',
    databaseURL: 'https://restaurant-order-managem-ee699-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'restaurant-order-managem-ee699.firebasestorage.app',
    iosBundleId: 'com.riya.restaurantapp',
  );
}
