import 'package:winauto/util/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateProvider((ref) => 0);

// class TestState extends ConsumerWidget {
//   const TestState({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     debug('rebuild');
//     final count = ref.watch(counterProvider);

//     return ElevatedButton(onPressed: (){
//       // final ref.read(counterProvier);
//       ref.read(counterProvider.notifier).state++;
//     }, child: Text('$count'));
//   }
// }

class TestState extends StatelessWidget {
  const TestState({super.key});

  @override
  Widget build(BuildContext context) {
    debug('rebuild');
    
    return Consumer(builder: (context, ref, child){
      final count = ref.watch(counterProvider);
      return ElevatedButton(onPressed: (){
      // final ref.read(counterProvier);
      ref.read(counterProvider.notifier).state++;
    }, child: Text('$count}'));
    });
  }
}

