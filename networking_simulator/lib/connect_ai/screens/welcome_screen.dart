import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'auth_screen.dart' show OnboardingQ1Screen;
import 'sign_in_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ConnectResponsive.isDesktop(context) ||
        ConnectResponsive.isTablet(context);

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: Stack(
        children: [
          _GlowBackground(pulse: _pulse),
          ...List.generate(8, (i) => _Particle(index: i, pulse: _pulse)),
          SafeArea(
            child: ConnectPage(
              fullWidth: isWide,
              child: isWide ? _WideLayout(pulse: _pulse) : _MobileLayout(pulse: _pulse),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        _LogoBlock(),
        const Spacer(flex: 3),
        ConnectPrimaryButton(
          label: 'Get Started',
          onPressed: () => connectPush(context, const OnboardingQ1Screen()),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => connectPush(context, const SignInScreen()),
          child: Text('I already have an account', style: connectMuted(14)),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height -
          MediaQuery.paddingOf(context).vertical,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LogoBlock(alignStart: true),
                const SizedBox(height: 32),
                Text(
                  'Practice real conversations with AI personas tailored to your career goals.',
                  style: connectMuted(16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ConnectColors.card,
                borderRadius: BorderRadius.circular(ConnectColors.radius),
                border: Border.all(color: ConnectColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConnectPrimaryButton(
                    label: 'Get Started',
                    onPressed: () => connectPush(context, const OnboardingQ1Screen()),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => connectPush(context, const SignInScreen()),
                    child: Text('I already have an account', style: connectMuted(14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock({this.alignStart = false});
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: ConnectColors.accent,
          ),
          child: Icon(Icons.mic_rounded, color: ConnectColors.textPrimary, size: 30),
        ),
        const SizedBox(height: 24),
        Text(
          'ConnectAI',
          style: connectTitle(context, size: alignStart ? 40 : 32),
          textAlign: alignStart ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your AI networking coach',
          style: connectMuted(16),
          textAlign: alignStart ? TextAlign.start : TextAlign.center,
        ),
      ],
    );
  }
}

class _GlowBackground extends StatelessWidget {
  const _GlowBackground({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        final scale = 1 + pulse.value * 0.12;
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ConnectColors.accent.withValues(alpha: 0.35),
                    ConnectColors.accent.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Particle extends StatelessWidget {
  const _Particle({required this.index, required this.pulse});
  final int index;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final angle = index * math.pi / 4;
    final radius = 120 + pulse.value * 20;
    return Positioned(
      left: size.width / 2 + math.cos(angle) * radius - 4,
      top: size.height * 0.35 + math.sin(angle) * radius - 4,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ConnectColors.accent.withValues(alpha: 0.25 + pulse.value * 0.2),
        ),
      ),
    );
  }
}
