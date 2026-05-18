import 'package:flutter/material.dart';

/// 원본 웹사이트(index.html)의 다크 팔레트를 그대로 옮긴 색상.
class AppColors {
  static const bg = Color(0xFF0B0D11);
  static const bgSoft = Color(0xFF161A21);
  static const card = Color(0xFF13171E);
  static const text = Color(0xFFF4F6F8);
  static const textMid = Color(0xFFA5ACB8);
  static const textMuted = Color(0xFF6E7682);
  static const accent = Color(0xFFD4FF4D);
  static const accentSoft = Color(0xFFC6F432);
  static const onAccent = Color(0xFF0A0C10);
  static const border = Color(0xFF1F242D);
  static const borderStrong = Color(0xFF2C323D);

  // 심박수 존 컬러
  static const zoneRecovery = Color(0xFF8AA890);
  static const zoneFatburn = Color(0xFFE0AC72);
  static const zoneCardio = Color(0xFFE07A5F);
  static const zonePeak = Color(0xFFCF5C4A);
}

ThemeData buildTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bg,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}
