import 'dart:ui';

import 'package:bookfx/bookfx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 电子书模拟手势翻页效果
class Book extends StatefulWidget {
  const Book({Key? key}) : super(key: key);

  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  String data = '''''';
  TextEditingController textEditingController = TextEditingController();

  EBookController eBookController = EBookController();
  BookController bookController = BookController();

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/santi.txt').then((value) {
      setState(() {
        data = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('电子书翻页demo'),
        ),
        body: data.isEmpty
            ? const SizedBox()
            : Column(
                children: [
                  EBook(
                      maxWidth: MediaQuery.of(context).size.width,
                      eBookController: eBookController,
                      bookController: bookController,
                      duration: const Duration(milliseconds: 400),
                      fontHeight: 1.6,
                      data: data,
                      fontSize: eBookController.fontSize,
                      padding: const EdgeInsetsDirectional.all(15),
                      maxHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQueryData.fromWindow(window).padding.top -40,),
                SizedBox(
                  height: 30,
                  child:   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            bookController.next();
                          },
                          child: const Text("下一页")),
                      ElevatedButton(
                          onPressed: () {
                            bookController.last();
                          },
                          child: const Text("上一页")),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("提示"),
                                    content: SizedBox(
                                        height: 100,
                                        child: Column(
                                          children: [
                                            TextField(
                                              controller: textEditingController,
                                              textInputAction:
                                              TextInputAction.go,
                                              keyboardType:
                                              TextInputType.number,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  int index = int.parse(
                                                      textEditingController
                                                          .text);
                                                  bookController.goTo(index);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("确定"))
                                          ],
                                        )),
                                  );
                                });
                          },
                          child: const Text("跳转指定页")),
                    ],
                  ),
                )
                ],
              ));
  }
}
