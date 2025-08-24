import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';


class OutputLine<T> extends ConsumerWidget {
  final ProviderBase<T> provider; // 어떤 provider든 받을 수 있음
  final String Function(T value)? formatter; // 포맷 함수

  const OutputLine({super.key, required this.provider, this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);
    final text = formatter != null ? formatter!(value) : '$value';
    return Text(text);
  }
}
