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

  /// Once the header title has scrolled under the top edge, a white app bar
  /// (back button and title) is shown. It's either hidden or fully shown,
  /// never half see-through over the header's own title.
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<bool> _solid = ValueNotifier(false);
  final GlobalKey _titleKey = GlobalKey();
  bool _syncScheduled = false;

  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_scheduleBarSync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncBar());
  }

  @override
  void dispose() {
    _scroll.removeListener(_scheduleBarSync);
    _scroll.dispose();
    _solid.dispose();
    _intro.dispose();
    super.dispose();
  }

  /// Wait until this frame's layout is done. Reading the title mid-scroll
  /// still sees the previous position, which would show the bar too early.
  void _scheduleBarSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      _syncBar();
    });
  }

  /// The white bar is shown only after the green title has gone fully behind
  /// it. Until then the bar is not built, so its title and back icon cannot
  /// sit on top of the header.
  void _syncBar() {
    if (!mounted) return;
    final box = _titleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final titleBottom = box.localToGlobal(Offset(0, box.size.height)).dy;
    final cover = MediaQuery.paddingOf(context).top + _CollapsedBar.height;
    final next = titleBottom <= cover;
    if (next != _solid.value) _solid.value = next;
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
                          colors: [Color(0xFF0A5C44), SplashScreen.background],
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(24, top + 8, 24, 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 44,
                            child: Row(
                              children: [
                                if (canPop)
                                  _GlassBackButton(onTap: () => Navigator.of(context).maybePop())
                                else
                                  const SizedBox(width: 44),
                                const Spacer(),
                                _enter(
                                  _at(0),
                                  ClipRect(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      heightFactor: 0.76,
                                      child: Image.asset(_logo, height: 58, semanticLabel: 'Peak Privee'),
                                    ),
                                  ),
                                  dy: -0.3,
                                ),
                                const Spacer(),
                                const SizedBox(width: 44),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _enter(
                            _at(0.08),
                            Text(
                              widget.title,
                              key: _titleKey,
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
              // Solid bar only after the green title has scrolled behind it.
              // While the header title is on screen this child is empty, so
              // a second title and back icon cannot be painted over it.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _solid,
                  builder: (_, shown, __) {
                    if (!shown) return const SizedBox.shrink();
                    return _CollapsedBar(
                      top: top,
                      title: widget.title,
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

/// Solid white bar (back button and screen title) shown over the top once
/// the green header title has scrolled behind it.
class _CollapsedBar extends StatelessWidget {
  const _CollapsedBar({required this.top, required this.title, this.onBack});

  final double top;
  final String title;
  final VoidCallback? onBack;

  static const height = 56.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: ColoredBox(
        color: Colors.white,
        child: Container(
          height: top + height,
          padding: EdgeInsets.only(top: top),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 4),
              if (onBack != null)
                IconButton(
                  tooltip: 'Back',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.sub_h1_medium_18(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 52), // balances the back button
            ],
          ),
        ),
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
