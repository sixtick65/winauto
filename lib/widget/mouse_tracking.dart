
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:winauto/util/bloc.dart';
import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:win32/win32.dart';

class Point{
  int x = 0;
  int y= 0;
}

class MouseTracking extends StatefulWidget {
  MouseTracking({super.key});

  Bloc<int> hWnd = Bloc(NULL);

  @override
  State<MouseTracking> createState() => _MouseTrackingState();
}

class _MouseTrackingState extends State<MouseTracking> {
  (int, int, int, int, int, Uint8List) point = (0,0,0,0,0,Uint8List(0));
  bool isCapture = false;
  Timer? timer;
  // int hWnd = NULL;
  Widget margin1 = const SizedBox(width: 20,);
  RawImage rawImage = RawImage(width: 50, height: 50,);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            rawImage,
            // Text("${point.$1}, ${point.$2}, ${point.$3}, ${point.$4}, ${point.$5}, ${point.$6.length}"),
            Column(children: [
              Text("${point.$1}, ${point.$2}"),
              Text("${point.$3}, ${point.$4}, ${point.$5}"),
            ],),
            
            Switch(
            value: isCapture, 
            onChanged: (onChanged){
              // 타이머 온 오프 
              setState(() {
                isCapture = onChanged;
              });
              if(isCapture){
                timer = Timer.periodic(const Duration(milliseconds: 200), (callback){
                  setState(() {
                    // point = getMousePoint(hWnd);
                    point = getRectColor(10, 10, widget.hWnd.state);
                    // image = Image.memory(point.$6, scale: 0.1, width: 100, height: 100,);
                    Completer<ui.Image> completer = Completer<ui.Image>();
                    ui.decodeImageFromPixels(point.$6, 10, 10, ui.PixelFormat.bgra8888, completer.complete);
                    completer.future.then((onValue) => rawImage = RawImage(image: onValue, scale: 0.2,));
                  });
                });
              }else{
                timer?.cancel();
              }
              debug(onChanged);}),
            
          ],
        ),
      ],
    );
  }
}


