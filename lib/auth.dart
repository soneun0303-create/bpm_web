import 'package:firebase_auth/firebase_auth.dart';

/// 기존 firebase-config.js 의 authErrorMessage() 와 동일한 한국어 매핑.
String authErrorMessage(String code) {
  const map = {
    'email-already-in-use': '이미 가입된 이메일입니다.',
    'invalid-email': '이메일 형식이 올바르지 않습니다.',
    'weak-password': '비밀번호는 6자 이상이어야 합니다.',
    'missing-password': '비밀번호를 입력하세요.',
    'user-not-found': '가입되지 않은 이메일입니다.',
    'wrong-password': '비밀번호가 일치하지 않습니다.',
    'invalid-credential': '이메일 또는 비밀번호가 올바르지 않습니다.',
    'too-many-requests': '시도가 너무 많습니다. 잠시 후 다시 시도하세요.',
    'network-request-failed': '네트워크 연결을 확인하세요.',
    'operation-not-allowed':
        '이메일/비밀번호 로그인이 비활성화되어 있습니다. Firebase 콘솔에서 사용 설정하세요.',
    'configuration-not-found':
        'Firebase 인증이 아직 설정되지 않았습니다. 콘솔 > Authentication 에서 이메일/비밀번호를 사용 설정하세요.',
  };
  return map[code] ?? '오류가 발생했습니다. ($code)';
}

Future<UserCredential> signIn(String email, String password) {
  return FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
}

Future<UserCredential> signUp(
    String name, String email, String password) async {
  final cred = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);
  await cred.user?.updateDisplayName(name);
  return cred;
}

Future<void> signOutUser() => FirebaseAuth.instance.signOut();
