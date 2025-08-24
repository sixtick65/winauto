import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:win32/win32.dart';
import 'package:winauto/component/input_line.dart';
import 'package:winauto/component/raw_image.dart';
import 'package:winauto/component/slider_button.dart';
import 'package:winauto/component/switch_button.dart';
import 'package:winauto/provider/provider_main.dart';
// import 'package:winauto/util/bloc.dart';
// import 'package:winauto/util/win32.dart';
// import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'dart:async';
// import 'package:win32/win32.dart';
// import 'dart:typed_data';
import 'package:flutter/services.dart';
// import 'dart:ui' as ui;
import 'package:winauto/component/output_line.dart';
import 'package:winauto/util/util.dart';
import 'package:winauto/util/win32.dart';



final providerMaxX = Provider<double>((ref){ // 읽기 전용
  final size = ref.watch(providerWindowSize);
  return size.$1.toDouble();
});

final providerMaxY = Provider<double>((ref){
  final size = ref.watch(providerWindowSize);
  return size.$2.toDouble();
});

class CaptureRect extends ConsumerStatefulWidget {
  CaptureRect({super.key, double x = 0, double y = 0})
    : x = StateProvider<double>((ref) => x,),
    y = StateProvider<double>((ref) => y,)
  ;
  
  final StateProvider<double> x;// = StateProvider<double>((ref) => test,);
  final StateProvider<double> y;// = StateProvider<double>((ref) => 0.0,);
  final providerOnOff = StateProvider((ref) => false);
  final providerCaptureUint8List = StateProvider((ref) => Uint8ListImage(uint8list: Uint8List(0), width: 0, height: 0));
  final providerSaveUint8List = StateProvider((ref) => Uint8ListImage(uint8list: Uint8List(0), width: 0, height: 0));

  @override
  ConsumerState<CaptureRect> createState() => _CaptureRectState();
}

class _CaptureRectState extends ConsumerState<CaptureRect> {

  
  // _Interval interval = _Interval();
  // _SwitchCapture switchCapture = _SwitchCapture();
  // _Image image = _Image();
  Timer? timer; // = Timer(const Duration(milliseconds: 100), callback)
  final providerInputKeyCode = StateProvider((ref) => VK_SPACE);
  

  @override
  void initState() {
    super.initState();
    // switchCapture.toggle.onChanged((handler)=> image.toggle.state = handler, name:  '_CaptureRectState initState');
    // widget.hWnd.onChanged((handler) => image.hWnd.state = handler, name: '_CaptureRectState initState');
    // ref.listenManual(providerHandle, (prev, next){
    //   final temp = getWindowSize(next);
    //   ref.read(widget.x.notifier).state = temp.$1.toDouble();
    //   ref.read(widget.y.notifier).state = temp.$2.toDouble();
    // });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    // final x = ref.watch(widget.x).toInt();
    // final y = ref.watch(widget.y).toInt();

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
        
        Row(
          children: [
            Expanded(child: RawImageUint8List(providerUint8List: widget.providerCaptureUint8List, scale: 0.1,)),
            Expanded(
              child: Row(
                children: [
                  const Text('🔹캡쳐 :  '), 
                  SwitchButton(
                    providerOnOff: widget.providerOnOff,
                    on :() {
                      debug('on');
                      // int count = 0;
                      timer = Timer.periodic(const Duration(milliseconds: 100), (t){
                        // debug(count++);
                        ref.read(widget.providerCaptureUint8List.notifier).state = 
                        Uint8ListImage(uint8list: captureRect(
                          ref.read(providerHandle), 
                          ref.read(widget.x).toInt(), 
                          ref.read(widget.y).toInt(), 10, 10), width: 10, height: 10 );
                      });
                    },
                    off: (){
                      debug('off');
                      timer?.cancel();
                      },
                    ),
                  ],)),
          ],
        ),
        Row(
          children: [
            Expanded(child: RawImageUint8List(providerUint8List: widget.providerSaveUint8List, scale: 0.1,)),
            Expanded(child: ElevatedButton(onPressed: (){
              ref.read(widget.providerSaveUint8List.notifier).state = 
                        Uint8ListImage(uint8list: captureRect(
                          ref.read(providerHandle), 
                          ref.read(widget.x).toInt(), 
                          ref.read(widget.y).toInt(), 10, 10), width: 10, height: 10 );
            }, child: const Text('save'))),

          ],),
        Row(
          children: [
            const Text('🔹입력키 :  '),
            // InputLine(provider: provider),
            // 셀렉트로 바꿔야겠어
            DropdownMenu<String>(
          initialSelection: '사과',
          onSelected: (String? value) {
            if (value != null) {
              // setState(() {
              //   selectedValue = value;
              // });
            }
          },
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: "사과", label: "🍎 사과"),
            DropdownMenuEntry(value: "바나나", label: "🍌 바나나"),
            DropdownMenuEntry(value: "포도", label: "🍇 포도"),
            DropdownMenuEntry(value: "수박", label: "🍉 수박"),
          ],),
          ],
        ),
        // 매칭 이미지, 저장버튼
        // 입력키 , 딜레이
      ],
    );
  }

  
}

// class _Image extends ConsumerStatefulWidget {

//   final Bloc<int> interval = Bloc(100);
//   final Bloc<bool> toggle = Bloc(false);

//   @override
//   ConsumerState<_Image> createState() => __ImageState();
// }

// class __ImageState extends ConsumerState<_Image> {

//   RawImage rawImage = RawImage();
//   Timer? timer;

//   void getImage(int hWnd, int x, int y, int width, int height){
//     final bytes = captureRect(hWnd, x, y, width, height);
//     Completer<ui.Image> completer = Completer<ui.Image>();
//     ui.decodeImageFromPixels(bytes, width, height, ui.PixelFormat.bgra8888, completer.complete);
//     completer.future.then((onValue){
//       setState(() {
//         rawImage = RawImage(image: onValue, scale: 1,);  
//       });
      
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     timer?.cancel();
//   }

//   @override
//   void initState() {
//     super.initState();
//     widget.toggle.onChanged((handler){
//       debug(handler);
//       if(handler){
//         debug('in ${ref.read(providerHandle)}');
//         if(ref.read(providerHandle) == 0)return;
//         timer = Timer.periodic(Duration(milliseconds: widget.interval.state), (callback){
//           final size = ref.read(providerWindowSize);
//           getImage(ref.read(providerHandle), 0, 0, size.$1, size.$2);
//         });
//       }else{
//         timer?.cancel();
//       }
//     },name:  '__ImageState initState');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return rawImage;
//   }
// }




// class _Interval extends StatefulWidget {

//   // Bloc<int> hWnd = Bloc(0);
//   final Bloc<int> interval = Bloc(100);

//   @override
//   State<_Interval> createState() => __IntervalState();
// }

// class __IntervalState extends State<_Interval> {
//   TextEditingController controller = TextEditingController(text: "100");

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
//       maxLength: 4,
//       onChanged: (value) => widget.interval.state = int.parse(value),
//     );
//   }
// }

// class _SwitchCapture extends StatefulWidget {

//   final Bloc<bool> toggle = Bloc(false);

//   @override
//   State<_SwitchCapture> createState() => __SwitchCaptureState();
// }

// class __SwitchCaptureState extends State<_SwitchCapture> {
//   @override
//   Widget build(BuildContext context) {
//     debug('build _SwitchCapture');
//     return Switch(
//       value: widget.toggle.state, 
//       onChanged: (onChanged){
//         setState(() {
//           widget.toggle.state = onChanged;
//         });
//       }
//       );
//   }
// }


