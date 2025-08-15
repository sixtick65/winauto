import 'package:winauto/util/bloc.dart';
import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:win32/win32.dart';

class MouseCapture extends StatefulWidget {
  MouseCapture({super.key});

  Bloc<int> hWnd = Bloc(NULL);

  @override
  State<MouseCapture> createState() => _MouseCaptureState();
}

class _MouseCaptureState extends State<MouseCapture> {
  (int, int, int, int, int) point = (0,0,0,0,0);
  bool isCapture = false;
  Timer? timer;
  // int hWnd = NULL;
  Widget margin1 = const SizedBox(width: 20,);

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
                      point = getPixelColor(widget.hWnd.state);
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


