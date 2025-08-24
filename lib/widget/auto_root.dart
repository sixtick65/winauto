import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winauto/component/capture_image.dart';
import 'package:winauto/component/input_text.dart';
import 'package:winauto/component/output_text.dart';
import 'package:winauto/component/switch_button.dart'; 
import 'package:winauto/util/bloc.dart';

final StateProvider<bool> providerRootOnOff = StateProvider((ref) => false);

class AutoRoot extends ConsumerStatefulWidget {
  const AutoRoot({super.key, required this.handle});
  final ValueNotifier<int> handle;

  @override
  ConsumerState<AutoRoot> createState() => _AutoRootState();
}

class _AutoRootState extends ConsumerState<AutoRoot> {
  final SizedBox marginWidth = const SizedBox(width: 20,);
  final InputText x = InputText(key: UniqueKey(), type: InputType.number, text: '1061');
  final InputText y = InputText(key: UniqueKey(), type: InputType.number, text: '627');
  final CaptureImage image = CaptureImage();
  final SwitchButton switchCapture = SwitchButton(providerOnOff: providerRootOnOff,);

  @override
  void initState() {
    
    widget.handle.addListener((){
      // image.hWnd.state = handler;
      debug('_AutoRootState widget.hWnd.addListener ${widget.handle.value}');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    
    return Column(
      children: [
        ValueListenableBuilder(valueListenable: widget.handle, builder: (context, value, child){
          return ElevatedButton(onPressed: (){widget.handle.value += 1;}, child: Text('$value'));
        }),
        
        Row(
          children: [
            marginWidth,
            const Text('스캔위치'),
            marginWidth,
            const Text('X : '),
            SizedBox(width: 50, child: x),
            marginWidth,
            const Text('Y : '),
            SizedBox(width:50, child:  y),
          ],
        ),
        Row(
          children: [
            marginWidth,
            image,
            marginWidth,
            switchCapture,
            marginWidth,
          ],
        ),

      ],
    );
  }
}
// 스캔 크기 10*10
// 스캔위치. 저장
// 저장이미지
// 매칭이미지
// 입력키
// 온오프
