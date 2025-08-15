import 'package:winauto/util/bloc.dart';
import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:win32/win32.dart';
import 'package:flutter/services.dart';

class ScanHp extends StatefulWidget {
  Bloc<int> hWnd = Bloc(NULL);
  ScanHp({super.key});
  int _x = 0;
  int get x => _x; 
  int _y = 0;
  int get y => _y;
  (int,int,int) _rgb = (0,0,0);
  (int,int,int) get rgb => _rgb;

  @override
  State<ScanHp> createState() => _ScanHpState();
}

class _ScanHpState extends State<ScanHp> {
  TextEditingController controllerX = TextEditingController();
  TextEditingController controllerY = TextEditingController();
  (int, int, int) scanColor = (0,0,0);
  Timer? timer;
  bool isScan = false;

  @override
  void dispose() {
    super.dispose();
    controllerX.dispose();
    controllerY.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {


    // 스캔위치 비교컬러 클릭위치 스캔간격 딜레이
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('● 스캔 위치 '),
            const Text("X :"),
            SizedBox(
              width: 50,
              child: TextField(
                controller: controllerX,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                ],
                maxLength: 4,
                onChanged: (value) => widget._x = int.parse(value),
              ),
              
            ),
            const Text("Y :"),
            SizedBox(
              width: 50,
              child: TextField(
                controller: controllerY,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                ],
                maxLength: 4,
                onChanged: (value) => widget._y = int.parse(value),
              ),
            ),
          ],
        ),
        // 비교컬러
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('● 스캔 컬러 : ${scanColor.$1}, ${scanColor.$2}, ${scanColor.$3}'),
            Switch(value: isScan, onChanged: (onChanged){
              if(onChanged){
                timer = Timer.periodic(const Duration(seconds: 1), (callback){
                  widget._rgb = getColor(widget.hWnd.state, widget.x, widget.y);
                  // debug(widget.rgb);
                  if(widget.rgb == (58, 0, 0)){
                    sendKeyToForegroundWindow(widget.hWnd.state, VK_F4);
                  }
                  setState(() {
                    scanColor = widget.rgb;
                  });
                });
                
              }else{
                timer?.cancel();
              }
              setState(() {
                isScan = onChanged;
              });
            }),
          ],),
      ],
    );
  }
}


