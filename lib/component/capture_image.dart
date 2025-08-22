import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart'; 
import 'package:winauto/util/bloc.dart';
import 'package:winauto/win32.dart';


class CaptureImage extends StatefulWidget {
  CaptureImage({super.key});
  // CaptureImage({super.key}){
  //   hWnd.onChanged((handler) => debug('CaptureImage hWnd onChanged : $handler ${hWnd.state}'), 'CaptureImage');
  // }

  final Bloc<int> hWnd = Bloc(0);
  final Bloc<int> x = Bloc(0);
  final Bloc<int> y = Bloc(0);
  final Bloc<int> width = Bloc(10);
  final Bloc<int> height = Bloc(10);
  final Bloc<int> interval = Bloc(100);
  final Bloc<bool> onOff = Bloc(false);

  @override
  State<CaptureImage> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage> {

  RawImage image = RawImage();
  Timer? timer;
  int handle = 0;

  void getImage(int hWnd, int x, int y, int width, int height){
    final bytes = captureRect(hWnd, x, y, width, height);
    Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(bytes, width, height, ui.PixelFormat.bgra8888, completer.complete);
    completer.future.then((onValue){
      setState(() {
        image = RawImage(image: onValue, scale: 1,);  
      });
      
    });
  }

  @override
  void initState() {
    super.initState();
    // widget.hWnd.onChanged((handler) => debug('widget.hWnd.onChanged $handler'), name:  '_CaptureImageState initState');

    widget.hWnd.onChanged((handler) => debug('왜 안걸리는거냐???'));
    widget.onOff.onChanged((handler){
      if(handler){
        if(widget.hWnd.state == 0){
          debug('핸들이 없습니다. ${widget.hWnd.state}');
          return;
        }
        debug('on');
        timer = Timer.periodic(Duration(milliseconds: widget.interval.state), (callback){
          getImage(widget.hWnd.state, widget.x.state, widget.y.state, widget.width.state, widget.height.state);
        });
      }else{
        debug('off');
        timer?.cancel();
      }
    }, name:  '_CaptureImageState initState');
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return image;
  }
}