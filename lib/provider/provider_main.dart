import 'dart:typed_data';
import 'package:winauto/util/win32.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerHandle = StateProvider((ref) => 0, name: 'providerHandle');
final providerCaptureUint8List = StateProvider((ref) => Uint8List(0));
final providerWindowSize = Provider<(int,int)>((ref) {
  final handle = ref.watch(providerHandle);
  return getWindowSize(handle);
});
