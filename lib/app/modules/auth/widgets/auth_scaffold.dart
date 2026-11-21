import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text-style.dart';
import '../../splash/splash_screen.dart';

/// Shared layout of the auth screens (login, signup, forgot password, code,
/// new password): the splash's green header with the logo, title and
/// subtitle, then a white rounded sheet holding the form. The header and
/// each form row slide in one after another.
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBack = true,
    this.footer,
  });

  final String title;
  final String subtitle;

  /// Form rows, animated in one after another.
  final List<Widget> children;

  /// Under the sheet's content (e.g. "New here? Create an account").
  final Widget? footer;
  final bool showBack;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold> with SingleTickerProviderStateMixin {
  static const _logo = 'assets/images/app_logo2.png';
  static const _headerTop = Color(0xFF0A5C44);

  /// As soon as the page scrolls, a pinned green app bar (back button and
  /// logo) takes over from the header's own logo row. It sits exactly where
  /// that row was, so the logo and back button look like they stay put while
  /// the title and form scroll under them.
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<bool> _pinned = ValueNotifier(false);

  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncBar);
  }

  @override
  void dispose() {
    _scroll.removeListener(_syncBar);
    _scroll.dispose();
    _pinned.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _syncBar() {
    final next = _scroll.hasClients && _scroll.offset > 0;
    if (next != _pinned.value) _pinned.value = next;
  }

  Animation<double> _at(double start, [double length = 0.45]) => CurvedAnimation(
    parent: _intro,
    curve: Interval(start.clamp(0.0, 1.0), (start + length).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
  );

  Widget _enter(Animation<double> a, Widget child, {double dy = 0.15}) => FadeTransition(
    opacity: a,
    child: SlideTransition(
      position: Tween(begin: Offset(0, dy), end: Offset.zero).animate(a),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final canPop = widget.showBack && Navigator.of(context).canPop();
    final rows = widget.children;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        // White below, green behind the header: the sheet then reaches the
        // bottom without being stretched (short forms), and the green shows
        // around its rounded top corners.
        backgroundColor: Colors.white,
        body: GestureDetector(
          // Tapping outside a field closes the keyboard.
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: const ColoredBox(color: SplashScreen.background),
              ),
              CustomScrollView(
                controller: _scroll,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_headerTop, SplashScreen.background],
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(24, top + _LogoRow.topGap, 24, 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LogoRow(
                            onBack: canPop ? () => Navigator.of(context).maybePop() : null,
                            logo: _enter(_at(0), const _Logo(), dy: -0.3),
                          ),
                          const SizedBox(height: 22),
                          _enter(
                            _at(0.08),
                            Text(
                              widget.title,
                              style: AppTextStyle.h3_semibold_20(
                                color: Colors.white,
                              ).copyWith(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _enter(
                            _at(0.14),
                            Text(
                              widget.subtitle,
                              style: AppTextStyle.sub_h3_regular_14(
                                color: Colors.white.withValues(alpha: 0.75),
                              ).copyWith(height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // The white sheet (scrolls with the keyboard open).
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + MediaQuery.paddingOf(context).bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < rows.length; i++) _enter(_at(0.2 + i * 0.06, 0.5), rows[i]),
                          if (widget.footer != null) ...[
                            const SizedBox(height: 28),
                            _enter(_at(0.5), Center(child: widget.footer!)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Pinned bar, shown once the page has scrolled at all. Its logo
              // row lines up with the header's, so the swap is not visible.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _pinned,
                  builder: (_, shown, __) {
                    if (!shown) return const SizedBox.shrink();
                    return _CollapsedBar(
                      top: top,
                      onBack: canPop ? () => Navigator.of(context).maybePop() : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The header's top row: back button on the left, logo centred.
class _LogoRow extends StatelessWidget {
  const _LogoRow({required this.logo, this.onBack});

  final Widget logo;
  final VoidCallback? onBack;

  static const topGap = 8.0;
  static const height = 44.0;
  static const bottomGap = 10.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          if (onBack != null) _GlassBackButton(onTap: onBack!) else const SizedBox(width: 44),
          const Spacer(),
          logo,
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// The copper "P" mark, cropped to drop the tagline.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.76,
        child: Image.asset(_AuthScaffoldState._logo, height: 58, semanticLabel: 'Peak Privee'),
      ),
    );
  }
}

/// Pinned green app bar (back button and logo) shown once the page scrolls.
/// Same colour as the top of the header and the same row layout, so it
/// reads as the header's logo row staying in place.
class _CollapsedBar extends StatelessWidget {
  const _CollapsedBar({required this.top, this.onBack});

  final double top;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, top + _LogoRow.topGap, 24, _LogoRow.bottomGap),
        decoration: BoxDecoration(
          color: _AuthScaffoldState._headerTop,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 3)),
          ],
        ),
        child: _LogoRow(onBack: onBack, logo: const _Logo()),
      ),
    );
  }
}

/// Back button on the green header (scrolls with it).
class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white, semanticLabel: 'Back'),
        ),
      ),
    );
  }
}

/// "Question? Action" line under an auth form.
class AuthSwitchLine extends StatelessWidget {
  const AuthSwitchLine({super.key, required this.question, required this.action, required this.onTap});

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Wraps onto two lines when it doesn't fit (small phone, large text).
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(question, style: AppTextStyle.sub_h3_regular_14(color: AppColors.textSecondary)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF9A7A12),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 40),
          ),
          child: Text(action, style: AppTextStyle.sub_h3_semibold_14(color: const Color(0xFF9A7A12))),
        ),
      ],
    );
  }
}
