import 'dart:async';

import 'package:fl_linux_window_manager/controller/focus_grab_controller.dart';
import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';
import 'package:flutter/widgets.dart';

class FocusGrab extends StatefulWidget {
  const FocusGrab({super.key, required this.child, this.callback, this.grabAgain});

  final Widget child;

  /// Called when the focus grab object is cleared
  final VoidCallback? callback;

  final Stream<()>? grabAgain;

  @override
  State<FocusGrab> createState() => FocusGrabState();
}

class FocusGrabState extends State<FocusGrab> {
  FocusGrabRequest? request;
  final controller = FocusGrabController();
  late final StreamSubscription<()> foucsSubscription;
  late final StreamSubscription<()>? widgetSubscription;

  @override
  void initState() {
    super.initState();
    request = controller.requestFocusGrab();
    foucsSubscription = FlLinuxWindowManager.instance.focusGrabCleared.listen((_) {
      request = null;
      widget.callback?.call();
    });
    widgetSubscription = widget.grabAgain?.listen((_) {
      request = controller.requestFocusGrab();
    });
  }

  @override
  void dispose() {
    if (request != null) {
      controller.removeFocusGrab(request!);
    }
    foucsSubscription.cancel();
    widgetSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
