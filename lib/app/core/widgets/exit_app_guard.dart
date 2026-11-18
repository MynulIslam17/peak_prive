import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../modules/booking/widgets/action_dialogs.dart';

/// Wrap an app's last screen (the one under everything else) so the system
/// back button asks "Close the app?" instead of closing it straight away.
///
/// If the screen was pushed on top of another one, back just goes back.
/// [onBack] runs first and can take the back press for itself (e.g. return
/// to the first tab); return true when it did.
class ExitAppGuard extends StatefulWidget {
  const ExitAppGuard({super.key, required this.child, this.onBack, this.closeApp});

  final Widget child;
  final bool Function()? onBack;

  /// Injected in tests; closes the app by default.
  final VoidCallback? closeApp;

  @override
  State<ExitAppGuard> createState() => _ExitAppGuardState();
}

class _ExitAppGuardState extends State<ExitAppGuard> {
  bool _asking = false;

  Future<void> _onBack() async {
    if (widget.onBack?.call() ?? false) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    if (_asking) return; // a second back press while the dialog is open
    _asking = true;
    final ok = await confirmBookingAction(
      context,
      title: 'Close the app?',
      message: 'Do you want to close Peak Privee?',
      confirmLabel: 'Close',
      cancelLabel: 'Stay',
      icon: Icons.logout_rounded,
    );
    _asking = false;
    if (ok != null && mounted) (widget.closeApp ?? SystemNavigator.pop)();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: widget.child,
    );
  }
}
