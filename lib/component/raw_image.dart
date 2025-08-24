import 'dart:typed_data';

import 'package:flutter/material.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winauto/util/util.dart';

// final tempProvider = StateProvider((ref) => 0);

class RawImageUint8List extends ConsumerWidget {
  const RawImageUint8List({super.key, required this.providerUint8List, this.scale = 1.0});
  final StateProvider<Uint8ListImage> providerUint8List;
  final double scale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawImage = ref.watch(providerUint8List);
    //ref.read(tempProvider.notifier).state++;
    return FutureBuilder(
      future: rawImage.toRawImage(scale: scale), 
      builder: (context, snapshot){
        return snapshot.data ?? RawImage();
      });
  }
}