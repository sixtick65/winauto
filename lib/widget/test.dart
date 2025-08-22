import 'package:winauto/util/bloc.dart';
import 'package:flutter/material.dart';


class TestState extends StatefulWidget {
  TestState({super.key});
  
  // final Bloc<int> num = Bloc(0);
  final ValueNotifier<int> number = ValueNotifier(0);

  @override
  State<TestState> createState() => _TestStateState();
}

class _TestStateState extends State<TestState> {
  @override
  void initState() {
    super.initState();
    // widget.num.onChanged((handler) => debug(handler));
    widget.number.addListener((){
      debug(widget.number.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: widget.number, builder: (context, value, child){
      return ElevatedButton(onPressed: (){
        widget.number.value += 1;
      }, child: Text('$value'));
    });
    // return ElevatedButton(onPressed: (){
    //   setState(() {
    //     widget.num.state += 1;
    //   });
        
      
      
    // }, child: Text('${widget.num.state}'));
  }
}