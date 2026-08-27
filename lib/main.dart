import 'package:flutter/material.dart';

void main() {
  runApp(const StorePh3App());
}

class StorePh3App extends StatelessWidget {
  const StorePh3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STOREPH3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: Center(
          child: Text('STOREPH3 v1.0'),
        ),
      ),
    );
  }
}
