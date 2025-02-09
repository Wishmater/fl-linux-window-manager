import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_linux_window_manager/fl_linux_window_manager_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlLinuxWindowManager platform = MethodChannelFlLinuxWindowManager();
  const MethodChannel channel = MethodChannel('fl_linux_window_manager');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
