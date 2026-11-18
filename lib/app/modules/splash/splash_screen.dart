import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../all_service/views/AllServiceScreen.dart' show serviceBackdrop;

/// Launch screen on the brand green: the rose-gold "P" rises in and a light
/// sweeps across it, "PEAK PRIVEE" appears letter by letter, the tagline
/// spreads out, and a thin line fills while the session loads. The native
/// launch background uses the same green, so there's no flash before it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.navigate = true});

  /// Off in tests: only the animation runs.
  final bool navigate;

  /// The brand green. Also set in android `launch_background.xml` and the
  /// iOS LaunchScreen.
  static const background = Color(0xFF08523C);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _logo = 'assets/images/app_logo2.png';

  static const _name = 'PEAK PRIVEE';
  static const _tagline = 'ABOVE AND BEYOND LUXURY';

  // Light rose gold (from the logo), readable on the green.
  static const _rose = Color(0xFFE6BE9C);
  static const _cream = Color(0xFFF7EFE6);

  /// The entrance, once.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  /// The light behind the logo breathes while waiting.
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  Animation<double> _interval(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: curve));

  late final _logoIn = _interval(0.0, 0.4);
  late final _shine = _interval(0.3, 0.7, Curves.easeInOut);
  late final _nameIn = _interval(0.28, 0.7, Curves.linear);
  late final _taglineIn = _interval(0.6, 0.92);
  late final _line = _interval(0.25, 1.0, Curves.easeInOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.navigate) _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_logo), context);
    // The service picker's photo: decoded now so that screen opens on it
    // instead of a blank frame.
    precacheImage(const AssetImage(serviceBackdrop), context);
  }

  @override
  void dispose() {
    _intro.dispose();
    _glow.dispose();
    super.dispose();
  }

  /// Loads the session while the animation plays; leaves once both are done.
  Future<void> _start() async {
    final auth = Get.find<AuthController>();
    final minTime = Future<void>.delayed(const Duration(milliseconds: 2500));

    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (seen) await auth.loadUserData();
    await minTime;
    if (!mounted) return;

    if (!seen) {
      Get.offAllNamed(Routes.onBoarding);
    } else if (!auth.isLoggedIn) {
      Get.offAllNamed(Routes.role);
    } else if (auth.role == 'Provider') {
      Get.offAllNamed(Routes.providerNavScreen);
    } else {
      Get.offAllNamed(Routes.service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final logoWidth = math.min(width * 0.78, 360.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF053D2C),
      ),
      child: Scaffold(
        backgroundColor: SplashScreen.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // The brand green, a touch deeper towards the bottom.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A5C44), SplashScreen.background, Color(0xFF053D2C)],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            // Soft warm light behind the logo.
            AnimatedBuilder(
              animation: Listenable.merge([_glow, _logoIn]),
              builder: (_, __) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.12),
                    radius: 0.62 + 0.06 * _glow.value,
                    colors: [
                      _rose.withValues(alpha: (0.16 + 0.06 * _glow.value) * _logoIn.value),
                      _rose.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The "P": rises, fades and settles from a slight zoom,
                  // then a light sweeps across it.
                  AnimatedBuilder(
                    animation: _logoIn,
                    builder: (_, child) => Opacity(
                      opacity: _logoIn.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _logoIn.value)),
                        child: Transform.scale(scale: 0.9 + 0.1 * _logoIn.value, child: child),
                      ),
                    ),
                    child: _Shine(progress: _shine, child: _logoMark(logoWidth)),
                  ),
                  const SizedBox(height: 18),
                  // "PEAK PRIVEE", letter by letter.
                  _LetterReveal(
                    text: _name,
                    progress: _nameIn,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 7,
                      color: _cream,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Thin divider that opens from the centre, then the
                  // tagline fades in while its letters spread apart.
                  AnimatedBuilder(
                    animation: _taglineIn,
                    builder: (_, __) => Column(
                      children: [
                        Container(
                          width: 64 * _taglineIn.value,
                          height: 1,
                          color: _rose.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: _taglineIn.value,
                          child: Text(
                            _tagline,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5 + 2.5 * _taglineIn.value,
                              color: _rose,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Thin line that fills while the session loads.
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.paddingOf(context).bottom + 56,
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 2,
                  child: AnimatedBuilder(
                    animation: _intro,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Stack(
                        children: [
                          Container(color: Colors.white.withValues(alpha: 0.12 * _logoIn.value)),
                          FractionallySizedBox(
                            widthFactor: _line.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [_rose.withValues(alpha: 0.3), _rose]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The "P" from the logo PNG (its top part; the tagline in the image is
  /// replaced by the animated text).
  Widget _logoMark(double width) {
    const aspect = 665 / 375;
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.76,
        child: Image.asset(
          _logo,
          width: width,
          height: width / aspect,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'Peak Privee',
        ),
      ),
    );
  }
}

/// Shows [text] one letter at a time as [progress] goes 0 → 1; each letter
/// fades in while rising into place.
class _LetterReveal extends StatelessWidget {
  const _LetterReveal({required this.text, required this.progress, required this.style});

  final String text;
  final Animation<double> progress;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final letters = text.characters.toList();
    // Each letter takes `span` of the progress; starts are spread evenly.
    const span = 0.35;
    final step = letters.length > 1 ? (1 - span) / (letters.length - 1) : 0.0;
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: progress,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < letters.length; i++)
              Builder(builder: (_) {
                final t = Curves.easeOutCubic.transform(((progress.value - i * step) / span).clamp(0.0, 1.0));
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - t)),
                    child: Text(letters[i], style: style),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// A diagonal band of light that crosses [child] once as [progress] goes
/// 0 → 1, only where the child is drawn.
class _Shine extends StatelessWidget {
  const _Shine({required this.progress, required this.child});

  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (_, child) {
        final t = progress.value;
        if (t <= 0 || t >= 1) return child!;
        final x = -1.6 + 3.2 * t; // band centre, left of the logo → right
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(x - 0.5, -0.4),
            end: Alignment(x + 0.5, 0.4),
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.55),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0.3, 0.5, 0.7],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}
