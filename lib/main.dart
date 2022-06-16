import 'package:flutter/material.dart';
import 'package:flutter_forms/pages/register_form_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Form Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const RegisterFormPage(),
    );
  }
}
