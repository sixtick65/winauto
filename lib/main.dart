import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:winauto/widget/scan_hp.dart';

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

class _MyHomePageState extends State<MyHomePage> {    // TODO : 마우스 포인터 위치색상 구현중. 새로 위젯 만들자
  int _counter = 0;
  Uint8List bytes = Uint8List.fromList([]);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // timer = Timer.periodic(const Duration(milliseconds: 200), (t) => debug(getMousePoint()));
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              MouseCapture(),
              Divider(),
              ScanHp(hWnd:  3671362),
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
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void debug(Object text){
  win32.debug(text);
}
