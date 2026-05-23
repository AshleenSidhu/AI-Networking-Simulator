import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:networking_simulator/connect_ai/screens/welcome_screen.dart';
import 'package:networking_simulator/connect_ai/state/connect_app_state.dart';
import 'package:networking_simulator/connect_ai/theme/connect_theme.dart';

void main() {
  testWidgets('Welcome screen shows ConnectAI branding', (tester) async {
    await tester.pumpWidget(
      ConnectScope(
        appState: ConnectAppState(),
        child: MaterialApp(
          theme: buildConnectTheme(),
          home: const WelcomeScreen(),
        ),
      ),
    );

    expect(find.text('ConnectAI'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
