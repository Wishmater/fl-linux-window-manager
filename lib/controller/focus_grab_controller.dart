
import 'dart:async';

import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';

int _id = 0;
int get _newID {
  _id+=1;
  return _id;
}

typedef FocusGrabRequest = int;

/// WARNING Only works for main window
class FocusGrabHandlerController {

  static final Set<FocusGrabRequest> _request = {};  
  static bool _withFocus = false;

  FocusGrabRequest requestFocusGrab() {
    final id = _newID;
    _request.add(id);
    if (!_withFocus) {
      _addSurface();
    }
    return id;
  }

  void removeFocusGrab(FocusGrabRequest request) {
    _request.remove(request);
    if (_request.isEmpty) {
      // delay _removeSurface to allow rapid remove/add focus grab requests
      // and not call that many times the native code
      Future.delayed(Duration(milliseconds: 50), () {
        if (_request.isEmpty && _withFocus) _removeSurface();
      });
    }
  }

  Future<void> _addSurface() async {
    await FlLinuxWindowManager.instance.focusGrab();
    _withFocus = true;
  }

  Future<void> _removeSurface() async {
    await FlLinuxWindowManager.instance.focusUngrab();
    _withFocus = false;
  }
}