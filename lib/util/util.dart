import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

void debug(Object text){
  if(kDebugMode){
    debugPrint(text.toString());
  }
}

Future<RawImage> uint8ListToImage(Uint8List bytes, int width, int height) async {
  Completer<ui.Image> completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(bytes, width, height, ui.PixelFormat.bgra8888, completer.complete);
  RawImage image = RawImage(image: await completer.future);
  return image;
}
