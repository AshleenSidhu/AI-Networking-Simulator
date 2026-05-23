import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../theme/connect_theme.dart';
import 'home_screen.dart';
import 'placeholder_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final useSide = ConnectResponsive.useSideNavigation(context);
    final pages = [
      HomeScreen(onGoProfile: () => goToTab(3)),
      const PlaceholderScreen(
        title: 'Practice',
        subtitle: 'Scenario selection — next screen in the flow.',
        embedded: true,
      ),
      const PlaceholderScreen(
        title: 'Schedule',
        subtitle: 'Your practice calendar — next screen in the flow.',
        embedded: true,
      ),
      const ProfileScreen(embedded: true),
    ];

    final body = IndexedStack(index: _index, children: pages);

    if (!useSide) {
      return Scaffold(
        backgroundColor: ConnectColors.background,
        body: body,
        bottomNavigationBar: _BottomNav(index: _index, onTap: goToTab),
      );
    }

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: Row(
        children: [
          _SideRail(index: _index, onTap: goToTab),
          const VerticalDivider(width: 1, color: ConnectColors.border),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});
  final int index;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ConnectColors.background,
        border: Border(top: BorderSide(color: ConnectColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Nav(0, Icons.home_rounded, 'Home', index, onTap),
              _Nav(1, Icons.track_changes_rounded, 'Practice', index, onTap),
              _Nav(2, Icons.calendar_month_rounded, 'Schedule', index, onTap),
              _Nav(3, Icons.person_rounded, 'Profile', index, onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.index, required this.onTap});
  final int index;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      color: ConnectColors.card,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ConnectColors.accent,
              ),
              child: const Icon(Icons.mic_rounded, color: ConnectColors.textPrimary, size: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              'ConnectAI',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            _RailItem(0, Icons.home_rounded, 'Home', index, onTap),
            _RailItem(1, Icons.track_changes_rounded, 'Practice', index, onTap),
            _RailItem(2, Icons.calendar_month_rounded, 'Schedule', index, onTap),
            _RailItem(3, Icons.person_rounded, 'Profile', index, onTap),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem(this.i, this.icon, this.label, this.current, this.onTap);
  final int i;
  final IconData icon;
  final String label;
  final int current;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final active = current == i;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: active ? ConnectColors.accent.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onTap(i),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(icon, color: active ? ConnectColors.accent : ConnectColors.textMuted),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: active ? ConnectColors.accent : ConnectColors.textMuted,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav(this.i, this.icon, this.label, this.current, this.onTap);
  final int i;
  final IconData icon;
  final String label;
  final int current;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final active = current == i;
    final color = active ? ConnectColors.accent : ConnectColors.textMuted;
    return GestureDetector(
      onTap: () => onTap(i),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
