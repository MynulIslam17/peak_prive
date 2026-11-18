import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/exit_app_guard.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';

/// One choice on the service picker.
class _Service {
  const _Service(this.label, this.subtitle, this.icon, {this.type});

  final String label;
  final String subtitle;
  final IconData icon;

  /// NavController service type; null for the itinerary (its own screen).
  final String? type;
}

const _services = [
  _Service('Ski Pass', 'Lift passes', Icons.confirmation_number_outlined, type: 'ski_pass'),
  _Service('Ski Hire', 'Skis, boards & boots', Icons.downhill_skiing_rounded, type: 'ski_hire'),
  _Service('Transport', 'Transfers & rides', Icons.airport_shuttle_outlined, type: 'transport'),
  _Service('Restaurant', 'Book a table', Icons.restaurant_rounded, type: 'restaurant'),
  _Service('Massage', 'Spa & recovery', Icons.spa_outlined, type: 'massage'),
];

const _itinerary = _Service('Itinerary', 'Your bookings by day', Icons.event_note_rounded);

/// The photo behind the picker; the splash decodes it ahead of time.
const serviceBackdrop = 'assets/images/opening.jpg';

/// Shown under the photo (and before it's decoded): the photo's dark tone,
/// not black, so there's no dark flash.
const _backdropTone = Color(0xFF1E2A2A);

/// The customer app's start screen: pick what to book (or open the
/// itinerary). It is the last screen, so back asks before closing the app.
class AllServiceScreen extends StatefulWidget {
  const AllServiceScreen({super.key});

  @override
  State<AllServiceScreen> createState() => _AllServiceScreenState();
}

class _AllServiceScreenState extends State<AllServiceScreen> with TickerProviderStateMixin {
  final navController = Get.find<NavController>();

  // Animations are drawn with transition widgets (fade/slide/scale layers),
  // so nothing rebuilds or re-lays out per frame; the frosted tiles and the
  // photo sit in their own repaint boundaries.

  /// Staggered entrance of the header and tiles; starts once the photo is
  /// on screen so it isn't spent behind a blank frame.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  /// Quick settle of the photo (a light zoom). Short, so it's done before the
  /// frosted tiles are visible: moving the photo makes every blur redraw.
  late final AnimationController _photo = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _photoScale = Tween(
    begin: 1.06,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _photo, curve: Curves.easeOutCubic));

  // Header pieces, then one entrance + icon pop per tile.
  late final _chipIn = _at(0, 0.3);
  late final _greetingIn = _at(0.08, 0.35);
  late final _line1In = _at(0.14, 0.4);
  late final _line2In = _at(0.22, 0.4);
  late final List<Animation<double>> _tileIn = [for (var i = 0; i < 6; i++) _at(0.32 + i * 0.08, 0.38)];
  late final List<Animation<double>> _iconPop = [
    for (var i = 0; i < 6; i++) _at(0.44 + i * 0.08, 0.3, Curves.easeOutBack),
  ];

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Usually already decoded by the splash; never wait more than 300 ms.
    Future.any([
      precacheImage(const AssetImage(serviceBackdrop), context),
      Future<void>.delayed(const Duration(milliseconds: 300)),
    ]).whenComplete(() {
      if (!mounted) return;
      _photo.forward();
      _intro.forward();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _photo.dispose();
    super.dispose();
  }

  void _open(_Service s) {
    HapticFeedback.selectionClick();
    navController.resetIndex();
    final type = s.type;
    if (type == null) {
      Get.toNamed(Routes.itinerary);
      return;
    }
    navController.addType(type);
    Get.toNamed(Routes.bottomNav);
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String? get _firstName {
    if (!Get.isRegistered<AuthController>()) return null;
    final name = Get.find<AuthController>().userModel?.fullName.trim() ?? '';
    if (name.isEmpty || name == 'N/A') return null;
    return name.split(RegExp(r'\s+')).first;
  }

  Animation<double> _at(double start, [double length = 0.4, Curve curve = Curves.easeOutCubic]) => CurvedAnimation(
    parent: _intro,
    curve: Interval(start, (start + length).clamp(0.0, 1.0), curve: curve),
  );

  /// A tile rises, fades and grows in; its icon pops just after.
  Widget _tileEnter(int index, Widget Function(Animation<double> pop) tile) {
    final a = _tileIn[index];
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(a),
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(a),
          child: RepaintBoundary(child: tile(_iconPop[index])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _firstName;
    final lastUsed = navController.getServiceType;

    return ExitAppGuard(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _backdropTone,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Fades in if it wasn't decoded yet, then settles from a
              // slight zoom.
              RepaintBoundary(
                child: ScaleTransition(
                  scale: _photoScale,
                  child: Image.asset(
                    serviceBackdrop,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    frameBuilder: (_, child, frame, sync) => sync
                        ? child
                        : AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            child: child,
                          ),
                  ),
                ),
              ),
              // Darker at the top (text) and bottom (tiles), the photo shows
              // in between.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.3, 0.55, 1],
                    colors: [Color(0xB3000000), Color(0x33000000), Color(0x40000000), Color(0xE6000000)],
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final pad = c.maxWidth > 600 ? (c.maxWidth - 560) / 2 : 20.0;
                    // Padding + badge + gap stay fixed; the two text lines
                    // grow with the phone's font size, so the tile does too.
                    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
                    final tileHeight = 96 + 44 * textScale;
                    final all = [..._services, _itinerary];
                    final rows = <Widget>[];
                    for (var i = 0; i < all.length; i += 2) {
                      if (i > 0) rows.add(const SizedBox(height: 12));
                      rows.add(
                        SizedBox(
                          height: tileHeight,
                          child: Row(
                            children: [
                              for (var j = i; j < i + 2 && j < all.length; j++) ...[
                                if (j > i) const SizedBox(width: 12),
                                Expanded(
                                  child: _tileEnter(
                                    j,
                                    (pop) => _ServiceTile(
                                      service: all[j],
                                      lastUsed: all[j].type != null && all[j].type == lastUsed,
                                      highlight: all[j].type == null,
                                      iconPop: pop,
                                      onTap: () => _open(all[j]),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }
                    // Header at the top, tiles at the bottom; scrolls only
                    // when the screen is too short for both.
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(pad, 28, pad, 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: c.maxHeight - 48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Header(
                              greeting: name == null ? _greeting : '$_greeting, $name',
                              chip: _chipIn,
                              greetingIn: _greetingIn,
                              line1: _line1In,
                              line2: _line2In,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Column(children: rows),
                            ),
                          ],
                        ),
                      ),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.chip,
    required this.greetingIn,
    required this.line1,
    required this.line2,
  });

  final String greeting;
  final Animation<double> chip;
  final Animation<double> greetingIn;
  final Animation<double> line1;
  final Animation<double> line2;

  /// Text that slides up from behind a clip edge while fading in.
  static Widget _reveal(Animation<double> a, Widget child) => ClipRect(
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(a),
      child: FadeTransition(opacity: a, child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyle.h3_semibold_20(
      color: Colors.white,
    ).copyWith(fontSize: 30, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -0.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The chip fades in while sliding from the left.
        FadeTransition(
          opacity: chip,
          child: SlideTransition(
            position: Tween(begin: const Offset(-0.15, 0), end: Offset.zero).animate(chip),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary_1.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary_1.withValues(alpha: 0.45)),
              ),
              child: Text(
                'PEAK PRIVEE',
                style: AppTextStyle.p_medium_12(color: AppColors.primary_1).copyWith(letterSpacing: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _reveal(
          greetingIn,
          Text(greeting, style: AppTextStyle.sub_h2_medium_16(color: Colors.white.withValues(alpha: 0.8))),
        ),
        const SizedBox(height: 6),
        _reveal(line1, Text('What would you like', style: titleStyle)),
        _reveal(line2, Text('to book today?', style: titleStyle)),
      ],
    );
  }
}

/// Frosted-glass tile: gold icon badge, name and a one-line description.
class _ServiceTile extends StatefulWidget {
  const _ServiceTile({
    required this.service,
    required this.onTap,
    this.lastUsed = false,
    this.highlight = false,
    this.iconPop,
  });

  final _Service service;
  final VoidCallback onTap;
  final bool lastUsed;

  /// The itinerary: gold-tinted, with an arrow (it opens a screen rather
  /// than a service).
  final bool highlight;

  /// Drives the icon badge's pop-in (0 → 1, may overshoot).
  final Animation<double>? iconPop;

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile> {
  bool _down = false;

  void _press(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final gold = AppColors.primary_1;
    final radius = BorderRadius.circular(22);

    final badgeBox = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gold,
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Icon(s.icon, size: 22, color: Colors.black87),
    );
    final pop = widget.iconPop;
    final badge = pop == null ? badgeBox : ScaleTransition(scale: pop, child: badgeBox);

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          s.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.sub_h2_medium_16(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          s.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.p_regular_12(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            badge,
            const SizedBox(width: 8),
            const Spacer(),
            if (widget.lastUsed)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Last used',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: AppTextStyle.p_medium_12(color: Colors.white).copyWith(fontSize: 10),
                  ),
                ),
              )
            else if (widget.highlight)
              Icon(Icons.arrow_outward_rounded, size: 20, color: gold),
          ],
        ),
        const Spacer(),
        texts,
      ],
    );

    return Semantics(
      button: true,
      label: '${s.label}. ${s.subtitle}${widget.lastUsed ? '. Last used' : ''}',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _press(true),
        onTapUp: (_) => _press(false),
        onTapCancel: () => _press(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: widget.highlight
                      ? gold.withValues(alpha: _down ? 0.3 : 0.2)
                      : Colors.white.withValues(alpha: _down ? 0.22 : 0.12),
                  border: Border.all(
                    color: widget.lastUsed || widget.highlight
                        ? gold.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.18),
                    width: widget.lastUsed ? 1.4 : 1,
                  ),
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
