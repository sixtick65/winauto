import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType{
  number,
  text
}

class InputLine extends ConsumerStatefulWidget {
  const InputLine({super.key, this.textInit, this.type = InputType.text, required this.provider});
  final String? textInit;
  final StateProvider<String> provider;
  final InputType type;

  @override
  ConsumerState<InputLine> createState() => _InputLineState();
}

class _InputLineState extends ConsumerState<InputLine> {
  TextEditingController controller = TextEditingController();
  late TextField textField;

  @override
  void initState() {
    super.initState();
    controller.text = widget.textInit ?? '';

    switch (widget.type) {
      case InputType.number:
        textField = TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
          onChanged: (value) => ref.read(widget.provider.notifier).state = value,
        );
        break;
      default:
        textField = TextField(
          controller: controller,
          onChanged: (value) => ref.read(widget.provider.notifier).state = value,
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
    // final temp = ref.watch(tempProvider);
    
    return textField;
  }
}