import 'package:winauto/util/bloc.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod/riverpod.dart'; // 으흥 dart 전용이군


class TestValuenotifier extends StatefulWidget {
  const TestValuenotifier({super.key, required this.count});

  final ValueNotifier<int> count; // = ValueNotifier(0);

  @override
  State<TestValuenotifier> createState() => _TestValuenotifierState();
}

class _TestValuenotifierState extends State<TestValuenotifier> {

  @override
  Widget build(BuildContext context) {
    debug('rebuild noti');

    return ValueListenableBuilder(valueListenable: widget.count, builder: (a,b,c){
      return ElevatedButton(onPressed: (){
        widget.count.value++;
      }, child: Text('$b'));
    });
  }
}