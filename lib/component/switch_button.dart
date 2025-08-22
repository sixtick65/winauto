import 'package:flutter/material.dart'; 
import 'package:winauto/util/bloc.dart';

class SwitchButton extends StatefulWidget {
  SwitchButton({super.key});

  final Bloc<bool> onOff = Bloc(false);

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  @override
  Widget build(BuildContext context) {
    return Switch(value: widget.onOff.state, onChanged: (onChanged){
      setState(() {
        widget.onOff.state = onChanged;
      });
      
    });
  }
}
