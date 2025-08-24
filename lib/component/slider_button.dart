import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:winauto/util/util.dart';
import 'package:winauto/widget/capture_rect.dart';

class SliderButton extends ConsumerWidget {
  const SliderButton({
    super.key, 
    required this.provider, 
    this.min = 0.0, 
    required this.max, 
    required this.division, 
    this.title = ''});
  final StateProvider<double> provider;
  final double min;
  final StateProvider<double> max;
  final StateProvider<double> division;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temp = ref.watch(provider);
    final stateMax = ref.watch(max) == 0 ? 10.0 : ref.watch(max);
    final stateDivision = ref.watch(division) == 0 ? 10.0 : ref.watch(division);
    //ref.read(valueProvider.notifier).state++;
    // return Text('$temp');
    return Row(
      children: [
        Text('$title ${temp.round()}  '),
        IconButton(onPressed: (){
          if(ref.read(provider) > min){
            // final temp = ref.read(provider.notifier).state;
            // debug('temp : $temp');
            // final step = max / division;
            // debug('step : $step');
            // final sum = temp - step;
            // debug('sum : $sum ${sum.toStringAsFixed(1)}');
            // ref.read(provider.notifier).state = sum;
            ref.read(provider.notifier).state -= (stateMax/stateDivision);
          }}, icon: Icon(Icons.remove_circle_outline)),
        Expanded(
          child: Slider(
            value: temp, 
            label: temp.round().toString(),
            min: min,
            max: stateMax,
            divisions: stateDivision.toInt(),
            onChanged: (value){
            ref.read(provider.notifier).state = value;
          }),
        ),
        IconButton(onPressed: (){
          if(ref.read(provider) < stateMax){
            ref.read(provider.notifier).state += (stateMax/stateDivision);
          }}, icon: Icon(Icons.add_circle_outline)),
      ],
    );
  }
}