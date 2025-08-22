import 'package:flutter/material.dart'; 
import 'package:winauto/util/bloc.dart';
import 'package:flutter/services.dart';

enum InputType{
  number,
  text
}


class InputText extends StatefulWidget {
  InputText({super.key, this.type = InputType.text, String? text})
   : text = text == null ? ValueNotifier('') : ValueNotifier(text);

  final InputType type;
  final ValueNotifier<String> text;

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  TextEditingController controller = TextEditingController();
  TextField textField = TextField();

  @override
  void initState() {
    super.initState();
    controller.text = widget.text.value;
    switch (widget.type) {
      case InputType.number:
        textField = TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
          onChanged: (value) => widget.text.value = value,
        );
        break;
      default:
        textField = TextField(
          controller: controller,
          onChanged: (value) => widget.text.value = value,
          );
    }
    
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return textField;
  }
}