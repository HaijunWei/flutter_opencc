import 'package:flutter/material.dart';
import 'package:flutter_opencc/flutter_opencc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    test();
  }

  void test() async {
    final opencc = FlutterOpenCC();
    await opencc.init(ConverType.s2t);
    final result = opencc.covert(
        '阴德者，月内阴德之神，阴德日为阴德之神当值之日。天地间之气化有阴就有阳，互而为用，正所谓孤阳不生，独阴不长。德之神，扬善嫉恶，明察功过之神，凡有冤情待平复，或行善积德、惠泽贫困之举，选用阴德日其愿顺遂。');
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(),
      ),
    );
  }
}
