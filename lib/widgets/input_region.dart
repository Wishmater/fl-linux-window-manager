import 'package:fl_linux_window_manager/controller/input_region_controller.dart';
import 'package:flutter/cupertino.dart';

class InputRegion extends StatefulWidget {
  final Widget child;
  final bool active;
  final bool isNegative;

  const InputRegion({
    required this.child,
    this.active = true,
    this.isNegative = false,
    super.key,
  });
  const InputRegion.negative({
    required this.child,
    this.active = true,
    super.key,
  }) : isNegative = true;

  @override
  State<InputRegion> createState() => _InputRegionState();
}

class _InputRegionState extends State<InputRegion> {
  // TODO: 1 don't use a global key, instead pass a callback into the controller that can get size from context
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Add the input region GlobalKey to the controller
    if (widget.active) {
      InputRegionController.addKey(
        _key,
        isNegative: widget.isNegative,
      );
      scheduleCheckForPositionOrSizeChanges();
    }
  }

  @override
  void didUpdateWidget(covariant InputRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        InputRegionController.addKey(
          _key,
          isNegative: widget.isNegative,
        );
      } else {
        InputRegionController.removeKey(_key);
      }
    } else if (widget.active) {
      if (oldWidget.isNegative != widget.isNegative) {
        // Update the key in the controller with the new isNegative value
        InputRegionController.addKey(
          _key,
          isNegative: widget.isNegative,
        );
      }
    }
  }

  @override
  void dispose() {
    /// Remove the input region key from the controller.
    InputRegionController.removeKey(_key);
    super.dispose();
  }

  void scheduleCheckForPositionOrSizeChanges() {
    WidgetsBinding.instance.addPostFrameCallback(checkForPositionOrSizeChanges);
  }

  Size? previousSize;
  Offset? previousPosition;
  void checkForPositionOrSizeChanges(_) {
    if (!mounted) return;
    try {
      RenderBox box = context.findRenderObject()! as RenderBox;
      final size = box.size;
      final position = box.localToGlobal(Offset.zero);
      if (previousSize != null && previousPosition != null) {
        if (previousSize != size || previousPosition != position) {
          /// Update the input region when the size changes
          InputRegionController.notifyRegionChange(_key);
        }
      }
      previousSize = size;
      previousPosition = position;
    } catch (_) {}
    scheduleCheckForPositionOrSizeChanges();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
