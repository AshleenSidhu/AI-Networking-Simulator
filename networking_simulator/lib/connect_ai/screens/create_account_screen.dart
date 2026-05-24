import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/connect_widgets.dart';
import '../widgets/session_form_widgets.dart';
import 'login_screen.dart';
import 'onboarding_screens.dart';

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
