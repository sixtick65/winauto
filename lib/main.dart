import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:winauto/widget/auto_root.dart';
import 'package:winauto/widget/capture_rect.dart';
import 'package:winauto/widget/mouse_tracking.dart';
import 'package:winauto/widget/scan_hp.dart';
import 'package:winauto/widget/search_handle.dart';
import 'package:winauto/widget/test.dart';
import 'package:winauto/widget/test_valuenotifier.dart';

import 'package:window_size/window_size.dart' as window_size;
import 'win32.dart' as win32;
import 'widget/mouse_capture.dart';
import 'package:winauto/util/bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:winauto/provider/provider_main.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 초기 창 크기와 위치 설정
    window_size.setWindowTitle('자동 고인물');
    window_size.setWindowMinSize(const Size(350, 600));
    window_size.setWindowMaxSize(const Size(1920, 1080));

    // 화면 가운데로 위치
    window_size.getScreenList().then((screens) {
      final screen = screens.first;
      const windowWidth = 550.0;
      const windowHeight = 1200.0;
      final left = (screen.frame.width - windowWidth) / 2 + 300;
      final top = (screen.frame.height - windowHeight) / 2 + 300;
      window_size.setWindowFrame(Rect.fromLTWH(left, top, windowWidth, windowHeight));
    });
  }

  // runApp(const MyApp());
  runApp(ProviderScope(child: MyApp())); // 프로바이더스코프로 묶어야 상태참조가 가능함
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final ValueNotifier<int> handle = ValueNotifier(0);
  final ValueNotifier<int> testCount = ValueNotifier(0);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {  
  Uint8List bytes = Uint8List.fromList([]);
  Timer? timer;

  late final SearchHandle searchHandle;
  final ScanHp scanHp = ScanHp();
  final MouseCapture mouseCapture = MouseCapture();
  final MouseTracking mouseTracking = MouseTracking();
  final CaptureRect captureRect = CaptureRect();
  late final AutoRoot autoRoot;
  final TestState testState1 = TestState();
  final TestState testState2 = TestState();
  
  late final TestValuenotifier testValuenotifier1;
  late final TestValuenotifier testValuenotifier2;

  @override
  void initState() {
    super.initState();
    testValuenotifier1 = TestValuenotifier(count: widget.testCount);
    testValuenotifier2 = TestValuenotifier(count: widget.testCount);
    searchHandle = SearchHandle();
    autoRoot = AutoRoot(handle: widget.handle);
    // timer = Timer.periodic(const Duration(milliseconds: 200), (t) => debug(getMousePoint()));
    // searchHandle.handle.addListener((){scanHp.hWnd.state = searchHandle.handle.value;});
    // searchHandle.handle.addListener((){mouseCapture.hWnd.state = searchHandle.handle.value;});
    // searchHandle.handle.addListener((){mouseTracking.hWnd.state = searchHandle.handle.value;});
    // searchHandle.handle.addListener((){captureRect.hWnd.state = searchHandle.handle.value;});
  }

  @override
  Widget build(BuildContext context) { // TODO : 이미지 캡쳐, 저장, 비교, 액션 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              searchHandle,
              const Divider(),
              mouseCapture,
              const Divider(),
              mouseTracking,
              const Divider(),
              scanHp,
              bytes.isEmpty ? SizedBox() : Image.memory(bytes),
              const Divider(),
              captureRect,
              const Divider(),
              autoRoot,
              const Divider(),
              Row(children: [
                testState1, testState2,
              ],),
              Row(children: [
                testValuenotifier1, testValuenotifier2,
              ],)
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // setState(() {
              //   bytes = win32.captureWindow(win32.findWindowHandle('sixtick65'));
              // }); 
              // win32.sendKeyToWindow(3671362, VK_F4);
              // win32.postMouseclick(3671362, 1068, 705);
              win32.sendKeyToForegroundWindow(3671362, VK_F4);
              },
            tooltip: 'test',
            child: const Text('test'),
          ),
          
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


