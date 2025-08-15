import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:winauto/widget/scan_hp.dart';
import 'package:winauto/widget/search_handle.dart';

import 'package:window_size/window_size.dart' as window_size;
import 'win32.dart' as win32;
import 'widget/mouse_capture.dart';

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

  runApp(const MyApp());
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {  
  Uint8List bytes = Uint8List.fromList([]);
  Timer? timer;

  final SearchHandle searchHandle = SearchHandle();
  final ScanHp scanHp = ScanHp();
  final MouseCapture mouseCapture = MouseCapture();

  @override
  void initState() {
    super.initState();
    // timer = Timer.periodic(const Duration(milliseconds: 200), (t) => debug(getMousePoint()));
    searchHandle.handle.onChanged((value){scanHp.hWnd.state = value;}, 'scanHp');
    searchHandle.handle.onChanged((value){mouseCapture.hWnd.state = value;}, 'mouseCapture');
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
              scanHp,
              bytes.isEmpty ? SizedBox() : Image.memory(bytes),
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

void debug(Object text){
  win32.debug(text);
}
