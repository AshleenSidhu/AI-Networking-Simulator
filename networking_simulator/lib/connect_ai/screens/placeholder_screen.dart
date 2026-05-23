import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../theme/connect_theme.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.embedded = false,
  });

  final String title;
  final String? subtitle;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = ConnectPage(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction_rounded, size: 48, color: ConnectColors.accent),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: connectTitle(context)),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(subtitle!, textAlign: TextAlign.center, style: connectMuted()),
              ],
            ],
          ),
        ),
      ),
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: ConnectColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: content,
    );
  }
}
