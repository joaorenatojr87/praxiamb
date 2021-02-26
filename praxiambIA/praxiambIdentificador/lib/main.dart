import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/screens/detect_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detectar o Guaraná',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: DetectScreen(title: 'Detectar GUARANÁ'),
    );
  }
}
