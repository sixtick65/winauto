import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winauto/component/slider_button.dart';
import 'package:winauto/provider/provider_main.dart';
import 'package:winauto/util/bloc.dart';
import 'package:winauto/util/win32.dart';
import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:win32/win32.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:winauto/component/output_line.dart';

final providerWindowSize = Provider<(int,int)>((ref) {
  final handle = ref.watch(providerHandle);
  return getWindowSize(handle);
});

final providerMaxX = StateProvider<double>((ref){
  final size = ref.watch(providerWindowSize);
  return size.$1.toDouble();
});

final providerMaxY = StateProvider<double>((ref){
  final size = ref.watch(providerWindowSize);
  return size.$2.toDouble();
});

class CaptureRect extends ConsumerStatefulWidget {
  CaptureRect({super.key});
  
  final x = StateProvider<double>((ref) => 0.0,);
  final y = StateProvider<double>((ref) => 0.0,);

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
    // ref.listenManual(providerHandle, (prev, next){
    //   final temp = getWindowSize(next);
    //   ref.read(widget.x.notifier).state = temp.$1.toDouble();
    //   ref.read(widget.y.notifier).state = temp.$2.toDouble();
    // });
  }

  @override
  Widget build(BuildContext context) {

    // 화면, 인터벌, 캡쳐스위치, 재생스위치
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutputLine(provider: providerHandle, formatter: (value) => '🔹창핸들 : $value',),
            OutputLine(provider: providerWindowSize, formatter: (value) => '🔹사이즈 : ${value.$1}, ${value.$2}',),
        ],),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: SliderButton(provider: widget.x, title: '🔹X : ', max: providerMaxX, division: providerMaxX,),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: SliderButton(
            provider: widget.y, 
            title: '🔹Y : ', 
            max: providerMaxY, division: providerMaxY,
            ),
        ),
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
          final size = ref.read(providerWindowSize);
          getImage(ref.read(providerHandle), 0, 0, size.$1, size.$2);
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


