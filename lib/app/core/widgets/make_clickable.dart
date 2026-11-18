import 'package:flutter/material.dart';

/// A simple reusable widget that makes any child clickable
/// with a ripple and slight scale animation.
class MakeClickable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double pressedScale;
  final Duration duration;
  final Color? rippleColor;

  const MakeClickable({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 120),
    this.rippleColor,
  }) : super(key: key);

  @override
  State<MakeClickable> createState() => _MakeClickableState();
}

class _MakeClickableState extends State<MakeClickable> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) {
      setState(() => _pressed = pressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);

    return AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1.0,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          splashColor: widget.rippleColor ?? Theme.of(context).splashColor,
          onHighlightChanged: _setPressed,
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }
}