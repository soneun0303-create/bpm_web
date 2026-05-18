import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'theme.dart';
import 'auth.dart';

/// auth.css 의 .auth-card 를 그대로 옮긴 공용 카드 레이아웃.
class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.title, required this.sub, required this.child});
  final String title;
  final String sub;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // 상단 라임 그라데이션 글로우
          Positioned(
            top: -240,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 800,
                height: 560,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0x24D4FF4D), Color(0x00D4FF4D)],
                    stops: [0.0, 0.62],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36, vertical: 40),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xD9000000),
                          blurRadius: 90,
                          offset: Offset(0, 40),
                          spreadRadius: -40),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/', (_) => false),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius:
                                    BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: const Text('♥',
                                  style: TextStyle(
                                      color: AppColors.onAccent,
                                      fontSize: 17)),
                            ),
                            const SizedBox(width: 10),
                            const Text('BPM Routine',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    letterSpacing: -0.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8)),
                      const SizedBox(height: 8),
                      Text(sub,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textMid,
                              fontSize: 14)),
                      const SizedBox(height: 28),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.label,
      required this.controller,
      this.obscure = false,
      this.hint,
      this.onSubmit});
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String? hint;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMid)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(
                color: AppColors.text, fontSize: 15),
            onSubmitted: (_) => onSubmit?.call(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.bgSoft,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    const BorderSide(color: AppColors.borderStrong),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    const BorderSide(color: AppColors.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg extends StatelessWidget {
  const _Msg(this.text, {required this.ok});
  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final color = ok ? AppColors.accent : const Color(0xFFFF9A9A);
    final bg = ok ? const Color(0x1AD4FF4D) : const Color(0x1AFF5C5C);
    final bd = ok ? const Color(0x59D4FF4D) : const Color(0x59FF5C5C);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bd),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 13.5, height: 1.5)),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton(
      {required this.label, required this.loading, required this.onTap});
  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.accent.withValues(alpha: loading ? 0.55 : 1),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: loading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onAccent),
                    )
                  : Text(label,
                      style: const TextStyle(
                          color: AppColors.onAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AltLink extends StatelessWidget {
  const _AltLink(
      {required this.text, required this.linkText, required this.onTap});
  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text,
              style: const TextStyle(
                  color: AppColors.textMid, fontSize: 14)),
          GestureDetector(
            onTap: onTap,
            child: Text(linkText,
                style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: const [
          Expanded(child: Divider(color: AppColors.borderStrong)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('또는',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ),
          Expanded(child: Divider(color: AppColors.borderStrong)),
        ],
      ),
    );
  }
}

/// 구글 로그인 버튼 (밝은 배경 + G 마크)
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onTap, required this.loading});
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: loading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF4285F4)),
                  child: const Text('G',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                const Text('Google 계정으로 계속하기',
                    style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== 로그인 =====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _loading = false;
  String _msg = '';
  bool _ok = false;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pw = _pw.text;
    if (email.isEmpty || pw.isEmpty) {
      setState(() {
        _ok = false;
        _msg = '이메일과 비밀번호를 모두 입력하세요.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _msg = '';
    });
    try {
      await signIn(email, pw);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } on EmailNotVerifiedException {
      setState(() {
        _ok = false;
        _msg = '아직 이메일 인증이 완료되지 않았어요.\n'
            '방금 인증 메일을 다시 보냈으니, 메일함(스팸함도)에서 링크를 누른 뒤 다시 로그인해 주세요.';
        _loading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _ok = false;
        _msg = authErrorMessage(e.code);
        _loading = false;
      });
    }
  }

  Future<void> _forgotPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    final emailCtrl = TextEditingController(text: _email.text.trim());
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('비밀번호 찾기',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('가입한 이메일을 입력하면 비밀번호 재설정 링크를 보내드려요.',
                style: TextStyle(
                    color: AppColors.textMid,
                    fontSize: 13.5,
                    height: 1.5)),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgSoft,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.borderStrong),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('닫기',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final em = emailCtrl.text.trim();
              if (em.isEmpty) {
                messenger.showSnackBar(const SnackBar(
                    content: Text('이메일을 입력하세요.')));
                return;
              }
              Navigator.of(ctx).pop();
              try {
                await sendPasswordReset(em);
                messenger.showSnackBar(const SnackBar(
                    content: Text(
                        '재설정 메일을 보냈어요. 메일함(스팸함도)을 확인하세요.')));
              } on FirebaseAuthException catch (e) {
                messenger.showSnackBar(
                    SnackBar(content: Text(authErrorMessage(e.code))));
              }
            },
            child: const Text('메일 보내기',
                style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    emailCtrl.dispose();
  }

  Future<void> _google() async {
    setState(() {
      _loading = true;
      _msg = '';
    });
    try {
      await signInWithGoogle();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _ok = false;
        _msg = authErrorMessage(e.code);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _ok = false;
        _msg = 'Google 로그인 중 문제가 발생했어요. 다시 시도해 주세요.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: '로그인',
      sub: '계정에 로그인하고 운동 루틴을 이어가세요.',
      child: Column(
        children: [
          _Msg(_msg, ok: _ok),
          _Field(
              label: '이메일',
              controller: _email,
              hint: 'you@example.com'),
          _Field(
              label: '비밀번호',
              controller: _pw,
              obscure: true,
              hint: '••••••••',
              onSubmit: _submit),
          const SizedBox(height: 6),
          _SubmitButton(
              label: '로그인', loading: _loading, onTap: _submit),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('비밀번호를 잊으셨나요?',
                  style: TextStyle(
                      color: AppColors.textMid, fontSize: 13)),
            ),
          ),
          const _OrDivider(),
          _GoogleButton(loading: _loading, onTap: _google),
          _AltLink(
            text: '아직 계정이 없으신가요? ',
            linkText: '회원가입',
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/signup'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (_) => false),
            child: const Text('← 홈으로 돌아가기',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ===================== 회원가입 =====================
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _loading = false;
  String _msg = '';
  bool _ok = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pw = _pw.text;
    final pw2 = _pw2.text;

    String? err;
    if (name.isEmpty) {
      err = '이름을 입력하세요.';
    } else if (email.isEmpty) {
      err = '이메일을 입력하세요.';
    } else if (pw.length < 6) {
      err = '비밀번호는 6자 이상이어야 합니다.';
    } else if (pw != pw2) {
      err = '비밀번호가 일치하지 않습니다.';
    }
    if (err != null) {
      setState(() {
        _ok = false;
        _msg = err!;
      });
      return;
    }

    setState(() {
      _loading = true;
      _msg = '';
    });
    try {
      await signUp(name, email, pw);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('가입 완료 🎉',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          content: Text(
            '$email 로 인증 메일을 보냈어요.\n'
            '메일함(스팸함도 확인)에서 링크를 눌러 이메일 인증을 완료한 뒤,\n'
            '로그인하면 서비스를 이용할 수 있어요. (인증 전에는 로그인되지 않습니다)',
            style: const TextStyle(
                color: AppColors.textMid, fontSize: 14, height: 1.55),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _ok = false;
        _msg = authErrorMessage(e.code);
        _loading = false;
      });
    }
  }

  Future<void> _google() async {
    setState(() {
      _loading = true;
      _msg = '';
    });
    try {
      await signInWithGoogle();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _ok = false;
        _msg = authErrorMessage(e.code);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _ok = false;
        _msg = 'Google 로그인 중 문제가 발생했어요. 다시 시도해 주세요.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: '회원가입',
      sub: '계정을 만들고 나만의 심박수 루틴을 시작하세요.',
      child: Column(
        children: [
          _Msg(_msg, ok: _ok),
          _Field(label: '이름', controller: _name, hint: '홍길동'),
          _Field(
              label: '이메일',
              controller: _email,
              hint: 'you@example.com'),
          _Field(
              label: '비밀번호',
              controller: _pw,
              obscure: true,
              hint: '6자 이상'),
          _Field(
              label: '비밀번호 확인',
              controller: _pw2,
              obscure: true,
              hint: '비밀번호 다시 입력',
              onSubmit: _submit),
          const SizedBox(height: 6),
          _SubmitButton(
              label: '회원가입', loading: _loading, onTap: _submit),
          const _OrDivider(),
          _GoogleButton(loading: _loading, onTap: _google),
          _AltLink(
            text: '이미 계정이 있으신가요? ',
            linkText: '로그인',
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (_) => false),
            child: const Text('← 홈으로 돌아가기',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
