import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';


void debug(Object text){
  if(kDebugMode){
    debugPrint(text.toString());
  }
}

String findName = '';
int result = 0;

int findWindowHandle(String name){
  findName = name;

  EnumWindows(
    // Pointer.fromFunction<EnumWindowsProc>(_enumWindowsCallback, 0),
    Pointer.fromFunction<WNDENUMPROC>(_enumWindowsCallback, 0),  // 콜백을 보낼때 콜백은 최상위 함수여야 한다. 
    0,
  );

  return result;
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

/// x, y, r, g, b
(int, int, int, int, int) getMousePoint(int hWnd){
  final point = calloc<POINT>();
  GetCursorPos(point);

  // final x = point.ref.x;
  // final y = point.ref.y;

  // 창의 DC 가져오기
  final hdc = GetDC(hWnd);

  // int targetX = x;
  // int targetY = y;

  if (hWnd != NULL) {
    // 화면 좌표 → 창 내부 좌표 변환
    ScreenToClient(hWnd, point);
    // targetX = point.ref.x;
    // targetY = point.ref.y;
  }

  final bgrColor = GetPixel(hdc, point.ref.x, point.ref.y);
  
  final b = (bgrColor >> 16) & 0xFF;
  final g = (bgrColor >> 8) & 0xFF;
  final r = bgrColor & 0xFF;

  free(point);
  ReleaseDC(hWnd, hdc); // ★ 반드시 반환
  return (point.ref.x, point.ref.y, r, g, b);
}

(int, int, int) getColor(int hWnd, int x, int y){
  // final point = calloc<POINT>();
  // point.ref.x = x;
  // point.ref.y = y;
  // GetCursorPos(point); // 스크린 좌표

  // int screenX = point.ref.x;
  // int screenY = point.ref.y;

  // int targetX = screenX;
  // int targetY = screenY;

  final hdcScreen = GetDC(hWnd);
  final hdcMem = CreateCompatibleDC(hdcScreen);

  final rect = calloc<RECT>();
  // if (hWnd != NULL) {
  //   // 스크린 좌표 → 창 클라이언트 좌표
  //   ScreenToClient(hWnd, point);
  //   targetX = point.ref.x;
  //   targetY = point.ref.y;

    GetClientRect(hWnd, rect);
  // } else {
  //   // 화면 전체 DC
  //   rect.ref.left = 0;
  //   rect.ref.top = 0;
  //   rect.ref.right = GetSystemMetrics(SM_CXSCREEN);
  //   rect.ref.bottom = GetSystemMetrics(SM_CYSCREEN);
  // }

  final width = rect.ref.right - rect.ref.left;
  final height = rect.ref.bottom - rect.ref.top;

  final hBitmap = CreateCompatibleBitmap(hdcScreen, width, height);
  final oldObj = SelectObject(hdcMem, hBitmap);

  // 화면을 메모리 DC로 복사
  BitBlt(hdcMem, 0, 0, width, height, hdcScreen, 0, 0, SRCCOPY);

  final color = GetPixel(hdcMem, x, y);

  final r = color & 0xFF;
  final g = (color >> 8) & 0xFF;
  final b = (color >> 16) & 0xFF;

  // 리소스 해제
  SelectObject(hdcMem, oldObj);
  DeleteObject(hBitmap);
  DeleteDC(hdcMem);
  ReleaseDC(hWnd, hdcScreen);
  free(rect);
  // free(point);

  return (r, g, b);
}

/// 마우스 위치 기준 픽셀 색상
/// hWnd: 창 핸들, NULL이면 화면 전체 기준
(int screenX, int screenY, int r, int g, int b) getPixelColor([int hWnd = NULL]) {
  final point = calloc<POINT>();
  GetCursorPos(point); // 스크린 좌표

  int screenX = point.ref.x;
  int screenY = point.ref.y;

  int targetX = screenX;
  int targetY = screenY;

  final hdcScreen = GetDC(hWnd);
  final hdcMem = CreateCompatibleDC(hdcScreen);

  final rect = calloc<RECT>();
  if (hWnd != NULL) {
    // 스크린 좌표 → 창 클라이언트 좌표
    ScreenToClient(hWnd, point);
    targetX = point.ref.x;
    targetY = point.ref.y;

    GetClientRect(hWnd, rect);
  } else {
    // 화면 전체 DC
    rect.ref.left = 0;
    rect.ref.top = 0;
    rect.ref.right = GetSystemMetrics(SM_CXSCREEN);
    rect.ref.bottom = GetSystemMetrics(SM_CYSCREEN);
  }

  final width = rect.ref.right - rect.ref.left;
  final height = rect.ref.bottom - rect.ref.top;

  final hBitmap = CreateCompatibleBitmap(hdcScreen, width, height);
  final oldObj = SelectObject(hdcMem, hBitmap);

  // 화면을 메모리 DC로 복사
  BitBlt(hdcMem, 0, 0, width, height, hdcScreen, 0, 0, SRCCOPY);

  final color = GetPixel(hdcMem, targetX, targetY);

  final r = color & 0xFF;
  final g = (color >> 8) & 0xFF;
  final b = (color >> 16) & 0xFF;

  // 리소스 해제
  SelectObject(hdcMem, oldObj);
  DeleteObject(hBitmap);
  DeleteDC(hdcMem);
  ReleaseDC(hWnd, hdcScreen);
  free(rect);
  free(point);

  return (targetX, targetY, r, g, b);
}

void sendKeyToWindow(int hWnd, int vkCode) {
  // 키 누름
  SendMessage(hWnd, WM_KEYDOWN, vkCode, 0);
  // 키 뗌
  SendMessage(hWnd, WM_KEYUP, vkCode, 0);
}

typedef KeybdEventC = Void Function(Uint8 bVk, Uint8 bScan, Uint32 dwFlags, IntPtr dwExtraInfo);
typedef KeybdEventDart = void Function(int bVk, int bScan, int dwFlags, int dwExtraInfo);
final user32 = DynamicLibrary.open('user32.dll');

final keybd_event = user32
    .lookupFunction<KeybdEventC, KeybdEventDart>('keybd_event');

void sendKeyToForegroundWindow(int hWnd, int vkCode) {
  final currentThreadId = GetCurrentThreadId();
  final targetThreadId = GetWindowThreadProcessId(hWnd, nullptr);

  // 현재 스레드와 대상 창 스레드 입력 연결
  AttachThreadInput(currentThreadId, targetThreadId, TRUE);

  // 창 활성화
  SetForegroundWindow(hWnd);

  // 키 누름
  keybd_event(vkCode, 0, 0, 0);

  // 키 뗌
  keybd_event(vkCode, 0, KEYEVENTF_KEYUP, 0);

  // 입력 연결 해제
  AttachThreadInput(currentThreadId, targetThreadId, FALSE);
}

const MK_LBUTTON = 0x0001;
const MK_RBUTTON = 0x0002;
const MK_SHIFT   = 0x0004;
const MK_CONTROL = 0x0008;

void postMouseclick(int hWnd, int x, int y){
  // 창 좌표에 상대적 위치
  final lParam = (y << 16) | x; // 상위 16bit = y, 하위 16bit = x

  // 마우스 버튼 누름
  debug(PostMessage(hWnd, WM_LBUTTONDOWN, MK_LBUTTON, lParam));
  // 마우스 버튼 뗌
  debug(PostMessage(hWnd, WM_LBUTTONUP, 0, lParam));
}