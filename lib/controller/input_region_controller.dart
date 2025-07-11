import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';
import 'package:flutter/cupertino.dart';

class InputRegionController {
  /// A list of global keys attached to the InputRegion widgets.
  ///
  /// The widgets attched to this key are representing positive input regions,
  /// that is we should enable inputs in this region.
  static final Set<GlobalKey> _positiveRegionKeys = {};

  /// A list of global keys attached to the InputRegion widgets.
  ///
  /// The widgets attched to this key are representing negative input regions,
  /// that is we should disable inputs in this region.
  static final Set<GlobalKey> _negativeRegionKeys = {};

  /// Adds a global key to the list of keys.
  static void addKey(
    GlobalKey key, {
    bool isNegative = false,
  }) {
    if (isNegative) {
      _positiveRegionKeys.remove(key); // just in case a key switches isNegative
      _negativeRegionKeys.add(key);
    } else {
      _negativeRegionKeys.remove(key); // just in case a key switches isNegative
      _positiveRegionKeys.add(key);
    }
    _ensureUpdateScheduled();
  }

  /// Removes a global key from the list of keys.
  static void removeKey(GlobalKey key) {
    _negativeRegionKeys.remove(key);
    _positiveRegionKeys.remove(key);
    _ensureUpdateScheduled();
  }

  static void notifyRegionChange(GlobalKey key) {
    _ensureUpdateScheduled();
  }

  static void notifyConfigChange() {
    _ensureUpdateScheduled();
  }

  static bool _isUpdateScheduled = false;
  static void _ensureUpdateScheduled() {
    if (_isUpdateScheduled) return;
    _isUpdateScheduled = true;
    // Any call to refreshInputRegion must be delayed a frame to ensure size and position
    // are calculated correctly. This also ensure it is called only once per frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshInputRegion();
      _isUpdateScheduled = false;
    });
  }

  /// This will be called whenever there is a change in the InputRegion widget.
  /// like size change, position change, etc.
  ///
  /// This will change the native window input region to the new input region.
  static void _refreshInputRegion() {
    /// Sort the keys based on the depth of the widget.
    final List<({GlobalKey key, bool isNegative})> keys = [
      ..._positiveRegionKeys.map((key) => (key: key, isNegative: false)),
      ..._negativeRegionKeys.map((key) => (key: key, isNegative: true)),
    ];
    keys.sort((a, b) => _findDepth(a.key).compareTo(_findDepth(b.key)));

    for (final item in keys) {
      /// Get the size and position of the widget.
      final RenderBox renderBox =
          item.key.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);

      /// Set the input region to the size and position of the widget.
      final Rect region = Rect.fromLTWH(
        position.dx,
        position.dy,
        size.width,
        size.height,
      );

      if (item.isNegative) {
        FlLinuxWindowManager.instance.subtractInputRegion(inputRegion: region);
      } else {
        FlLinuxWindowManager.instance.addInputRegion(inputRegion: region);
      }
    }
  }

  /// Find the depth of the InputRegion widget with the given key.
  static int _findDepth(GlobalKey key) {
    /// If the key is not attached to any widget, then return -1.
    if (key.currentContext == null || !key.currentContext!.mounted) {
      return -1;
    }

    Element element = key.currentContext! as Element;
    return element.depth;
  }
}
