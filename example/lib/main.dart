import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';
import 'package:fl_linux_window_manager/models/layer.dart';
import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

MethodChannel channel = MethodChannel('shared_example');
List<String> arggg = [];

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  FlLinuxWindowManager.instance.enableTransparency();
  FlLinuxWindowManager.instance.setLayer(WindowLayer.top);
  FlLinuxWindowManager.instance.setSize(width: 800, height: 600);
  FlLinuxWindowManager.instance.setTitle(title: "sample");

  print("Args received: $args");
  arggg.addAll(args);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _platformVersion = 'Unknown';
  bool passingThrough = false;

  @override
  void initState() {
    super.initState();

    channel.setMethodCallHandler((call) async {
      print("Received call in main window: ${call.method}, Args: $arggg");
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget result = MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                onPressed: () {
                  FlLinuxWindowManager.instance.createWindow(
                    windowId: "new_window",
                    title: "Sample",
                    width: 500,
                    height: 300,
                    isLayer: true,
                    args: ["--class=sample", "--name=sample"],
                  );
                },
                child: const Text('Create Window'),
              ),
              ElevatedButton(
                  onPressed: () {
                    FlLinuxWindowManager.instance
                        .hideWindow(windowId: "new_window");
                  },
                  child: const Text('Hide Window')),
              ElevatedButton(
                  onPressed: () {
                    FlLinuxWindowManager.instance
                        .showWindow(windowId: "new_window");
                  },
                  child: const Text('Show Window')),
              ElevatedButton(
                  onPressed: () async {
                    await FlLinuxWindowManager.instance
                        .createSharedMethodChannel(
                            channelName: "shared_example",
                            shareWithWindowId: "main",
                            windowId: "new_window");

                    channel.invokeMethod("SampleMethodName");
                  },
                  child: Text("Create shared message")),
              InputRegion(
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      passingThrough = !passingThrough;
                    });
                    print('set passingThrough to $passingThrough');
                  },
                  child: Text("Input Region"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (passingThrough) {
      print('building with negative input region');
      result = InputRegion.negative(
        key: ValueKey(passingThrough),
        child: result,
      );
    } else {
      print('building with positive input region');
      result = InputRegion(
        key: ValueKey(passingThrough),
        child: result,
      );
    }
    return result;
  }
}
