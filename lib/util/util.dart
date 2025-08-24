import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

void debug(Object text){
  if(kDebugMode){
    debugPrint(text.toString());
  }
}

class Uint8ListImage{
  Uint8ListImage({required this.uint8list, required this.width, required this.height});
  Uint8List uint8list;
  int width;
  int height;

  Future<RawImage> toRawImage({double scale = 1.0}) async {
    if(uint8list.isEmpty) return RawImage();
    Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(uint8list, width, height, ui.PixelFormat.bgra8888, completer.complete);
    RawImage image = RawImage(image: await completer.future, scale: scale,);
    return image;
  }
}

Future<RawImage> uint8ListToImage(Uint8List bytes, int width, int height) async {
  Completer<ui.Image> completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(bytes, width, height, ui.PixelFormat.bgra8888, completer.complete);
  RawImage image = RawImage(image: await completer.future);
  return image;
}
