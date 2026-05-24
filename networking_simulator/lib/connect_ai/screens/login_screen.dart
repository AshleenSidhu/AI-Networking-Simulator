import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/connect_widgets.dart';
import '../widgets/session_form_widgets.dart';
import 'create_account_screen.dart';
import 'home_shell.dart';

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
