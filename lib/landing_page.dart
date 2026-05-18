import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'theme.dart';
import 'auth.dart';

const double _maxW = 1120;

/// 상단/푸터 메뉴가 가리키는 섹션
enum _Section { features, calc, goals, how, cta }

/// 자손 위젯이 섹션으로 스크롤할 수 있게 해주는 스코프
class _NavScope extends InheritedWidget {
  const _NavScope({required this.scrollTo, required super.child});
  final void Function(_Section) scrollTo;

  static _NavScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_NavScope>()!;

  @override
  bool updateShouldNotify(_NavScope oldWidget) => false;
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final Map<_Section, GlobalKey> _keys = {
    _Section.features: GlobalKey(),
    _Section.calc: GlobalKey(),
    _Section.goals: GlobalKey(),
    _Section.how: GlobalKey(),
    _Section.cta: GlobalKey(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(_Section s) {
    final ctx = _keys[s]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _NavScope(
      scrollTo: _scrollTo,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const _NavBar(),
              const _VerifyBanner(),
              const _Hero(),
              KeyedSubtree(
                  key: _keys[_Section.features]!, child: const _Features()),
              KeyedSubtree(
                  key: _keys[_Section.calc]!, child: const _Calculator()),
              KeyedSubtree(
                  key: _keys[_Section.goals]!, child: const _Goals()),
              KeyedSubtree(
                  key: _keys[_Section.how]!, child: const _HowItWorks()),
              KeyedSubtree(
                  key: _keys[_Section.cta]!, child: const _CtaSection()),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 가운데 정렬 + 최대폭 제한 래퍼 (원본의 .wrap)
class _Wrap extends StatelessWidget {
  const _Wrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxW),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size + 12,
          height: size + 12,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text('♥',
              style: TextStyle(
                  color: AppColors.onAccent, fontSize: size - 1)),
        ),
        const SizedBox(width: 10),
        Text('BPM Routine',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: size,
                letterSpacing: -0.5)),
      ],
    );
  }
}

/// 둥근 버튼 (원본 .btn)
class _PillButton extends StatelessWidget {
  const _PillButton(
      {required this.label,
      required this.onTap,
      this.primary = false,
      this.small = false,
      this.icon});
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool small;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? AppColors.accent : Colors.transparent;
    final fg = primary ? AppColors.onAccent : AppColors.text;
    return Material(
      color: bg,
      shape: StadiumBorder(
        side: primary
            ? BorderSide.none
            : const BorderSide(color: AppColors.borderStrong),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: small ? 18 : 22, vertical: small ? 9 : 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Text(icon!, style: TextStyle(color: fg, fontSize: 14)),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: small ? 14 : 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 760;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD90B0D11),
        border:
            Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: _Wrap(
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              const _Logo(),
              const Spacer(),
              if (!narrow) ...[
                _NavLink('기능',
                    onTap: () =>
                        _NavScope.of(context).scrollTo(_Section.features)),
                _NavLink('심박수 존',
                    onTap: () =>
                        _NavScope.of(context).scrollTo(_Section.calc)),
                _NavLink('운동 목표',
                    onTap: () =>
                        _NavScope.of(context).scrollTo(_Section.goals)),
                _NavLink('사용법',
                    onTap: () =>
                        _NavScope.of(context).scrollTo(_Section.how)),
                const SizedBox(width: 28),
              ],
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snap) {
                  final user = snap.data;
                  if (user == null) {
                    return _PillButton(
                      label: '로그인',
                      small: true,
                      onTap: () =>
                          Navigator.pushNamed(context, '/login'),
                    );
                  }
                  return _AccountMenu(
                      label: '${user.displayName ?? user.email} 님');
                },
              ),
              const SizedBox(width: 10),
              _PillButton(
                  label: '앱 받기',
                  small: true,
                  primary: true,
                  onTap: () =>
                      _NavScope.of(context).scrollTo(_Section.cta)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, {this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.textMid,
                fontSize: 14.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 900;
    final copy = _HeroCopy(center: narrow);
    const phone = _PhoneMockup();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 90),
      child: _Wrap(
        child: narrow
            ? Column(children: const [phone, SizedBox(height: 50), _HeroCopy(center: true)])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 105, child: copy),
                  const SizedBox(width: 56),
                  const Expanded(flex: 95, child: Center(child: phone)),
                ],
              ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({this.center = false});
  final bool center;

  @override
  Widget build(BuildContext context) {
    final align =
        center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x1AD4FF4D),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x40D4FF4D)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('심박수 기반 유산소 가이드',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: center ? TextAlign.center : TextAlign.start,
          text: const TextSpan(
            style: TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w800,
                height: 1.08,
                letterSpacing: -2,
                color: AppColors.text),
            children: [
              TextSpan(text: '오늘 운동, '),
              TextSpan(
                  text: '몇 BPM',
                  style: TextStyle(color: AppColors.accent)),
              TextSpan(text: '으로\n뛰어야 할까?'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            '나이와 운동 목표만 고르면 — 목표 심박수 구간과 권장 운동 시간을 '
            '계산해 단계별 타이머로 안내합니다. 막연한 유산소는 그만.',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
                fontSize: 17.5, color: AppColors.textMid, height: 1.65),
          ),
        ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _PillButton(
                label: '앱 다운로드',
                icon: '⬇',
                primary: true,
                onTap: () =>
                    _NavScope.of(context).scrollTo(_Section.cta)),
            _PillButton(
                label: '내 심박수 존 보기',
                onTap: () =>
                    _NavScope.of(context).scrollTo(_Section.calc)),
          ],
        ),
        const SizedBox(height: 46),
        Container(
          padding: const EdgeInsets.only(top: 30),
          decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: AppColors.border))),
          child: Wrap(
            spacing: 40,
            runSpacing: 20,
            children: const [
              _Stat('5종', '운동 목표 프리셋'),
              _Stat('4구간', '심박수 존 분석'),
              _Stat('220 − 나이', '최대 심박수 공식'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.num, this.lab);
  final String num;
  final String lab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(num,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -1)),
        const SizedBox(height: 2),
        Text(lab,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }
}

class _BeatingHeart extends StatefulWidget {
  const _BeatingHeart();
  @override
  State<_BeatingHeart> createState() => _BeatingHeartState();
}

class _BeatingHeartState extends State<_BeatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        double s = 1;
        if (t < 0.14) {
          s = 1 + (0.22 * (t / 0.14));
        } else if (t < 0.28) {
          s = 1.22 - (0.22 * ((t - 0.14) / 0.14));
        } else if (t < 0.42) {
          s = 1 + (0.16 * ((t - 0.28) / 0.14));
        } else if (t < 0.5) {
          s = 1.16 - (0.16 * ((t - 0.42) / 0.08));
        }
        return Transform.scale(scale: s, child: child);
      },
      child: const Text('♥',
          style: TextStyle(color: AppColors.zonePeak, fontSize: 56)),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      height: 590,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: const [
          BoxShadow(
              color: Color(0xCC000000),
              blurRadius: 90,
              offset: Offset(0, 40),
              spreadRadius: -30),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 44, 20, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E1218), Color(0xFF0A0C10)]),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('현재 심박수',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _BeatingHeart(),
                SizedBox(width: 10),
                Text('142',
                    style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -3,
                        height: 1.1)),
                SizedBox(width: 6),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('bpm',
                      style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: const [
                  _ScrZoneRow(AppColors.zoneRecovery, '회복', '93–112'),
                  _ScrZoneRow(
                      AppColors.zoneFatburn, '지방 연소', '112–130'),
                  _ScrZoneRow(AppColors.zoneCardio, '유산소', '130–158',
                      live: true),
                  _ScrZoneRow(AppColors.zonePeak, '고강도', '158–186'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text('❚❚',
                      style: TextStyle(
                          color: AppColors.onAccent, fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('18:24',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1)),
                    Text('메인 구간 · 체력 향상',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrZoneRow extends StatelessWidget {
  const _ScrZoneRow(this.color, this.name, this.val, {this.live = false});
  final Color color;
  final String name;
  final String val;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: 9, horizontal: live ? 8 : 0),
      decoration: BoxDecoration(
        color: live ? const Color(0x14D4FF4D) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
              width: 9,
              height: 9,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(name,
              style: const TextStyle(
                  color: AppColors.textMid, fontSize: 12.5)),
          const Spacer(),
          Text(val,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12.5)),
        ],
      ),
    );
  }
}

/// 섹션 공통 헤더
class _SecHead extends StatelessWidget {
  const _SecHead(this.tag, this.title, [this.desc]);
  final String tag;
  final String title;
  final String? desc;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5)),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                  height: 1.18)),
          if (desc != null) ...[
            const SizedBox(height: 14),
            Text(desc!,
                style: const TextStyle(
                    color: AppColors.textMid, fontSize: 16.5)),
          ],
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    const items = [
      ['❤️', '심박수 존 계산',
        '나이로 최대 심박수를 구하고 회복·지방연소·유산소·고강도 4구간을 BPM으로 안내합니다.'],
      ['⏱️', '단계별 타이머',
        '준비 · 메인 · 마무리 구간을 자동으로 나눠 안내하고 일시정지·종료를 컨트롤합니다.'],
      ['🎯', '운동 목표 5종',
        '마라톤, 등산, 체력 향상, 지방 감량, 회복 운동 — 목표별 강도·시간 프리셋.'],
      ['🔥', '식단 · 칼로리 기록',
        '섭취 칼로리와 식단을 기록해 운동량과 함께 한눈에 비교합니다.'],
      ['📊', '인바디 추적',
        '체중·골격근량·체지방률 변화를 기록해 루틴의 효과를 시각화합니다.'],
      ['👥', '친구와 함께',
        '친구를 추가해 서로의 운동 기록을 확인하며 동기를 유지합니다.'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 92),
      child: _Wrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SecHead('Features', '감으로 하던 유산소를\n숫자로 바꿔주는 기능들',
                '심박수 가이드부터 식단·인바디 기록까지, 유산소 루틴에 필요한 걸 한 앱에서.'),
            const SizedBox(height: 54),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth < 600
                  ? 1
                  : c.maxWidth < 900
                      ? 2
                      : 3;
              return _Grid(
                cols: cols,
                gap: 18,
                children: [
                  for (final it in items)
                    _FeatureCard(it[0], it[1], it[2]),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 간단한 반응형 그리드 (열 수 지정)
class _Grid extends StatelessWidget {
  const _Grid(
      {required this.cols, required this.gap, required this.children});
  final int cols;
  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children)
            SizedBox(width: w, child: child),
        ],
      );
    });
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(this.icon, this.title, this.desc);
  final String icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0x1AD4FF4D),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 18),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 9),
          Text(desc,
              style: const TextStyle(
                  color: AppColors.textMid,
                  fontSize: 14.5,
                  height: 1.5)),
        ],
      ),
    );
  }
}

/// 심박수 존 계산기 (나이 슬라이더 → 220-나이)
class _Calculator extends StatefulWidget {
  const _Calculator();
  @override
  State<_Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<_Calculator> {
  double age = 30;

  static const zones = [
    ['회복', '50–60%', 0.50, 0.60, AppColors.zoneRecovery],
    ['지방 연소', '60–70%', 0.60, 0.70, AppColors.zoneFatburn],
    ['유산소', '70–85%', 0.70, 0.85, AppColors.zoneCardio],
    ['고강도', '85–100%', 0.85, 1.00, AppColors.zonePeak],
  ];

  @override
  Widget build(BuildContext context) {
    final maxHR = 220 - age.round();
    final narrow = MediaQuery.of(context).size.width < 860;

    final input = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('나이',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textMid)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${age.round()}',
                style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -3)),
            const Padding(
              padding: EdgeInsets.only(bottom: 10, left: 4),
              child: Text('세',
                  style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.borderStrong,
            thumbColor: AppColors.accent,
            overlayColor: const Color(0x22D4FF4D),
            trackHeight: 6,
          ),
          child: Slider(
            min: 14,
            max: 90,
            value: age,
            onChanged: (v) => setState(() => age = v),
          ),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14, color: AppColors.textMid),
            children: [
              const TextSpan(text: '최대 심박수 '),
              TextSpan(
                  text: '$maxHR',
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800)),
              const TextSpan(text: ' bpm  '),
              const TextSpan(
                  text: '· 220 − 나이',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );

    final zoneList = Column(
      children: [
        for (final z in zones)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ZoneCard(
              color: z[4] as Color,
              name: z[0] as String,
              pct: z[1] as String,
              lo: (maxHR * (z[2] as double)).round(),
              hi: (maxHR * (z[3] as double)).round(),
            ),
          ),
      ],
    );

    return Container(
      color: AppColors.bgSoft,
      padding: const EdgeInsets.symmetric(vertical: 92),
      child: _Wrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SecHead('Try it', '내 심박수 존, 지금 확인해보세요',
                '앱에 들어가는 핵심 계산을 그대로 옮겼습니다. 나이를 움직여보세요.'),
            const SizedBox(height: 54),
            Container(
              padding: EdgeInsets.all(narrow ? 28 : 40),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(28),
              ),
              child: narrow
                  ? Column(children: [
                      input,
                      const SizedBox(height: 34),
                      zoneList
                    ])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 85, child: input),
                        const SizedBox(width: 44),
                        Expanded(flex: 115, child: zoneList),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard(
      {required this.color,
      required this.name,
      required this.pct,
      required this.lo,
      required this.hi});
  final Color color;
  final String name;
  final String pct;
  final int lo;
  final int hi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x05FFFFFF),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 6,
              height: 42,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 3),
                Text('최대 심박수의 $pct',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.2,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.text),
              children: [
                TextSpan(text: '$lo–$hi '),
                const TextSpan(
                    text: 'bpm',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Goals extends StatelessWidget {
  const _Goals();

  @override
  Widget build(BuildContext context) {
    const goals = [
      ['🏃', '마라톤 준비', '장거리 지구력 훈련', '60–80%'],
      ['🥾', '등산', '오르막 지구력 훈련', '60–75%'],
      ['💪', '체력 향상', '심폐 능력 강화', '70–85%'],
      ['🔥', '지방 감량', '저강도 장시간 유산소', '60–70%'],
      ['🌿', '회복 운동', '가볍게 몸 풀기', '50–60%'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 92),
      child: _Wrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SecHead('Goals', '목표에 맞는 강도로 운동하세요',
                '목표를 고르면 권장 심박수 비율과 운동 시간이 자동으로 세팅됩니다.'),
            const SizedBox(height: 54),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth < 560
                  ? 2
                  : c.maxWidth < 900
                      ? 3
                      : 5;
              return _Grid(
                cols: cols,
                gap: 14,
                children: [
                  for (final g in goals)
                    _GoalCard(g[0], g[1], g[2], g[3]),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard(this.emoji, this.title, this.desc, this.range);
  final String emoji;
  final String title;
  final String desc;
  final String range;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 5),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12.5, color: AppColors.textMuted)),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x17D4FF4D),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(range,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ['나이 입력', '나이를 입력하면 220 − 나이 공식으로 최대 심박수를 계산합니다.'],
      ['목표 선택', '지방 감량·체력 향상·마라톤 등 목표를 고르면 강도와 시간이 정해집니다.'],
      ['구간 확인', '목표 심박수 구간과 권장 운동 시간을 한눈에 확인합니다.'],
      ['타이머 시작', '준비·메인·마무리 단계 타이머를 따라 운동하고 기록을 남깁니다.'],
    ];
    return Container(
      color: AppColors.bgSoft,
      padding: const EdgeInsets.symmetric(vertical: 92),
      child: _Wrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SecHead('How it works', '네 단계면 충분합니다'),
            const SizedBox(height: 54),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth < 520
                  ? 1
                  : c.maxWidth < 900
                      ? 2
                      : 4;
              return _Grid(
                cols: cols,
                gap: 20,
                children: [
                  for (var i = 0; i < steps.length; i++)
                    _StepCard(i + 1, steps[i][0], steps[i][1]),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard(this.n, this.title, this.desc);
  final int n;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('0$n',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: 1)),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(desc,
              style: const TextStyle(
                  color: AppColors.textMid, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 92),
      child: _Wrap(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 70),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1F12), Color(0xFF12150C)]),
            border: Border.all(color: AppColors.borderStrong),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Text('오늘 유산소,\n정확한 BPM으로 시작하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.6,
                      height: 1.15)),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: const Text(
                    'BPM Routine과 함께라면 운동 강도를 더 이상 감으로 정하지 않아도 됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textMid, fontSize: 16)),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _PillButton(
                      label: '앱 다운로드',
                      icon: '📱',
                      primary: true,
                      onTap: () {}),
                  _PillButton(
                      label: '먼저 체험해보기',
                      onTap: () =>
                          _NavScope.of(context).scrollTo(_Section.calc)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border))),
      child: _Wrap(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            const _Logo(size: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavLink('기능',
                    onTap: () =>
                        _NavScope.of(context).scrollTo(_Section.features)),
                _NavLink('심박수 존',
                    onTap: () =>
                        _NavScope.of(context).scrollTo(_Section.calc)),
                _NavLink('운동 목표',
                    onTap: () =>
                        _NavScope.of(context).scrollTo(_Section.goals)),
                _NavLink('사용법',
                    onTap: () =>
                        _NavScope.of(context).scrollTo(_Section.how)),
              ],
            ),
            const Text('© 2026 BPM Routine. Flutter로 제작.',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}

/// 로그인했지만 이메일 미인증인 경우 상단에 표시되는 안내바
class _VerifyBanner extends StatefulWidget {
  const _VerifyBanner();
  @override
  State<_VerifyBanner> createState() => _VerifyBannerState();
}

class _VerifyBannerState extends State<_VerifyBanner> {
  bool _busy = false;

  Future<void> _resend() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await resendVerification();
      messenger.showSnackBar(const SnackBar(
          content: Text('인증 메일을 다시 보냈어요. 메일함(스팸함도)을 확인하세요.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('잠시 후 다시 시도해 주세요.')));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _refresh() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final verified = await refreshEmailVerified();
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(
        content: Text(verified
            ? '이메일 인증이 완료됐어요! 🎉'
            : '아직 인증되지 않았어요. 메일의 링크를 눌러주세요.')));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null || user.emailVerified) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          color: const Color(0x1AD4FF4D),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _Wrap(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 14,
              runSpacing: 10,
              children: [
                const Text(
                    '✉️  이메일 인증이 필요해요. 받은 메일의 링크를 눌러 인증해 주세요.',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                _PillButton(
                    label: _busy ? '처리 중…' : '인증 메일 다시 보내기',
                    small: true,
                    onTap: _busy ? () {} : _resend),
                _PillButton(
                    label: '인증했어요 · 새로고침',
                    small: true,
                    primary: true,
                    onTap: _busy ? () {} : _refresh),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 로그인 상태일 때 네비바에 표시: 이름 + 로그아웃 + 회원 탈퇴
class _AccountMenu extends StatefulWidget {
  const _AccountMenu({required this.label});
  final String label;
  @override
  State<_AccountMenu> createState() => _AccountMenuState();
}

class _AccountMenuState extends State<_AccountMenu> {
  bool _busy = false;

  Future<void> _confirmDelete() async {
    const phrase = '회원탈퇴';
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final matched = ctrl.text.trim() == phrase;
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('회원 탈퇴',
                style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    '이 작업은 되돌릴 수 없어요.\n계정과 모든 정보가 영구 삭제됩니다.',
                    style: TextStyle(
                        color: AppColors.textMid,
                        fontSize: 14,
                        height: 1.5)),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        color: AppColors.textMid,
                        fontSize: 13.5,
                        height: 1.5),
                    children: [
                      TextSpan(text: '계속하려면 아래 칸에 '),
                      TextSpan(
                          text: phrase,
                          style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800)),
                      TextSpan(text: ' 라고 입력하세요.'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  onChanged: (_) => setLocal(() {}),
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: phrase,
                    hintStyle:
                        const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.bgSoft,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.borderStrong),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed:
                    matched ? () => Navigator.pop(ctx, true) : null,
                child: Text('탈퇴',
                    style: TextStyle(
                        color: matched
                            ? const Color(0xFFFF6B6B)
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
    ctrl.dispose();
    if (ok == true) await _runDelete(null);
  }

  Future<void> _runDelete(String? password) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await deleteAccount(password: password);
      messenger.showSnackBar(const SnackBar(
          content: Text('계정이 삭제됐어요. 그동안 이용해 주셔서 감사합니다.')));
      // authStateChanges가 로그아웃 상태로 갱신 → UI 자동 반영
    } on NeedsPasswordException {
      if (!mounted) return;
      setState(() => _busy = false);
      final pw = await _askPassword();
      if (pw != null && pw.isNotEmpty) await _runDelete(pw);
      return;
    } on FirebaseAuthException catch (e) {
      messenger
          .showSnackBar(SnackBar(content: Text(authErrorMessage(e.code))));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('탈퇴 처리 중 문제가 발생했어요. 다시 시도해 주세요.')));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<String?> _askPassword() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('비밀번호 확인',
            style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('보안을 위해 비밀번호를 다시 입력해 주세요.',
                style: TextStyle(
                    color: AppColors.textMid, fontSize: 13.5)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              autofocus: true,
              style: const TextStyle(color: AppColors.text),
              onSubmitted: (v) => Navigator.pop(ctx, v),
              decoration: InputDecoration(
                hintText: '비밀번호',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted),
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('확인',
                style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMid,
                fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        _PillButton(
            label: '로그아웃',
            small: true,
            onTap: () => signOutUser()),
        const SizedBox(width: 4),
        TextButton(
          onPressed: _busy ? null : _confirmDelete,
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text(_busy ? '처리 중…' : '회원 탈퇴',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12.5)),
        ),
      ],
    );
  }
}
