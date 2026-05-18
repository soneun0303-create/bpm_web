// ============================================================
//  Firebase 설정
// ------------------------------------------------------------
//  ▼▼▼ 아래 firebaseConfig 값을 본인 프로젝트 값으로 교체하세요 ▼▼▼
//
//  설정 방법:
//   1. https://console.firebase.google.com 접속 → 프로젝트 생성
//   2. 좌측 '빌드 > Authentication' → 시작하기
//        → 'Sign-in method' 탭에서 '이메일/비밀번호' 사용 설정
//   3. 프로젝트 설정(톱니바퀴) → '내 앱'에서 웹 앱(</>) 추가
//   4. 표시되는 firebaseConfig 객체를 그대로 아래에 붙여넣기
//   5. Authentication > Settings > '승인된 도메인'에
//        실행할 도메인 추가 (localhost 는 기본 포함됨)
// ============================================================

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";

const firebaseConfig = {
  apiKey: "AIzaSyC1oq8py2I6r1vpQQXpVTLTT6HPLYqwfxo",
  authDomain: "example2-ed9e9.firebaseapp.com",
  projectId: "example2-ed9e9",
  storageBucket: "example2-ed9e9.firebasestorage.app",
  messagingSenderId: "281778091203",
  appId: "1:281778091203:web:242aa9e3700e9a6f86de76",
  measurementId: "G-CR7568W78Y",
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);

// 한국어 오류 메시지 매핑 (로그인/회원가입 공용)
export function authErrorMessage(code) {
  const map = {
    "auth/email-already-in-use": "이미 가입된 이메일입니다.",
    "auth/invalid-email": "이메일 형식이 올바르지 않습니다.",
    "auth/weak-password": "비밀번호는 6자 이상이어야 합니다.",
    "auth/missing-password": "비밀번호를 입력하세요.",
    "auth/user-not-found": "가입되지 않은 이메일입니다.",
    "auth/wrong-password": "비밀번호가 일치하지 않습니다.",
    "auth/invalid-credential": "이메일 또는 비밀번호가 올바르지 않습니다.",
    "auth/too-many-requests": "시도가 너무 많습니다. 잠시 후 다시 시도하세요.",
    "auth/network-request-failed": "네트워크 연결을 확인하세요.",
    "auth/operation-not-allowed":
      "이메일/비밀번호 로그인이 비활성화되어 있습니다. Firebase 콘솔에서 사용 설정하세요.",
    "auth/configuration-not-found":
      "Firebase 인증이 아직 설정되지 않았습니다. 콘솔 > Authentication > 시작하기 후 '이메일/비밀번호'를 사용 설정하세요.",
  };
  return map[code] || ("오류가 발생했습니다. (" + code + ")");
}
