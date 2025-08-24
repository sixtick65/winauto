import 'package:flutter/material.dart'; 
import 'package:winauto/util/util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SwitchButton extends ConsumerStatefulWidget {
  const SwitchButton({super.key, required this.providerOnOff, this.on, this.off});
  final StateProvider<bool> providerOnOff;
  final void Function()? on;
  final void Function()? off;
  // final Bloc<bool> onOff = Bloc(false);

  @override
  ConsumerState<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends ConsumerState<SwitchButton> {
  @override
  Widget build(BuildContext context) {
    final onOff = ref.watch(widget.providerOnOff);
    return Switch(
      value: onOff, 
      onChanged: (onChanged){
        if(onChanged){
          debug(onChanged);
          widget.on?.call();
        }else{
          debug(onChanged);
          widget.off?.call();
        }
        ref.read(widget.providerOnOff.notifier).state = onChanged; 
      });
  }
}
