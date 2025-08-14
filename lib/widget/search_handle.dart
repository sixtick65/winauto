import 'package:winauto/util/bloc.dart';
import 'package:winauto/win32.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

class SearchHandle extends StatefulWidget {
  SearchHandle({super.key});

  Bloc<int> handle = Bloc<int>(0);

  @override
  State<SearchHandle> createState() => _SearchHandleState();
}

class _SearchHandleState extends State<SearchHandle> {
  final TextEditingController controller = TextEditingController();
  final SizedBox margin1 = SizedBox(width: 20,); 

  @override
  void initState() {
    super.initState();
    debug(widget.handle.state);
    debug("NULL : $NULL");
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
                        widget.handle.state = NULL;
                      });
                    },
                  ),
                  border: UnderlineInputBorder(),
                ),
                )),
            margin1,
            Text(" : ${widget.handle.state.toString()}"),
            margin1,
            ElevatedButton(onPressed: (){
              setState(() {
                try {
                  widget.handle.state = findWindowHandle(controller.text);
                  debug(widget.handle.state);
                } catch (e) {
                  widget.handle.state = NULL;
                  debug("${controller.text} not found");
                }
              });
            }, child: const Text('search')),
            margin1,
          ],
        );
  }
}

