import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/connect_theme.dart';

enum ConnectBreakpoint { mobile, tablet, desktop }

class ConnectResponsive {
  static ConnectBreakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return ConnectBreakpoint.desktop;
    if (width >= 600) return ConnectBreakpoint.tablet;
    return ConnectBreakpoint.mobile;
  }

  static bool isMobile(BuildContext context) => of(context) == ConnectBreakpoint.mobile;
  static bool isTablet(BuildContext context) => of(context) == ConnectBreakpoint.tablet;
  static bool isDesktop(BuildContext context) => of(context) == ConnectBreakpoint.desktop;

  static double contentMaxWidth(BuildContext context) {
    switch (of(context)) {
      case ConnectBreakpoint.desktop:
        return 1100;
      case ConnectBreakpoint.tablet:
        return 720;
      case ConnectBreakpoint.mobile:
        return 480;
    }
  }

  static EdgeInsets pagePadding(BuildContext context) {
    switch (of(context)) {
      case ConnectBreakpoint.desktop:
        return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
      case ConnectBreakpoint.tablet:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
      case ConnectBreakpoint.mobile:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  static bool useSideNavigation(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 800;
}

/// Centers content with responsive max-width; full-bleed on desktop shell.
class ConnectPage extends StatelessWidget {
  const ConnectPage({
    super.key,
    required this.child,
    this.fullWidth = false,
    this.padding,
  });

  final Widget child;
  final bool fullWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? ConnectResponsive.pagePadding(context);
    final maxW = fullWidth ? double.infinity : ConnectResponsive.contentMaxWidth(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(padding: pad, child: child),
      ),
    );
  }
}

/// Two-column layout on tablet/desktop.
class ConnectSplitLayout extends StatelessWidget {
  const ConnectSplitLayout({
    super.key,
    required this.primary,
    required this.secondary,
    this.secondaryFlex = 2,
    this.primaryFlex = 3,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;

  @override
  Widget build(BuildContext context) {
    if (ConnectResponsive.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [primary, const SizedBox(height: 24), secondary],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: primaryFlex, child: primary),
        const SizedBox(width: 32),
        Expanded(flex: secondaryFlex, child: secondary),
      ],
    );
  }
}

class ConnectScrollBehavior extends MaterialScrollBehavior {
  const ConnectScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
