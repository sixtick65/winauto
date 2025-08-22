import 'package:winauto/util/bloc.dart';
import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

class SearchHandle extends StatefulWidget {
  const SearchHandle({super.key, required this.handle});

  final ValueNotifier<int> handle;

  @override
  State<SearchHandle> createState() => _SearchHandleState();
}

class _SearchHandleState extends State<SearchHandle> {
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
                      setState(() {
                        widget.handle.value = NULL;
                      });
                    },
                  ),
                  border: UnderlineInputBorder(),
                ),
                )),
            margin1,
            Text(" : ${widget.handle.value.toString()}"),
            margin1,
            ElevatedButton(onPressed: (){
              setState(() {
                try {
                  widget.handle.value = findWindowHandle(controller.text);
                  debug(widget.handle.value);
                } catch (e) {
                  widget.handle.value = NULL;
                  debug("${controller.text} not found");
                }
              });
            }, child: const Text('search')),
            margin1,
          ],
        );
  }
}

