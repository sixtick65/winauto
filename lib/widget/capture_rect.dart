import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winauto/provider/provider_main.dart';
import 'package:winauto/util/bloc.dart';
import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:win32/win32.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class CaptureRect extends ConsumerStatefulWidget {
  const CaptureRect({super.key});

  @override
  ConsumerState<CaptureRect> createState() => _CaptureRectState();
}

class _CaptureRectState extends ConsumerState<CaptureRect> {

  
  _Interval interval = _Interval();
  _SwitchCapture switchCapture = _SwitchCapture();
  _Image image = _Image();

  

  @override
  void initState() {
    super.initState();
    switchCapture.toggle.onChanged((handler)=> image.toggle.state = handler, name:  '_CaptureRectState initState');
    // widget.hWnd.onChanged((handler) => image.hWnd.state = handler, name: '_CaptureRectState initState');
  }

  @override
  Widget build(BuildContext context) {

    // 화면, 인터벌, 캡쳐스위치, 재생스위치
    return Column(
      children: [
        image,
        Row(
          children: [
            switchCapture,
          ],
        ),
      ],
    );
  }

  
}

class _Image extends ConsumerStatefulWidget {

  final Bloc<int> interval = Bloc(100);
  final Bloc<bool> toggle = Bloc(false);

  @override
  ConsumerState<_Image> createState() => __ImageState();
}

class __ImageState extends ConsumerState<_Image> {

  RawImage rawImage = RawImage();
  Timer? timer;

  void getImage(int hWnd, int x, int y, int width, int height){
    final bytes = captureRect(hWnd, x, y, width, height);
    Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(bytes, width, height, ui.PixelFormat.bgra8888, completer.complete);
    completer.future.then((onValue){
      setState(() {
        rawImage = RawImage(image: onValue, scale: 1,);  
      });
      
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    widget.toggle.onChanged((handler){
      debug(handler);
      if(handler){
        debug('in ${ref.read(providerHandle)}');
        if(ref.read(providerHandle) == 0)return;
        timer = Timer.periodic(Duration(milliseconds: widget.interval.state), (callback){
          getImage(ref.read(providerHandle), 600, 300, 100, 100);
        });
      }else{
        timer?.cancel();
      }
    },name:  '__ImageState initState');
  }

  @override
  Widget build(BuildContext context) {
    return rawImage;
  }
}




class _Interval extends StatefulWidget {

  // Bloc<int> hWnd = Bloc(0);
  final Bloc<int> interval = Bloc(100);

  @override
  State<_Interval> createState() => __IntervalState();
}

class __IntervalState extends State<_Interval> {
  TextEditingController controller = TextEditingController(text: "100");

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
      maxLength: 4,
      onChanged: (value) => widget.interval.state = int.parse(value),
    );
  }
}

class _SwitchCapture extends StatefulWidget {

  final Bloc<bool> toggle = Bloc(false);

  @override
  State<_SwitchCapture> createState() => __SwitchCaptureState();
}

class __SwitchCaptureState extends State<_SwitchCapture> {
  @override
  Widget build(BuildContext context) {
    debug('build _SwitchCapture');
    return Switch(
      value: widget.toggle.state, 
      onChanged: (onChanged){
        setState(() {
          widget.toggle.state = onChanged;
        });
      }
      );
  }
}


