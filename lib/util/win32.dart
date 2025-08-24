import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';


(int width, int height) getWindowSize(int handle){
  if(handle == 0) return (0, 0);
  final rect = calloc<RECT>();
  GetClientRect(handle, rect);
  final windowWidth = rect.ref.right - rect.ref.left;
  final windowHeight = rect.ref.bottom - rect.ref.top;
  free(rect);
  return (windowWidth, windowHeight);
}