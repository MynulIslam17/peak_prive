import 'package:flutter/material.dart';

/// Keeps bottom-navigation tabs alive. A tab is built the first time it is
/// shown and then kept (scroll position, loaded data), so switching tabs is
/// instant instead of rebuilding the screen and showing its loader again.
///
/// [onRevisit] runs when the user comes back to a tab that was already built:
/// use it for a quiet background refresh (no loader).
class LazyTabStack extends StatefulWidget {
  const LazyTabStack({super.key, required this.index, required this.children, this.onRevisit});

  final int index;
  final List<Widget> children;
  final ValueChanged<int>? onRevisit;

  @override
  State<LazyTabStack> createState() => _LazyTabStackState();
}

class _LazyTabStackState extends State<LazyTabStack> {
  late final Set<int> _built = {widget.index};

  @override
  void didUpdateWidget(LazyTabStack old) {
    super.didUpdateWidget(old);
    final i = widget.index;
    if (i == old.index) return;
    final revisit = _built.contains(i);
    _built.add(i);
    // After the frame: the refresh calls update() on controllers that this
    // build depends on.
    if (revisit && widget.onRevisit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onRevisit!(i);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          // Hidden tabs don't tick animations or take focus.
          TickerMode(
            enabled: i == widget.index,
            child: _built.contains(i) ? widget.children[i] : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
