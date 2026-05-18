// Firebase 설정 (웹 전용)
// 기존 firebase-config.js 와 동일한 example2-ed9e9 프로젝트를 그대로 사용합니다.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      '이 앱은 웹 전용으로 설정되어 있어요. (모바일은 미구성)',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1oq8py2I6r1vpQQXpVTLTT6HPLYqwfxo',
    appId: '1:281778091203:web:242aa9e3700e9a6f86de76',
    messagingSenderId: '281778091203',
    projectId: 'example2-ed9e9',
    authDomain: 'example2-ed9e9.firebaseapp.com',
    storageBucket: 'example2-ed9e9.firebasestorage.app',
    measurementId: 'G-CR7568W78Y',
  );
}
