import 'package:flutter/material.dart'; 
import 'package:winauto/util/bloc.dart';


class OutputText extends StatefulWidget {
  OutputText({super.key, Bloc<String>? text}): 
    text = text ?? Bloc('');

  final Bloc<String> text;

  @override
  State<OutputText> createState() => _OutputTextState();
}

class _OutputTextState extends State<OutputText> {
  @override
  void initState() {
    super.initState();
    widget.text.onChanged((handler){
      setState(() {
        // 걍 다시 그림
      });
    }, name:  '_OutputTextState initState');
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.state,
    );
  }
}