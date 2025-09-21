import 'dart:async';

import 'package:fl_linux_window_manager/controller/focus_grab_controller.dart';
import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';
import 'package:flutter/widgets.dart';

/// {@template request}
/// An active request means that the focus grab is currently active
///
/// An inactive request instead does not means that the focus grab is inactive,
/// instead means that this widget does not need the focus grab anymore
/// {@endtemplate}

class FocusGrabController {
  FocusGrabState? _state;
  FocusGrabController() : _state = null;

  /// Send a request to grab the focus if the FocusGrab widget does not have
  /// an active request
  ///
  /// {@macro request}
  void grabFocus() {
    _state?.requestFocusGrab();
  }

  /// Cancel the request for the focus grab if there is an active request for the grab
  ///
  /// {@macro request}
  void ungrabFocus() {
    _state?.removeFocusGrab();
  }
}

class FocusGrab extends StatefulWidget {
  const FocusGrab({
    super.key,
    required this.child,
    this.callback,
    this.controller,
    this.grabOnInit = true,
  });

  final Widget child;

  /// Called when the focus grab object is cleared
  final VoidCallback? callback;

  final FocusGrabController? controller;

  /// If true will request focus grab on init state
  final bool grabOnInit;

  @override
  State<FocusGrab> createState() => FocusGrabState();
}

class FocusGrabState extends State<FocusGrab> {
  FocusGrabRequest? request;
  final handlerController = FocusGrabHandlerController();
  late final StreamSubscription<()> foucsSubscription;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    if (widget.grabOnInit) {
      requestFocusGrab();
    }
    foucsSubscription = FlLinuxWindowManager.instance.focusGrabCleared.listen((_) {
      if (request != null) {
        removeFocusGrab();
        widget.callback?.call();
      }
    });
  }

  void requestFocusGrab() {
    request ??= handlerController.requestFocusGrab();
  }

  void removeFocusGrab() {
    if (request != null) {
      handlerController.removeFocusGrab(request!);
      request = null;
    }
  }

  @override
  void dispose() {
    removeFocusGrab();
    foucsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
