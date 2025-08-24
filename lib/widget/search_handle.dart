import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winauto/util/bloc.dart';
import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:winauto/provider/provider_main.dart';


// final tempProvider = StateProvider((ref) => 0);

class SearchHandle extends ConsumerStatefulWidget {
  const SearchHandle({super.key});

  @override
  ConsumerState<SearchHandle> createState() => _SearchHandleState();
}

class _SearchHandleState extends ConsumerState<SearchHandle> {

  final TextEditingController controller = TextEditingController();
  final SizedBox margin1 = SizedBox(width: 20,);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debug('SearchHandle re build');
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            margin1,
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      controller.clear(); // 입력 내용 삭제
                      var _ = ref.refresh(providerHandle);
                    },
                  ),
                  border: UnderlineInputBorder(),
                ),
                // onChanged: (value) => ref.read(providerHandle.notifier).state = int.parse(value),
                )),
            margin1,
            _OutputText(),
            margin1,
            ElevatedButton(onPressed: (){
              
                try {
                  ref.read(providerHandle.notifier).state = findWindowHandle(controller.text);
                } catch (e) {
                  debug("${controller.text} not found");
                }
              
            }, child: const Text('search')),
            margin1,
          ],
        );
  }
}


class _OutputText extends ConsumerWidget {
  const _OutputText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debug('_OutputText re build');
    final temp = ref.watch(providerHandle);
    return Text('$temp');
  }
}
