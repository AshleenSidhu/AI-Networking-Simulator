import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'home_shell.dart';

/// Backend-owned sign-in screen.
///
/// Reachable from the welcome screen ("I already have an account" tap) and
/// from any "Sign in" affordance we add later. On a successful Google
/// sign-in the auth state stream emits a non-null [AppUser], the listener
/// in [build] catches it, and we replace the route with [HomeShell] so
/// the back button doesn't bounce the user back to this screen.
///
/// The "Skip — use demo data" button is the escape hatch for stage. It
/// drops the user straight into the home shell against the mock Firestore
/// path, identical to running with `--dart-define=USE_MOCKS=true`.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _signingIn = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _signingIn = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider).signInWithGoogle();
      // The authStateProvider listener below handles the navigation
      // once FirebaseAuth emits the new user.
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _signingIn = false;
        _error = e.toString();
      });
    }
  }

  void _goToHomeAsGuest() {
    connectReplace(context, const HomeShell());
  }

  @override
  Widget build(BuildContext context) {
    // Auto-navigate to home shell once we observe a signed-in user. Using
    // ref.listen here (instead of ref.watch + post-frame callback) keeps
    // the side-effect cleanly tied to state transitions, not rebuilds.
    ref.listen(authStateProvider, (prev, next) {
      final user = next.value;
      if (user != null && mounted) {
        connectReplace(context, const HomeShell());
      }
    });

    final auth = ref.watch(authStateProvider);
    final alreadySignedIn = auth.value != null;

    return Scaffold(
      backgroundColor: ConnectColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ConnectPage(
          fullWidth: ConnectResponsive.useSideNavigation(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ConnectColors.accent,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: ConnectColors.textPrimary,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sign in to ConnectAI',
                textAlign: TextAlign.center,
                style: connectTitle(context, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Your sessions, custom personas, and feedback persist to your account.',
                textAlign: TextAlign.center,
                style: connectMuted(14),
              ),
              const SizedBox(height: 32),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ConnectColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ConnectColors.danger.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: ConnectColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (alreadySignedIn)
                ConnectPrimaryButton(
                  label: 'Continue as ${auth.value!.displayName}',
                  onPressed: () =>
                      connectReplace(context, const HomeShell()),
                )
              else
                ConnectPrimaryButton(
                  label: _signingIn ? 'Signing in…' : 'Continue with Google',
                  onPressed: _signingIn ? () {} : _signIn,
                ),
              const SizedBox(height: 12),
              ConnectPrimaryButton(
                label: 'Skip — use demo data',
                outlined: true,
                onPressed: _goToHomeAsGuest,
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'We never post to your account or contact anyone.',
                  style: connectMuted(11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
