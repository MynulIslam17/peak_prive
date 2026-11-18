import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One tab of [FloatingNavBar]. [icon] / [activeIcon] are widgets so a tab
/// can carry a badge; they inherit the bar's icon colour and size.
class FloatingNavItem {
  const FloatingNavItem({required this.label, required this.icon, Widget? activeIcon}) : activeIcon = activeIcon ?? icon;

  final String label;
  final Widget icon;
  final Widget activeIcon;
}

/// Dark floating pill navigation bar. The selected tab sits in a white
/// circle that slides between tabs. The geometry is concentric: the circle is
/// inset by the same [_inset] on every side, so at the first and last tab it
/// follows the pill's rounded ends exactly.
///
/// Use it with `Scaffold(extendBody: true)` so the content scrolls under the
/// bar; the body then gets the bar's height as bottom padding.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.items, required this.index, required this.onTap});

  final List<FloatingNavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  // Warm camel tan with dark-brown icons; the selected tab sits on a soft
  // light circle.
  static const _bar = Color(0xFFC9A27E);
  static const _icon = Color(0xFF3B2A1C);
  static const _selectedCircle = Color(0x47FFFFFF); // white, 28%
  static const double _height = 66;
  static const double _inset = 7;
  static const double _circle = _height - _inset * 2;
  static const _duration = Duration(milliseconds: 320);
  static const _curve = Curves.easeOutCubic;

  /// Height the bar takes above the bottom safe area; lift floating buttons
  /// by this much so they sit above it.
  static const double clearance = _height + 8 + 4;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: _bar,
            shape: const StadiumBorder(),
            shadows: [
              // Wide, soft ambient shadow plus a tight contact shadow.
              BoxShadow(color: const Color(0xFF6B4A2B).withValues(alpha: 0.22), blurRadius: 28, spreadRadius: -4, offset: const Offset(0, 12)),
              BoxShadow(color: const Color(0xFF6B4A2B).withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: ClipPath(
            clipper: const ShapeBorderClipper(shape: StadiumBorder()),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: _height,
              child: LayoutBuilder(
                builder: (context, box) {
                  final n = items.length;
                  // Centres run from the left cap's centre to the right cap's.
                  final step = n > 1 ? (box.maxWidth - _inset * 2 - _circle) / (n - 1) : 0.0;
                  double left(int i) => _inset + step * i;
                  return Stack(
                    children: [
                      // Faint top highlight, for depth on dark backgrounds.
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: StadiumBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.22))),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: _duration,
                        curve: _curve,
                        left: left(index.clamp(0, n - 1)),
                        top: _inset,
                        width: _circle,
                        height: _circle,
                        child: const DecoratedBox(
                          decoration: ShapeDecoration(color: FloatingNavBar._selectedCircle, shape: CircleBorder()),
                        ),
                      ),
                      for (var i = 0; i < n; i++)
                        Positioned(
                          left: left(i),
                          top: _inset,
                          width: _circle,
                          height: _circle,
                          child: _NavButton(
                            item: items[i],
                            selected: i == index,
                            onTap: () {
                              if (i != index) HapticFeedback.selectionClick();
                              onTap(i);
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Tooltip(
        message: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: TweenAnimationBuilder<Color?>(
              duration: FloatingNavBar._duration,
              curve: FloatingNavBar._curve,
              tween: ColorTween(end: selected ? FloatingNavBar._icon : FloatingNavBar._icon.withValues(alpha: 0.78)),
              builder: (context, color, _) => IconTheme(
                data: IconThemeData(size: 24, color: color),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(selected),
                    child: selected ? item.activeIcon : item.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
