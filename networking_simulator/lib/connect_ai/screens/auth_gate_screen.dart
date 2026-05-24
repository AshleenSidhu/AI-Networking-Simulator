import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import '../widgets/session_form_widgets.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

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
