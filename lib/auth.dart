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

/// 이메일 미인증 상태로 로그인을 시도했을 때 던지는 예외
class EmailNotVerifiedException implements Exception {
  EmailNotVerifiedException(this.email);
  final String email;
}

Future<UserCredential> signIn(String email, String password) async {
  final auth = FirebaseAuth.instance;
  final cred = await auth.signInWithEmailAndPassword(
      email: email, password: password);
  // 이메일 인증을 완료하지 않았으면 로그인 차단
  if (cred.user != null && !cred.user!.emailVerified) {
    auth.setLanguageCode('ko');
    try {
      await cred.user!.sendEmailVerification(); // 인증 메일 재발송
    } catch (_) {
      // 재발송 실패(예: too-many-requests)는 무시하고 차단만
    }
    await auth.signOut();
    throw EmailNotVerifiedException(email);
  }
  return cred;
}

/// 회원가입: 계정 생성 + 인증 메일 발송 후 로그아웃 (인증 전엔 로그인 불가)
Future<void> signUp(String name, String email, String password) async {
  final auth = FirebaseAuth.instance;
  auth.setLanguageCode('ko'); // 인증/재설정 메일을 한국어로
  final cred = await auth.createUserWithEmailAndPassword(
      email: email, password: password);
  await cred.user?.updateDisplayName(name);
  await cred.user?.sendEmailVerification();
  await auth.signOut(); // 이메일 인증 전에는 로그인 상태로 두지 않음
}

/// 현재 로그인한 사용자에게 인증 메일 재발송
Future<void> resendVerification() async {
  final auth = FirebaseAuth.instance;
  auth.setLanguageCode('ko');
  await auth.currentUser?.sendEmailVerification();
}

/// 사용자 정보 새로고침 후 이메일 인증 여부 반환
Future<bool> refreshEmailVerified() async {
  final user = FirebaseAuth.instance.currentUser;
  await user?.reload();
  return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
}

/// 비밀번호 재설정 메일 발송
Future<void> sendPasswordReset(String email) async {
  final auth = FirebaseAuth.instance;
  auth.setLanguageCode('ko');
  await auth.sendPasswordResetEmail(email: email);
}

Future<void> signOutUser() => FirebaseAuth.instance.signOut();
