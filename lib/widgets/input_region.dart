import 'package:fl_linux_window_manager/controller/input_region_controller.dart';
import 'package:flutter/cupertino.dart';

class InputRegion extends StatefulWidget {
  final Widget child;
  final bool isNegative;

  const InputRegion({
    required this.child,
    this.isNegative = false,
    super.key,
  });
  const InputRegion.negative({
    super.key,
    required this.child,
  }) : isNegative = true;

  @override
  State<InputRegion> createState() => _InputRegionState();
}

class _InputRegionState extends State<InputRegion> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Add the input region GlobalKey to the controller
    InputRegionController.addKey(
      _key,
      isNegative: widget.isNegative,
    );
  }

  @override
  void didUpdateWidget(covariant InputRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isNegative != widget.isNegative) {
      // Update the key in the controller with the new isNegative value
      InputRegionController.addKey(
        _key,
        isNegative: widget.isNegative,
      );
    }
  }

  @override
  void dispose() {
    /// Remove the input region key from the controller.
    InputRegionController.removeKey(_key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        /// Update the input region when the size changes
        InputRegionController.notifyRegionChange(_key);
        return false;
      },
      child: SizeChangedLayoutNotifier(
        key: _key,
        child: widget.child,
      ),
    );
  }
}
