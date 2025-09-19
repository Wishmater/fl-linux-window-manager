
import 'dart:async';

import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';

int _id = 0;
int get _newID {
  _id+=1;
  return _id;
}

typedef FocusGrabRequest = int;

/// WARNING Only works for main window
class FocusGrabController {

  static final Set<FocusGrabRequest> _request = {};  

  FocusGrabRequest requestFocusGrab() {
    final id = _newID;
    _request.add(id);
    if (_request.length == 1) {
      _addSurface();
    }
    return id;
  }

  void removeFocusGrab(FocusGrabRequest request) {
    _request.remove(request);
    if (_request.isEmpty) {
      _removeSurface();
    }
  }

  Future<void> _addSurface() async {
    await FlLinuxWindowManager.instance.focusGrab();
  }

  Future<void> _removeSurface() async {
    FlLinuxWindowManager.instance.focusUngrab();
  }
}