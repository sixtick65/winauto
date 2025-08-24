import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:flutter/foundation.dart';

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


(int width, int height) getWindowSize(int handle){
  if(handle == 0) return (0, 0);
  final rect = calloc<RECT>();
  GetClientRect(handle, rect);
  final windowWidth = rect.ref.right - rect.ref.left;
  final windowHeight = rect.ref.bottom - rect.ref.top;
  free(rect);
  return (windowWidth, windowHeight);
}

Uint8List captureRect(int hWnd, int x, int y, int width, int height) {

  final hdcScreen = GetDC(hWnd);
  final hdcMem = CreateCompatibleDC(hdcScreen);

  final hBitmap = CreateCompatibleBitmap(hdcScreen, width, height);
  final oldObj = SelectObject(hdcMem, hBitmap);

  // 화면을 메모리 DC로 복사
  BitBlt(hdcMem, 0, 0, width, height, hdcScreen, x, y, SRCCOPY);

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
  GetDIBits(hdcMem, hBitmap, 0, height, bitmapData, bmi, DIB_RGB_COLORS);

  // GetDIBits로 얻은 데이터를 Dart의 Uint8List로 변환
  final pixelData = bitmapData.asTypedList(bitmapSize);

  // 리소스 해제
  SelectObject(hdcMem, oldObj);
  DeleteObject(hBitmap);
  DeleteDC(hdcMem);
  ReleaseDC(hWnd, hdcScreen);

  return pixelData;
}