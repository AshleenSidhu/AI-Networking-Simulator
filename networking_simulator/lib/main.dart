import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connect_ai/layout/responsive.dart';
import 'connect_ai/screens/welcome_screen.dart';
import 'connect_ai/state/connect_app_state.dart';
import 'connect_ai/theme/connect_theme.dart';
import 'firebase_options.dart';
import 'state/connect_state_provider.dart';

final _connectState = ConnectAppState();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Loads GEMINI_API_KEY from .env (bundled as an asset). Missing values
  // surface as null in dotenv.env — downstream services degrade to mocks.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[bootstrap] .env load failed: $e');
  }

  // Optional Firebase init. Throws until `flutterfire configure` has been
  // run — that's expected before HUMAN_TODO step 5 is complete. Auth and
  // Firestore providers detect `Firebase.apps.isEmpty` and fall back to
  // mocks so the rest of the app keeps working.
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

class ConnectAIApp extends StatelessWidget {
  const ConnectAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectAI',
      debugShowCheckedModeBanner: false,
      theme: buildConnectTheme(),
      scrollBehavior: const ConnectScrollBehavior(),
      home: const WelcomeScreen(),
    );
  }
}
