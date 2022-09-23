import 'package:flutter/material.dart';

import 'package:bookfx/bookfx.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String data = '''''';
  EBookController eBookController = EBookController();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "翻页demo",
        ),
      ),
      body: data.isNotEmpty
          ? EBook(
              maxWith: MediaQuery.of(context).size.width,
              eBookController: eBookController,
              data: data,
              fontSize: eBookController.fontSize,
              padding: const EdgeInsetsDirectional.all(15),
              maxHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  56)
          : const SizedBox(),
    );
  }
}
