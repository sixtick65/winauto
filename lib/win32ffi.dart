import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

final _hWndResult = calloc<IntPtr>();
final _processId = GetCurrentProcessId();

/// EnumWindows API에 전달될 콜백 함수입니다.
int _enumWindowsCallback(int hWnd, int lParam) {
  final windowProcessId = calloc<Uint32>();
  GetWindowThreadProcessId(hWnd, windowProcessId);

  // if (windowProcessId.value == _processId) {
    // UTF-16 문자열을 담을 메모리 버퍼를 할당합니다.
    // SizedNativeType에 해당하는 Uint16을 사용해야 합니다.
    final  titleBuffer = calloc<Uint16>(256);   //
    
    // GetWindowText 호출 시에는 Uint16 포인터를 전달해도 자동으로 처리됩니다.
    final titleLength = GetWindowText(hWnd, titleBuffer.cast<Utf16>(), 256);

    // if (titleLength > 0) {
      // print("titleBuffer : ${titleBuffer.cast<Utf16>().toDartString()}");

      _hWndResult.value = hWnd;
      // free(titleBuffer);
      // free(windowProcessId);
      // return 0;
    // }
    final title = titleBuffer.cast<Utf16>().toDartString();
    if(title.startsWith('sixtick65')){
      print("sixtick65 handle! : $hWnd");
    }
    free(titleBuffer);
  // }
  free(windowProcessId);
  return 1;
}

/// 현재 프로세스의 메인 창 핸들(HWND)을 찾습니다.
int findMainWindowHandle() {
  EnumWindows(
    Pointer.fromFunction<EnumWindowsProc>(_enumWindowsCallback, 0),
    0,
  );
  
  final hWnd = _hWndResult.value;
  free(_hWndResult);
  return hWnd;
}

void main() {
  final hWnd = findMainWindowHandle();
  if (hWnd != 0) {
    print('현재 프로세스의 창 핸들(HWND): 0x${hWnd.toRadixString(16)}');
  } else {
    print('창 핸들을 찾을 수 없습니다.');
  }
}