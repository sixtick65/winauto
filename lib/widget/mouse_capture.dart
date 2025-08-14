import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:win32/win32.dart';

class MouseCapture extends StatefulWidget {
  const MouseCapture({super.key});

  @override
  State<MouseCapture> createState() => _MouseCaptureState();
}

class _MouseCaptureState extends State<MouseCapture> {
  (int, int, int, int, int) point = (0,0,0,0,0);
  bool isCapture = false;
  Timer? timer;
  TextEditingController controller = TextEditingController();
  int hWnd = NULL;
  Widget margin1 = const SizedBox(width: 20,);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            margin1,
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      controller.clear(); // 입력 내용 삭제
                      setState(() {
                        hWnd = NULL;
                      });
                    },
                  ),
                  border: UnderlineInputBorder(),
                ),
                )),
            margin1,
            Text(" : ${hWnd.toString()}"),
            margin1,
            ElevatedButton(onPressed: (){
              setState(() {
                try {
                  hWnd = findWindowHandle(controller.text);
                  debug(hWnd);
                } catch (e) {
                  hWnd = NULL;
                  debug("${controller.text} not found");
                }
              });
            }, child: const Text('search')),
            margin1,
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            
            // x, y, r, g, b
            // text, switch
            Text(point.toString()),
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
                      point = getPixelColor(hWnd);
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


