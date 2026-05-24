import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connect_ai/layout/responsive.dart';
import 'connect_ai/screens/auth_screen.dart';
import 'connect_ai/state/connect_app_state.dart';
import 'connect_ai/theme/connect_theme.dart';
import 'firebase_options.dart';
import 'state/connect_state_provider.dart';
import 'state/connect_state_sync.dart';
import 'state/score_backfill.dart';

final _connectState = ConnectAppState();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[bootstrap] .env load failed: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[bootstrap] Firebase initialized.');
  } catch (e) {
    debugPrint('[bootstrap] Firebase init skipped: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        connectAppStateProvider.overrideWithValue(_connectState),
      ],
      child: ConnectScope(
        appState: _connectState,
        child: const ConnectAIApp(),
      ),
    ),
  );
}

class ConnectAIApp extends ConsumerWidget {
  const ConnectAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(connectStateSyncProvider);
    ref.watch(scoreBackfillProvider);

    return ListenableBuilder(
      listenable: _connectState,
      builder: (context, _) {
        applyConnectThemeMode(dark: _connectState.isDarkMode);
        return MaterialApp(
          title: 'ConnectAI',
          debugShowCheckedModeBanner: false,
          theme: buildConnectTheme(),
          darkTheme: buildConnectDarkTheme(),
          themeMode: _connectState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          scrollBehavior: const ConnectScrollBehavior(),
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
