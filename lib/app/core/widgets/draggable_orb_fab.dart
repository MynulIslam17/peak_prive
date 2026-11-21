import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/gesture_exclusion.dart';

/// Which screen edge the orb rests on.
enum OrbSide { left, right }

/// A floating, animated "orb" button that can be dragged anywhere and tucked
/// into the side of the screen (like the ElevenLabs app).
///
/// * The orb is a slow, living gradient (soft blobs drifting inside a circle).
/// * Drag it anywhere; on release it springs to the nearest left/right edge.
/// * Push it past an edge, or flick it hard sideways, and it hides: only a
///   sliver stays visible. Tap or drag the sliver to bring it back.
/// * With [storageKey] it remembers its side, height and hidden state, also
///   after the app restarts.
///
/// Wrap the content it floats over. It can wrap one screen's body (only that
/// screen gets the orb) or the whole app via `GetMaterialApp.builder` (it then
/// stays over every route):
///
/// ```dart
/// DraggableOrbFab(
///   icon: const Icon(Icons.apps_rounded),
///   semanticLabel: 'Switch service',
///   onTap: openSwitcher,
///   bottomInset: FloatingNavBar.clearance, // keep clear of a bottom bar
///   storageKey: 'home_orb',
///   child: screenContent,
/// )
/// ```
class DraggableOrbFab extends StatefulWidget {
  const DraggableOrbFab({
    super.key,
    required this.child,
    this.icon,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.semanticLabel,
    this.size = 58,
    this.edgeMargin = 14,
    this.peek = 22,
    this.topInset = 0,
    this.bottomInset = 0,
    this.initialSide = OrbSide.right,
    this.initialHeight = 1,
    this.colors = goldColors,
    this.storageKey,
    this.hintText,
    this.enabled = true,
    this.dockColor = const Color(0xFF161616),
  });

  /// The app's gold, from deep amber to cream.
  static const goldColors = [
    Color(0xFFD4AF38), // base (also the glow)
    Color(0xFFF2D27A),
    Color(0xFFFFF0C2),
    Color(0xFFB8891C),
  ];

  /// What the orb floats over.
  final Widget child;

  /// Drawn in the middle of the orb (an icon or a small image).
  final Widget? icon;

  final VoidCallback? onTap;

  /// Hold the orb (e.g. push-to-talk). Not available while it is hidden.
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  /// Read by screen readers ("Switch service").
  final String? semanticLabel;

  /// Orb diameter.
  final double size;

  /// Gap to the screen edge when resting.
  final double edgeMargin;

  /// How much of the orb stays visible when hidden at the edge.
  final double peek;

  /// Extra space kept free at the top (below the status bar) and bottom
  /// (above the home indicator), e.g. a header or a floating nav bar.
  final double topInset;
  final double bottomInset;

  /// Where it starts the first time: side, and height from 0 (top) to 1
  /// (bottom) of the space it can move in.
  final OrbSide initialSide;
  final double initialHeight;

  /// Blob colours inside the orb; the first is the base and the glow.
  final List<Color> colors;

  /// Remembers the position under this key (in memory and on the device).
  /// Without it the orb starts at [initialSide]/[initialHeight] every time.
  final String? storageKey;

  /// Shown once next to the orb (once ever with [storageKey]).
  final String? hintText;

  /// When false the orb is not shown (the [child] still is).
  final bool enabled;

  /// The curved "dock" that grows out of the screen edge while the orb is
  /// pushed towards it, pulls it in, and holds it while hidden.
  final Color dockColor;

  @override
  State<DraggableOrbFab> createState() => _DraggableOrbFabState();
}

/// Where the orb rests: everything else is derived from the screen size.
class _OrbPlace {
  const _OrbPlace(this.side, this.height, this.hidden);
  final OrbSide side;
  final double height; // 0..1 of the free vertical space
  final bool hidden;
}

class _DraggableOrbFabState extends State<DraggableOrbFab> with TickerProviderStateMixin {
  /// Survives the screen being rebuilt or re-opened (no jump on return).
  static final Map<String, _OrbPlace> _memory = {};
  static final Set<String> _hintShown = {};

  /// Extra touch area on the inner side of a hidden orb (the sliver alone is
  /// too thin to hit reliably).
  static const _hiddenTouchSlop = 18.0;

  late final AnimationController _life = AnimationController(vsync: this, duration: const Duration(seconds: 6));
  late final AnimationController _snap = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
  Animation<Offset>? _snapAnim;

  /// How open the edge dock is: 0 none, 1 fully wrapped around the orb.
  late final AnimationController _dock = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

  /// Where the finger has taken the orb (before the dock's pull).
  Offset? _raw;

  /// The edge the orb is nearer to while dragging.
  OrbSide _dragSide = OrbSide.right;

  /// Past the hide point while dragging: releasing now hides the orb.
  bool _inDock = false;
  bool _dragging = false;

  /// Position while dragging or snapping; null when resting (then the
  /// position comes from [_place] and the current screen size).
  final _live = ValueNotifier<Offset?>(null);

  late _OrbPlace _place;
  bool _pressed = false;
  bool _showHint = false;
  Timer? _hintTimer;

  Size _area = Size.zero;
  double _top = 0;
  double _bottom = 0;

  double get _s => widget.size;
  double get _minY => _top + widget.edgeMargin;
  double get _maxY => math.max(_minY, _area.height - _bottom - _s - widget.edgeMargin);

  @override
  void initState() {
    super.initState();
    final key = widget.storageKey;
    _place =
        (key == null ? null : _memory[key]) ??
        _OrbPlace(widget.initialSide, widget.initialHeight.clamp(0.0, 1.0), false);
    _snap.addListener(() {
      final a = _snapAnim;
      if (a != null) _live.value = a.value;
    });
    _snap.addStatusListener((s) {
      if (s == AnimationStatus.completed) _live.value = null;
    });
    // Settled in a new place: move the back-swipe exclusion with it.
    _live.addListener(() {
      if (_live.value == null) _scheduleExclusionSync();
    });
    if (_place.hidden) _dock.value = 1;
    if (key != null && !_memory.containsKey(key)) _restore(key);
    _maybeShowHint();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect "remove animations" in the system settings.
    if (MediaQuery.of(context).disableAnimations) {
      _life.value = 0.2;
      _life.stop();
    } else if (!_life.isAnimating) {
      _life.repeat();
    }
  }

  @override
  void dispose() {
    GestureExclusion.set(this, null, 1);
    _hintTimer?.cancel();
    _life.dispose();
    _snap.dispose();
    _dock.dispose();
    _live.dispose();
    super.dispose();
  }

  // ───────────────────────── persistence ─────────────────────────

  Future<void> _restore(String key) async {
    try {
      final p = await SharedPreferences.getInstance();
      final side = p.getString('$key.side');
      final height = p.getDouble('$key.height');
      final hidden = p.getBool('$key.hidden');
      if (!mounted || side == null || height == null) return;
      final place = _OrbPlace(side == 'left' ? OrbSide.left : OrbSide.right, height.clamp(0.0, 1.0), hidden ?? false);
      _memory[key] = place;
      if (_live.value == null) {
        setState(() => _place = place);
        _dock.value = place.hidden ? 1 : 0;
      }
    } catch (_) {
      // Storage unavailable: keep the default place.
    }
  }

  void _save() {
    final key = widget.storageKey;
    if (key == null) return;
    _memory[key] = _place;
    SharedPreferences.getInstance()
        .then((p) {
          p.setString('$key.side', _place.side.name);
          p.setDouble('$key.height', _place.height);
          p.setBool('$key.hidden', _place.hidden);
        })
        .catchError((_) {});
  }

  Future<void> _maybeShowHint() async {
    final text = widget.hintText;
    final key = widget.storageKey ?? '_orb';
    if (text == null || _hintShown.contains(key)) return;
    _hintShown.add(key);
    if (widget.storageKey != null) {
      try {
        final p = await SharedPreferences.getInstance();
        if (p.getBool('$key.hintSeen') ?? false) return;
        await p.setBool('$key.hintSeen', true);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _showHint = true);
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  void _hideHint() {
    if (!_showHint) return;
    _hintTimer?.cancel();
    setState(() => _showHint = false);
  }

  // ─────────────────── Android edge back-swipe ───────────────────

  /// The resting orb sits at the screen edge, inside the strip where
  /// Android's gesture navigation treats a swipe as "back". Without this a
  /// grab of the (hidden) orb often went back instead of dragging it. The
  /// edge strip next to the orb is excluded, but only while the orb is
  /// actually on screen (not on another tab or under a pushed page).
  bool _exclusionScheduled = false;

  void _scheduleExclusionSync() {
    if (_exclusionScheduled) return;
    _exclusionScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _exclusionScheduled = false;
      _syncExclusion();
    });
  }

  void _syncExclusion() {
    if (!mounted) return;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final box = context.findRenderObject() as RenderBox?;
    final visible = widget.enabled && TickerMode.valuesOf(context).enabled && box != null && box.attached && box.hasSize;
    // Mid-drag or mid-snap: keep the old area until it settles.
    if (visible && _live.value != null) return;
    if (!visible) {
      GestureExclusion.set(this, null, dpr);
      return;
    }
    final pos = _restOffset;
    final onRight = _place.side == OrbSide.right;
    final slop = _place.hidden ? _hiddenTouchSlop : 0.0;
    const pad = 12.0;
    final local = onRight
        ? Rect.fromLTRB(pos.dx - slop, pos.dy - pad, _area.width, pos.dy + _s + pad)
        : Rect.fromLTRB(0, pos.dy - pad, pos.dx + _s + slop, pos.dy + _s + pad);
    GestureExclusion.set(this, local.shift(box.localToGlobal(Offset.zero)), dpr);
  }

  // ───────────────────────── geometry ─────────────────────────

  double _restX(OrbSide side, bool hidden) {
    if (hidden) return side == OrbSide.left ? -_s + widget.peek : _area.width - widget.peek;
    return side == OrbSide.left ? widget.edgeMargin : _area.width - _s - widget.edgeMargin;
  }

  double _yFor(double height) => _minY + height * (_maxY - _minY);

  double _heightFor(double y) => _maxY <= _minY ? 0 : ((y - _minY) / (_maxY - _minY)).clamp(0.0, 1.0);

  Offset get _restOffset => Offset(_restX(_place.side, _place.hidden), _yFor(_place.height));

  Offset get _current => _live.value ?? _restOffset;

  void _animateTo(Offset target, {required Curve curve}) {
    _snapAnim = Tween<Offset>(begin: _current, end: target).animate(CurvedAnimation(parent: _snap, curve: curve));
    _snap.forward(from: 0);
  }

  // ───────────────────────── gestures ─────────────────────────

  /// How open the dock is while it waits at the edge during a drag: a small
  /// bump from the start, growing as the orb comes closer.
  static const _dockWaiting = 0.25;
  static const _dockNear = 0.6;

  /// The dock grabs the orb this close to the edge (gap in px), and lets it
  /// go again beyond [_releaseGap] (so it doesn't flicker at the border).
  static const _grabGap = 4.0;
  static const _releaseGap = 16.0;

  OrbSide _nearerSide(double x) => x + _s / 2 < _area.width / 2 ? OrbSide.left : OrbSide.right;

  /// Space between the orb and [side]'s edge (negative when pushed past it).
  double _gap(double x, OrbSide side) => side == OrbSide.left ? x : _area.width - _s - x;

  /// 0 in the middle of the screen, 1 where the dock grabs it.
  double _closeness(double x, OrbSide side) {
    final far = (_area.width - _s) / 2;
    return ((far - _gap(x, side)) / (far - _grabGap)).clamp(0.0, 1.0);
  }

  void _onPanStart(DragStartDetails _) {
    _raw = _current;
    _live.value = _raw;
    _snap.stop();
    _hideHint();
    _dragging = true;
    _inDock = _place.hidden;
    _dragSide = _place.hidden ? _place.side : _nearerSide(_raw!.dx);
    // The dock pops out of the nearer edge as soon as the drag starts.
    if (!_inDock) _popDock(_raw!.dx);
    setState(() => _pressed = true);
  }

  void _popDock(double x) {
    final target = lerpDouble(_dockWaiting, _dockNear, Curves.easeIn.transform(_closeness(x, _dragSide)))!;
    _dock.animateTo(target, duration: const Duration(milliseconds: 240), curve: Curves.easeOutBack);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final p = (_raw ?? _current) + d.delta;
    final raw = Offset(
      // It may travel partly off-screen so it can be pushed into the edge.
      p.dx.clamp(-_s * 0.8, _area.width - _s * 0.2),
      p.dy.clamp(_minY, _maxY),
    );
    _raw = raw;
    final side = _nearerSide(raw.dx);

    // Crossing the middle: the dock leaves this edge and pops out of the other.
    if (side != _dragSide && !_inDock) {
      _dragSide = side;
      _dock.value = 0;
      setState(() {});
      _popDock(raw.dx);
    }

    final gap = _gap(raw.dx, _dragSide);
    final inDock = _inDock ? gap <= _releaseGap : gap <= _grabGap;
    if (inDock != _inDock) {
      // A firm tick when the dock grabs it, a light one when it lets go.
      inDock ? HapticFeedback.mediumImpact() : HapticFeedback.selectionClick();
      _inDock = inDock;
      if (inDock) {
        _dock.animateTo(1, duration: const Duration(milliseconds: 260), curve: Curves.easeOutBack);
      } else {
        _popDock(raw.dx);
      }
    } else if (!inDock && !_dock.isAnimating) {
      // Grows smoothly as the orb comes closer.
      _dock.value = lerpDouble(_dockWaiting, _dockNear, Curves.easeIn.transform(_closeness(raw.dx, _dragSide)))!;
    }

    // Grabbed: the orb is pulled into the dock, towards its hidden place.
    _live.value = inDock ? Offset(lerpDouble(raw.dx, _restX(_dragSide, true), 0.6)!, raw.dy) : raw;
  }

  void _onPanEnd(DragEndDetails d) {
    final pos = _raw ?? _current;
    final vx = d.velocity.pixelsPerSecond.dx;

    // A clear sideways flick picks the side, otherwise the nearer half.
    final side = _inDock ? _dragSide : (vx.abs() > 700 ? (vx < 0 ? OrbSide.left : OrbSide.right) : _nearerSide(pos.dx));

    // Hide when let go inside the dock or flicked hard.
    final hide = _inDock || vx.abs() > 1800;
    if (hide && !_place.hidden) {
      _inDock ? HapticFeedback.lightImpact() : HapticFeedback.mediumImpact();
    } else if (!hide && _place.hidden) {
      HapticFeedback.selectionClick();
    }

    _raw = null;
    _dragging = false;
    _inDock = false;
    _dragSide = side;
    setState(() {
      _pressed = false;
      _place = _OrbPlace(side, _heightFor(pos.dy), hide);
    });
    _save();
    _dock.animateTo(
      hide ? 1 : 0,
      duration: Duration(milliseconds: hide ? 280 : 200),
      curve: hide ? Curves.easeOutBack : Curves.easeIn,
    );
    _animateTo(_restOffset, curve: hide ? Curves.easeOutCubic : Curves.easeOutBack);
  }

  void _onTap() {
    if (_place.hidden) {
      HapticFeedback.selectionClick();
      setState(() => _place = _OrbPlace(_place.side, _place.height, false));
      _save();
      _dock.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      _animateTo(_restOffset, curve: Curves.easeOutBack);
      return;
    }
    _hideHint();
    widget.onTap?.call();
  }

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    // Also re-runs when the tab or route visibility (TickerMode) changes.
    TickerMode.valuesOf(context).enabled;
    _scheduleExclusionSync();
    if (!widget.enabled) return widget.child;
    final mq = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        _area = constraints.biggest;
        // Clear of the status bar, the home indicator, the keyboard and any
        // bars the caller names.
        _top = mq.padding.top + widget.topInset;
        _bottom = math.max(mq.padding.bottom + widget.bottomInset, mq.viewInsets.bottom);

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            // Only the orb (and the hint) take touches; the rest passes through.
            Positioned.fill(
              child: ValueListenableBuilder<Offset?>(
                valueListenable: _live,
                builder: (context, live, _) {
                  final pos = live ?? _restOffset;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _dockLayer(pos),
                      if (_showHint && widget.hintText != null && !_place.hidden) _hint(pos),
                      _orb(pos),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dockLayer(Offset pos) {
    final side = _dragging ? _dragSide : _place.side;
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _DockPainter(
            progress: _dock,
            side: side,
            centerY: pos.dy + _s / 2,
            // The hidden orb's centre, measured from the edge (negative:
            // past it).
            centerFromEdge: widget.peek - _s / 2,
            orbRadius: _s / 2,
            color: widget.dockColor,
          ),
        ),
      ),
    );
  }

  Widget _hint(Offset pos) {
    final right = _place.side == OrbSide.right;
    return Positioned(
      left: 16,
      right: 16,
      top: math.max(_minY, pos.dy - 64),
      child: IgnorePointer(
        child: Align(
          alignment: right ? Alignment.centerRight : Alignment.centerLeft,
          child: _HintBubble(text: widget.hintText!),
        ),
      ),
    );
  }

  Widget _orb(Offset pos) {
    final hidden = _place.hidden && live == null;
    final onRight = _place.side == OrbSide.right;
    // A hidden orb gets extra touch area on its visible (inner) side.
    final slop = hidden ? _hiddenTouchSlop : 0.0;
    final left = onRight ? pos.dx - slop : pos.dx;

    return Positioned(
      left: left,
      top: pos.dy,
      width: _s + slop,
      height: _s,
      child: Semantics(
        button: true,
        label: _place.hidden
            ? '${widget.semanticLabel ?? 'Button'}, hidden at the edge. Tap to show.'
            : widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onLongPressStart: _place.hidden || widget.onLongPressStart == null
              ? null
              : (_) {
                  HapticFeedback.mediumImpact();
                  _hideHint();
                  setState(() => _pressed = true);
                  widget.onLongPressStart!.call();
                },
          onLongPressEnd: _place.hidden || widget.onLongPressStart == null
              ? null
              : (_) {
                  setState(() => _pressed = false);
                  widget.onLongPressEnd?.call();
                },
          child: Align(
            alignment: onRight ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedScale(
              scale: _pressed && !_inDock ? 1.1 : 1.0,
              // Shrink towards the edge so the visible sliver stays the same.
              alignment: onRight ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedOrb(animation: _life, size: _s, colors: widget.colors, child: widget.icon),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Offset? get live => _live.value;
}

// ───────────────────────── the orb itself ─────────────────────────

/// The living gradient orb. Usable on its own (e.g. a static avatar-like
/// badge) with any looping [animation] from 0 to 1.
class AnimatedOrb extends StatelessWidget {
  const AnimatedOrb({
    super.key,
    required this.animation,
    required this.size,
    this.colors = DraggableOrbFab.goldColors,
    this.child,
  });

  final Animation<double> animation;
  final double size;
  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: colors.first.withValues(alpha: 0.38), blurRadius: 18, spreadRadius: 1),
            BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        // Repaints on every tick without rebuilding any widget.
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _OrbPainter(animation, colors),
            child: child == null
                ? null
                : Center(
                    child: IconTheme.merge(
                      data: const IconThemeData(color: Color(0xDD000000), size: 24),
                      child: child!,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter(this.animation, this.colors) : super(repaint: animation);

  final Animation<double> animation;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final a = t * 2 * math.pi;
    // Gentle breathing (3 breaths per loop, so the loop stays seamless).
    final breathe = 1 + 0.025 * math.sin(a * 3);
    final r = size.width / 2 * breathe;
    final c = size.center(Offset.zero);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r, Paint()..color = colors.first);

    // Soft blobs drifting on loops (integer frequencies keep it seamless).
    for (var i = 0; i < colors.length; i++) {
      final phase = i * 2 * math.pi / colors.length;
      final dir = i.isEven ? 1 : -1;
      final p = c + Offset(math.cos(dir * a + phase) * r * 0.5, math.sin(2 * a + phase) * r * 0.45);
      final blobR = r * (0.85 + 0.1 * math.sin(a + phase));
      canvas.drawCircle(
        p,
        blobR,
        Paint()
          ..shader = RadialGradient(
            colors: [colors[i].withValues(alpha: 0.95), colors[i].withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: p, radius: blobR)),
      );
    }

    // Glossy highlight, top left.
    final hc = c + Offset(-r * 0.3, -r * 0.35);
    canvas.drawCircle(
      hc,
      r * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: hc, radius: r * 0.55)),
    );
    canvas.restore();

    // Thin rim.
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.animation != animation || old.colors != colors;
}

/// The black curve that grows out of the screen edge: a circle around the
/// (hidden) orb joined to the wall by smooth concave fillets, like a drop
/// coming out of the edge.
class _DockPainter extends CustomPainter {
  _DockPainter({
    required this.progress,
    required this.side,
    required this.centerY,
    required this.centerFromEdge,
    required this.orbRadius,
    required this.color,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final OrbSide side;
  final double centerY;
  final double centerFromEdge;
  final double orbRadius;
  final Color color;

  static const _ring = 6.0;
  static const _fillet = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.value;
    if (p <= 0.01) return;

    // Drawn for the left edge; mirrored for the right.
    canvas.save();
    if (side == OrbSide.right) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final cx = centerFromEdge;
    final cy = centerY;
    final r = lerpDouble(orbRadius * 0.45, orbRadius + _ring, p.clamp(0.0, 1.2))!;
    if (cx + r <= 1) {
      canvas.restore();
      return;
    }
    final f = _fillet * p.clamp(0.25, 1.0);

    // Where the circle crosses the wall (x = 0).
    final yi = math.sqrt(math.max(r * r - cx * cx, 0.0));
    // Join the fillets to the circle a little inside the screen.
    final xt = (f * 0.6).clamp(0.5, cx + r - 1);
    final ct = ((xt - cx) / r).clamp(-1.0, 1.0);
    final thetaTop = -math.acos(ct);
    final thetaBottom = math.acos(ct);

    Offset at(double t) => Offset(cx + r * math.cos(t), cy + r * math.sin(t));
    Offset dir(double t) => Offset(-math.sin(t), math.cos(t)); // travel direction

    final top = at(thetaTop);
    final bottom = at(thetaBottom);
    final k = f * 0.55;
    final wallTop = cy - yi - f;
    final wallBottom = cy + yi + f;

    final path = Path()
      ..moveTo(-2, wallTop)
      ..lineTo(0, wallTop)
      ..cubicTo(0, wallTop + k, top.dx - dir(thetaTop).dx * k, top.dy - dir(thetaTop).dy * k, top.dx, top.dy)
      ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: r), thetaTop, thetaBottom - thetaTop, false)
      ..cubicTo(
        bottom.dx + dir(thetaBottom).dx * k,
        bottom.dy + dir(thetaBottom).dy * k,
        0,
        wallBottom - k,
        0,
        wallBottom,
      )
      ..lineTo(-2, wallBottom)
      ..close();

    final alpha = (p * 8).clamp(0.0, 1.0); // solid black almost at once
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.35 * alpha), 6, false);
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: color.a * alpha));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DockPainter old) =>
      old.progress != progress ||
      old.side != side ||
      old.centerY != centerY ||
      old.centerFromEdge != centerFromEdge ||
      old.orbRadius != orbRadius ||
      old.color != color;
}

class _HintBubble extends StatelessWidget {
  const _HintBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2328),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35)),
      ),
    );
  }
}
