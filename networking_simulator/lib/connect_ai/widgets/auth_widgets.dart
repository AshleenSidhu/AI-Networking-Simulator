import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/connect_theme.dart';

/// Google sign-in button UI — wire to Google Auth later.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: ConnectColors.textPrimary,
          backgroundColor: ConnectColors.card,
          side: const BorderSide(color: ConnectColors.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ConnectColors.radius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleLogo(),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);

  void arc(Color color, double start, double sweep) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * 0.72),
        start,
        sweep,
        false,
        paint,
      );
    }

    arc(const Color(0xFF4285F4), -0.4, 1.6);
    arc(const Color(0xFF34A853), 1.2, 1.2);
    arc(const Color(0xFFFBBC05), 2.4, 1.1);
    arc(const Color(0xFFEA4335), 3.5, 1.3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with email'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: ConnectColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: connectMuted(12)),
        ),
        const Expanded(child: Divider(color: ConnectColors.border)),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
  });

  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: connectMuted(13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: ConnectColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: connectMuted(14),
            filled: true,
            fillColor: ConnectColors.card,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ConnectColors.radius),
              borderSide: const BorderSide(color: ConnectColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ConnectColors.radius),
              borderSide: const BorderSide(color: ConnectColors.accent, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: connectMuted(14)),
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              action,
              style: const TextStyle(
                color: ConnectColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder snackbar for future Google Auth.
void showAuthComingSoon(BuildContext context, {String provider = 'Google'}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$provider sign-in coming soon'),
      backgroundColor: ConnectColors.cardElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
