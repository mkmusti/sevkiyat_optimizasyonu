import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyA-5gK6DJqg7BNirV3ipn77L4fgGGwNAEE',
    appId: '1:547787121667:web:f07c384e035553b6711a36',
    messagingSenderId: '547787121667',
    projectId: 'sevkiyat-optimizasyon-api',
    authDomain: 'sevkiyat-optimizasyon-api.firebaseapp.com',
    storageBucket: 'sevkiyat-optimizasyon-api.firebasestorage.app',
    measurementId: 'G-EDTYQ9CS43',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1PTV4i-J2R9y0Rv4zP8VdDt1dje_vAcs',
    appId: '1:547787121667:android:c3bfb62a9207f2c6711a36',
    messagingSenderId: '547787121667',
    projectId: 'sevkiyat-optimizasyon-api',
    storageBucket: 'sevkiyat-optimizasyon-api.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDT7lhBHSk7L9Djzvm7Gn-RdLR48LE4_Qc',
    appId: '1:547787121667:ios:330f16bd86201a4f711a36',
    messagingSenderId: '547787121667',
    projectId: 'sevkiyat-optimizasyon-api',
    storageBucket: 'sevkiyat-optimizasyon-api.firebasestorage.app',
    iosClientId: '547787121667-rca7sdao39in0lta7f0cmnck06cbne7p.apps.googleusercontent.com',
    iosBundleId: 'com.karaosman.sevkiyatOptimizasyonu',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDT7lhBHSk7L9Djzvm7Gn-RdLR48LE4_Qc',
    appId: '1:547787121667:ios:330f16bd86201a4f711a36',
    messagingSenderId: '547787121667',
    projectId: 'sevkiyat-optimizasyon-api',
    storageBucket: 'sevkiyat-optimizasyon-api.firebasestorage.app',
    iosClientId: '547787121667-rca7sdao39in0lta7f0cmnck06cbne7p.apps.googleusercontent.com',
    iosBundleId: 'com.karaosman.sevkiyatOptimizasyonu',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA-5gK6DJqg7BNirV3ipn77L4fgGGwNAEE',
    appId: '1:547787121667:web:5f566b7c08697d8f711a36',
    messagingSenderId: '547787121667',
    projectId: 'sevkiyat-optimizasyon-api',
    authDomain: 'sevkiyat-optimizasyon-api.firebaseapp.com',
    storageBucket: 'sevkiyat-optimizasyon-api.firebasestorage.app',
    measurementId: 'G-6GW88G61Q7',
  );
}
