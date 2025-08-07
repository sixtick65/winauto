import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Image.memory(bytes),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              findWindowHandle('sixtick65');
              setState(() {
                bytes = captureWindow(result);
              }); 
              getMousePoint();
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
  if(kDebugMode){
    debugPrint(text.toString());
  }
}

String findName = '';
int result = 0;

void findWindowHandle(String name){
  findName = name;

  EnumWindows(
    // Pointer.fromFunction<EnumWindowsProc>(_enumWindowsCallback, 0),
    Pointer.fromFunction<WNDENUMPROC>(_enumWindowsCallback, 0),  // 콜백을 보낼때 콜백은 최상위 함수여야 한다. 
    0,
  );
}

int _enumWindowsCallback(int hWnd, int lParam) {
    final windowProcessId = calloc<Uint32>();
    GetWindowThreadProcessId(hWnd, windowProcessId);
    final titleBuffer = calloc<Uint16>(256);   //
    final titleLength = GetWindowText(hWnd, titleBuffer.cast<Utf16>(), 256);
    if(titleLength == 0){
      free(titleBuffer);
      free(windowProcessId);
      return 1; // continue
    }
    final title = titleBuffer.cast<Utf16>().toDartString();
    if(title.startsWith(findName)){
      debug("$findName handle! : $hWnd");
      free(titleBuffer);
      free(windowProcessId);
      result = hWnd;
      return 0; // break;
    }

    free(titleBuffer);
    free(windowProcessId);
    return 1; // for
  }


Uint8List captureWindow(int hWnd) {
  // 1. 창의 DC 가져오기 device context
  final hdcScreen = GetDC(hWnd); // 또는 GetWindowDC(hWnd) : 타이틀 테두리 포함

  // 2. 호환 DC 생성
  final hdcMemDC = CreateCompatibleDC(hdcScreen);

  // 3. 창 크기 얻기
  final rect = calloc<RECT>();
  GetClientRect(hWnd, rect);
  debug("x : ${rect.ref.left}, y : ${rect.ref.top}"); // 0, 0
  final width = rect.ref.right - rect.ref.left;
  final height = rect.ref.bottom - rect.ref.top;
  free(rect);
  debug("width : $width, height : $height"); // 1323, 763

  // 4. 호환 비트맵 생성 및 선택
  final hBitmap = CreateCompatibleBitmap(hdcScreen, width, height);
  SelectObject(hdcMemDC, hBitmap);

  // 5. 화면 DC 내용을 메모리 DC로 복사
  BitBlt(hdcMemDC, 0, 0, width, height, hdcScreen, 0, 0, SRCCOPY);

  // 6. 비트맵 정보 구조체 준비
  final bmi = calloc<BITMAPINFO>();
  bmi.ref.bmiHeader.biSize = sizeOf<BITMAPINFOHEADER>();
  bmi.ref.bmiHeader.biWidth = width;
  bmi.ref.bmiHeader.biHeight = -height; // top-down 이미지
  bmi.ref.bmiHeader.biPlanes = 1;
  bmi.ref.bmiHeader.biBitCount = 32; // 또는 24
  bmi.ref.bmiHeader.biCompression = BI_RGB;

  // 7. 비트 데이터 추출
  final bitmapSize = width * height * 4; // 32비트의 경우
  final bitmapData = calloc<Uint8>(bitmapSize);
  GetDIBits(hdcMemDC, hBitmap, 0, height, bitmapData, bmi, DIB_RGB_COLORS);
  

  // // 8. 이미지 파일로 저장 (BMP 예시)
  // final bmpFile = File('captured_window.bmp');
  // final bytes = generateBmpHeader(width, height, bitmapData.asTypedList(bitmapSize));

  // bmpFile.writeAsBytesSync(bytes);
  // print('창 화면을 captured_window.bmp로 저장했습니다.');

  // GetDIBits로 얻은 데이터를 Dart의 Uint8List로 변환
  final pixelData = bitmapData.asTypedList(bitmapSize);
  
  // win32 API에서 가져온 비트맵은 일반적으로 BGR 순서입니다.
  // Dart의 image 패키지는 RGB를 기대하므로 순서를 바꿔줘야 합니다.
  final img.Image image = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: pixelData.buffer,
    order: img.ChannelOrder.bgra, // BGR-A 순서로 데이터 처리
  );
  
  // image 패키지를 사용하여 PNG로 인코딩
  final Uint8List pngBytes = img.encodePng(image);
  
  free(bmi);
  free(bitmapData);
  // 9. 리소스 해제
  DeleteObject(hBitmap);
  DeleteDC(hdcMemDC);
  ReleaseDC(hWnd, hdcScreen); // GetDC로 얻었으면 ReleaseDC 사용

  return pngBytes;
}

(int, int, int, int, int) getMousePoint(){
  final point = calloc<POINT>();
  int res = GetCursorPos(point);
  // debug(res);
  final x = point.ref.x;
  final y = point.ref.y;
  // debug("$x, $y");

  // 창의 DC 가져오기
  final hdc = GetDC(NULL);
  // GetPixel을 사용해 픽셀 색상 값 얻기
  final bgrColor = GetPixel(hdc, x, y);
  // debug("color : $bgrColor");
  final b = (bgrColor >> 16) & 0xFF;
  final g = (bgrColor >> 8) & 0xFF;
  final r = bgrColor & 0xFF;

  // debug('색상 정보 (RGB): ($r, $g, $b)');
  // debug((0,0).runtimeType.toString());
  free(point);
  return (x, y, r, g, b);
}

