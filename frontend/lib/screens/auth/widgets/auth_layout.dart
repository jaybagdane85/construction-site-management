import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footer,
    this.showBackButton = false,
    this.bottomContent,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget footer;
  final bool showBackButton;
  final Widget? bottomContent;

  static const purple = Color(0xFF6D3FEF);
  static const bluePurple = Color(0xFF4D44E8);
  static const ink = Color(0xFF091126);
  static const muted = Color(0xFF56617D);
  static const fieldBorder = Color(0xFFE1D9F4);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 760;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7FF),
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  isWide ? 48 : 18,
                  showBackButton ? 16 : 28,
                  isWide ? 48 : 18,
                  18,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 460 : 350),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showBackButton) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.08),
                            child: IconButton(
                              onPressed: Navigator.of(context).maybePop,
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const SiteManagerBrand(compact: true),
                      const SizedBox(height: 28),
                      Text(
                        title,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          height: 1.04,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.28,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _AuthCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...children,
                            const SizedBox(height: 18),
                            footer,
                          ],
                        ),
                      ),
                      if (bottomContent != null) ...[
                        const SizedBox(height: 18),
                        bottomContent!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
    this.prefix,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      style: const TextStyle(
        color: AuthLayout.ink,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: AuthLayout.purple,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        prefix: prefix,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFCFAFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: AuthLayout.muted,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: AuthLayout.ink,
        suffixIconColor: AuthLayout.ink,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AuthLayout.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AuthLayout.purple, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AuthLayout.fieldBorder),
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B45F4), Color(0xFF5237E6)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AuthLayout.purple.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(icon, size: 24),
                ],
              ),
      ),
    );
  }
}

class SiteManagerBrand extends StatelessWidget {
  const SiteManagerBrand({super.key, this.compact = false, this.light = false});

  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : AuthLayout.ink;
    final subtitleColor = light
        ? Colors.white.withValues(alpha: 0.82)
        : AuthLayout.muted;

    return Row(
      mainAxisAlignment: compact
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        const _SiteLogo(size: 50),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: compact
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: textColor,
                  fontSize: compact ? 25 : 34,
                  fontWeight: FontWeight.w900,
                ),
                children: const [
                  TextSpan(text: 'Site'),
                  TextSpan(
                    text: 'Manager',
                    style: TextStyle(color: AuthLayout.purple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Build  •  Manage  •  Grow',
              style: TextStyle(
                color: subtitleColor,
                fontSize: compact ? 12 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AuthFeatureItem extends StatelessWidget {
  const AuthFeatureItem({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AuthLayout.ink, size: 23),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AuthLayout.ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D3FEF).withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SiteLogo extends StatelessWidget {
  const _SiteLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SiteLogoPainter()),
    );
  }
}

class _SiteLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 58;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = AuthLayout.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final house = Path()
      ..moveTo(8, 28)
      ..lineTo(29, 10)
      ..lineTo(50, 28)
      ..moveTo(15, 25)
      ..lineTo(15, 50)
      ..lineTo(43, 50)
      ..lineTo(43, 25)
      ..moveTo(25, 50)
      ..lineTo(25, 36)
      ..lineTo(34, 36)
      ..lineTo(34, 50);
    canvas.drawPath(house, paint);

    final helmet = Paint()
      ..color = AuthLayout.purple
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      const Rect.fromLTWH(28, 2, 21, 18),
      3.14,
      3.14,
      true,
      helmet,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(26, 16, 27, 6),
        const Radius.circular(2),
      ),
      helmet,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.1,
          colors: [Color(0xFFFFFFFF), Color(0xFFF7F0FF), Color(0xFFE8DDFC)],
        ),
      ),
      child: CustomPaint(painter: _AuthBackgroundPainter()),
    );
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  const _AuthBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.52)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.18),
      size.width * 0.72,
      arcPaint,
    );

    final skyline = Paint()
      ..color = const Color(0xFF7B65D8).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = const Color(0xFF7B65D8).withValues(alpha: 0.24)
      ..strokeWidth = 2;

    final bottom = size.height;
    for (var i = 0; i < 8; i++) {
      final w = size.width / 10;
      final h = (i.isEven ? 70 : 105).toDouble();
      final x = i * w * 1.25;
      canvas.drawRect(Rect.fromLTWH(x, bottom - h, w, h), skyline);
    }

    final craneX = size.width * 0.78;
    final craneY = size.height * 0.2;
    canvas.drawLine(Offset(craneX, craneY), Offset(craneX, bottom - 60), line);
    canvas.drawLine(
      Offset(craneX - 80, craneY + 20),
      Offset(craneX + 120, craneY - 28),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
