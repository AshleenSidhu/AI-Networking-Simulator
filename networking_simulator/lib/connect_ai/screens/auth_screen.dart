import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../state/connect_app_state.dart';
import '../theme/connect_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/connect_widgets.dart';
import '../widgets/session_form_widgets.dart';
import 'home_screen.dart';

// --- welcome_screen.dart ---
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
          onTap: () => connectPush(context, const AuthGateScreen()),
          child: Text(
            'I already have an account',
            style: connectMuted(14).copyWith(
              decoration: TextDecoration.underline,
              decorationColor: ConnectColors.textMuted,
            ),
          ),
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
                    onTap: () => connectPush(context, const AuthGateScreen()),
                    child: Text(
                      'I already have an account',
                      style: connectMuted(14).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: ConnectColors.textMuted,
                      ),
                    ),
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
          child: const Icon(Icons.mic_rounded, color: ConnectColors.textPrimary, size: 30),
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

// --- auth_gate_screen.dart ---
/// Entry point after "I already have an account" — choose login or sign up.
class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ConnectBackButton(),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ConnectColors.accent,
                  ),
                  child: const Icon(Icons.mic_rounded, color: ConnectColors.textPrimary),
                ),
              ),
              const SizedBox(height: 24),
              Text('Welcome back', style: connectTitle(context, size: 28)),
              const SizedBox(height: 8),
              Text(
                'Log in to continue your practice, or create a new account.',
                style: connectMuted(15),
              ),
              const Spacer(),
              ConnectPrimaryButton(
                label: 'Log In',
                onPressed: () => connectPush(context, const LoginScreen()),
              ),
              const SizedBox(height: 12),
              ConnectPrimaryButton(
                label: 'Create Account',
                outlined: true,
                onPressed: () => connectPush(context, const CreateAccountScreen()),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// --- login_screen.dart ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'alex@example.com');
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goHome() {
    connectReplace(context, const HomeShell());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const ConnectBackButton(),
                  Expanded(
                    child: Text(
                      'Log In',
                      textAlign: TextAlign.center,
                      style: connectTitle(context, size: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 32),
                  children: [
                    Text('Welcome back 👋', style: connectTitle(context, size: 26)),
                    const SizedBox(height: 8),
                    Text('Sign in to pick up where you left off.', style: connectMuted()),
                    const SizedBox(height: 28),
                    GoogleSignInButton(
                      onPressed: () => showAuthComingSoon(context),
                    ),
                    const SizedBox(height: 24),
                    const AuthDivider(),
                    const SizedBox(height: 24),
                    AuthTextField(
                      label: 'Email',
                      hint: 'you@company.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Password',
                      hint: '••••••••',
                      obscureText: _obscure,
                      controller: _password,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: ConnectColors.accent, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthLinkRow(
                      prompt: "Don't have an account?",
                      action: 'Create one',
                      onTap: () => connectReplace(context, const CreateAccountScreen()),
                    ),
                  ],
                ),
              ),
              ConnectPrimaryButton(label: 'Log In', onPressed: _goHome),
              SizedBox(height: ConnectResponsive.isMobile(context) ? 8 : 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- create_account_screen.dart ---
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _terms = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const ConnectBackButton(),
                  Expanded(
                    child: Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: connectTitle(context, size: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 32),
                  children: [
                    Text('Join ConnectAI', style: connectTitle(context, size: 26)),
                    const SizedBox(height: 8),
                    Text(
                      'Create an account to save progress and personalize practice.',
                      style: connectMuted(),
                    ),
                    const SizedBox(height: 28),
                    GoogleSignInButton(
                      onPressed: () => showAuthComingSoon(context),
                    ),
                    const SizedBox(height: 24),
                    const AuthDivider(label: 'or sign up with email'),
                    const SizedBox(height: 24),
                    AuthTextField(
                      label: 'Full name',
                      hint: 'Alex Johnson',
                      controller: _name,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Email',
                      hint: 'you@company.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Password',
                      hint: 'At least 8 characters',
                      obscureText: _obscure,
                      controller: _password,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _terms,
                            onChanged: (v) => setState(() => _terms = v ?? false),
                            activeColor: ConnectColors.accent,
                            side: const BorderSide(color: ConnectColors.border),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: connectMuted(13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AuthLinkRow(
                      prompt: 'Already have an account?',
                      action: 'Log in',
                      onTap: () => connectReplace(context, const LoginScreen()),
                    ),
                  ],
                ),
              ),
              ConnectPrimaryButton(
                label: 'Create Account',
                onPressed: () => connectPush(context, const OnboardingQ1Screen()),
              ),
              SizedBox(height: ConnectResponsive.isMobile(context) ? 8 : 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- onboarding_screens.dart ---
class OnboardingQ1Screen extends StatefulWidget {
  const OnboardingQ1Screen({super.key});

  @override
  State<OnboardingQ1Screen> createState() => _OnboardingQ1ScreenState();
}

class _OnboardingQ1ScreenState extends State<OnboardingQ1Screen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_name.text.isEmpty) {
      _name.text = ConnectScope.of(context).onboardingName;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: 1,
      emoji: '👋',
      headline: "What's your name?",
      subtitle: "Let's make this personal",
      body: TextField(
        controller: _name,
        autofocus: true,
        style: const TextStyle(color: ConnectColors.textPrimary, fontSize: 18),
        decoration: InputDecoration(
          hintText: 'Your first name',
          hintStyle: connectMuted(16),
          filled: true,
          fillColor: ConnectColors.card,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ConnectColors.radius),
            borderSide: const BorderSide(color: ConnectColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ConnectColors.radius),
            borderSide: const BorderSide(color: ConnectColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
      onContinue: () {
        ConnectScope.of(context).setOnboardingName(_name.text);
        connectPush(context, const OnboardingQ2Screen());
      },
    );
  }
}

class OnboardingQ2Screen extends StatefulWidget {
  const OnboardingQ2Screen({super.key});

  @override
  State<OnboardingQ2Screen> createState() => _OnboardingQ2ScreenState();
}

class _OnboardingQ2ScreenState extends State<OnboardingQ2Screen> {
  static const _options = [
    ('🎓', 'Student', 'University or college student'),
    ('💼', 'Early Professional', '0-3 years work experience'),
    ('🚀', 'Mid-Level Professional', '3-8 years work experience'),
    ('👑', 'Senior Professional', '8+ years experience'),
  ];

  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final role = ConnectScope.of(context).onboardingRole;
    final idx = _options.indexWhere((o) => o.$2 == role);
    if (idx >= 0) _selected = idx;
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: 2,
      emoji: '🎓',
      headline: 'What describes you best?',
      subtitle: "We'll personalize your experience",
      body: ConnectResponsive.isDesktop(context)
          ? GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: List.generate(_options.length, (i) {
                final (emoji, title, sub) = _options[i];
                return SelectableOptionCard(
                  emoji: emoji,
                  title: title,
                  subtitle: sub,
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                );
              }),
            )
          : Column(
              children: List.generate(_options.length, (i) {
                final (emoji, title, sub) = _options[i];
                return SelectableOptionCard(
                  emoji: emoji,
                  title: title,
                  subtitle: sub,
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                );
              }),
            ),
      onContinue: () {
        ConnectScope.of(context).setOnboardingRole(_options[_selected].$2);
        connectPush(context, const OnboardingQ3Screen());
      },
    );
  }
}

class OnboardingQ3Screen extends StatefulWidget {
  const OnboardingQ3Screen({super.key});

  @override
  State<OnboardingQ3Screen> createState() => _OnboardingQ3ScreenState();
}

class _OnboardingQ3ScreenState extends State<OnboardingQ3Screen> {
  static const _industries = [
    'Technology',
    'Finance',
    'Healthcare',
    'Marketing',
    'Entrepreneurship',
    'Law',
    'Education',
    'Engineering',
    'Design',
    'Sales',
    'Product',
    'Other',
  ];

  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {'Technology'};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selected.length == 1 && _selected.contains('Technology')) {
      _selected = Set<String>.from(ConnectScope.of(context).onboardingIndustries);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: 3,
      emoji: '🏢',
      headline: "What's your industry?",
      subtitle: 'Your personas will match your field',
      body: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _industries.map((ind) {
          return ConnectChip(
            label: ind,
            selected: _selected.contains(ind),
            onTap: () {
              setState(() {
                if (_selected.contains(ind)) {
                  _selected.remove(ind);
                } else {
                  _selected.add(ind);
                }
              });
            },
          );
        }).toList(),
      ),
      onContinue: () {
        ConnectScope.of(context).setOnboardingIndustries(_selected);
        connectPush(context, const OnboardingQ4Screen());
      },
    );
  }
}

class OnboardingQ4Screen extends StatefulWidget {
  const OnboardingQ4Screen({super.key});

  @override
  State<OnboardingQ4Screen> createState() => _OnboardingQ4ScreenState();
}

class _OnboardingQ4ScreenState extends State<OnboardingQ4Screen> {
  static const _goals = [
    ('🎯', 'Land a Job', 'Practice recruiter and hiring manager calls'),
    ('💰', 'Investor Pitch', 'Practice pitching to VCs and angels'),
    ('🤝', 'General Networking', 'Build connections in your industry'),
    ('💼', 'Client or Sales Calls', 'Win clients and close deals'),
  ];

  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final goal = ConnectScope.of(context).onboardingGoal;
    final idx = _goals.indexWhere((g) => g.$2 == goal);
    if (idx >= 0) _selected = idx;
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: 4,
      emoji: '🎯',
      headline: "What's your main goal?",
      subtitle: "We'll build your perfect practice plan",
      body: Column(
        children: List.generate(_goals.length, (i) {
          final (emoji, title, sub) = _goals[i];
          return SelectableOptionCard(
            emoji: emoji,
            title: title,
            subtitle: sub,
            selected: _selected == i,
            onTap: () => setState(() => _selected = i),
          );
        }),
      ),
      continueLabel: 'Build My Profile ✦',
      shimmerButton: true,
      largeButton: true,
      onContinue: () {
        final app = ConnectScope.of(context);
        app.setOnboardingGoal(_goals[_selected].$2);
        app.commitOnboardingProfile();
        connectPush(context, const ProfileLoadingScreen());
      },
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({
    required this.step,
    required this.emoji,
    required this.headline,
    required this.subtitle,
    required this.body,
    required this.onContinue,
    this.continueLabel = 'Continue →',
    this.shimmerButton = false,
    this.largeButton = false,
  });

  final int step;
  final String emoji;
  final String headline;
  final String subtitle;
  final Widget body;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool shimmerButton;
  final bool largeButton;

  @override
  Widget build(BuildContext context) {
    final pad = ConnectResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingHeader(step: step),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(0, 32, 0, 16),
                  children: [
                    if (ConnectResponsive.isDesktop(context))
                      ConnectSplitLayout(
                        primary: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 56)),
                            const SizedBox(height: 20),
                            Text(headline, style: connectTitle(context, size: 32)),
                            const SizedBox(height: 8),
                            Text(subtitle, style: connectMuted(16)),
                          ],
                        ),
                        secondary: body,
                        primaryFlex: 2,
                        secondaryFlex: 3,
                      )
                    else ...[
                      Text(emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 20),
                      Text(headline, style: connectTitle(context, size: 26)),
                      const SizedBox(height: 8),
                      Text(subtitle, style: connectMuted()),
                      const SizedBox(height: 28),
                      body,
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: pad.bottom),
                child: ConnectPrimaryButton(
                  label: continueLabel,
                  large: largeButton,
                  shimmer: shimmerButton,
                  onPressed: onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- profile_loading_screen.dart ---
class ProfileLoadingScreen extends StatefulWidget {
  const ProfileLoadingScreen({super.key});

  @override
  State<ProfileLoadingScreen> createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen>
    with TickerProviderStateMixin {
  static const _items = [
    'Analyzing your background',
    'Identifying your strengths',
    'Finding your blind spots',
    'Matching you with personas',
  ];

  int _completed = 0;
  late final AnimationController _spin;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (var i = 0; i < _items.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _completed = i + 1);
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    connectReplace(context, const HomeShell());
  }

  @override
  void dispose() {
    _spin.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: ConnectPage(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _glow,
              builder: (_, __) {
                return Container(
                  width: 260 + _glow.value * 40 + _completed * 12,
                  height: 260 + _glow.value * 40 + _completed * 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ConnectColors.accent.withValues(alpha: 0.15 + _completed * 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: AnimatedBuilder(
                        animation: _spin,
                        builder: (_, __) {
                          return CustomPaint(
                            painter: _ArcPainter(_spin.value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Building your profile...', style: connectTitle(context, size: 22)),
                    const SizedBox(height: 8),
                    Text('This only takes a moment', style: connectMuted()),
                    const SizedBox(height: 40),
                    ...List.generate(_items.length, (i) {
                      final done = i < _completed;
                      return TweenAnimationBuilder<double>(
                        key: ValueKey('item_$i'),
                        tween: Tween(begin: 0, end: done ? 1 : 0),
                        duration: const Duration(milliseconds: 250),
                        builder: (_, value, child) {
                          return Opacity(
                            opacity: value.clamp(0.3, 1),
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 12),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Icon(
                                done ? Icons.check_circle : Icons.circle_outlined,
                                color: done ? ConnectColors.accent : ConnectColors.textMuted,
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                _items[i],
                                style: TextStyle(
                                  color: done ? ConnectColors.textPrimary : ConnectColors.textMuted,
                                  fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bg = Paint()
      ..color = ConnectColors.cardElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final fg = Paint()
      ..color = ConnectColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(4), 0, 6.28, false, bg);
    canvas.drawArc(rect.deflate(4), -1.57 + progress * 6.28, 2.2, false, fg);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.progress != progress;
}

