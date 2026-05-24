import 'package:flutter/material.dart';

import 'connect_ai/layout/responsive.dart';
import 'connect_ai/screens/auth_screen.dart';
import 'connect_ai/state/connect_app_state.dart';
import 'connect_ai/theme/connect_theme.dart';

final _connectState = ConnectAppState();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ConnectScope(
      appState: _connectState,
      child: const ConnectAIApp(),
    ),
  );
}

class ConnectAIApp extends StatelessWidget {
  const ConnectAIApp({super.key});

  @override
  Widget build(BuildContext context) {
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
