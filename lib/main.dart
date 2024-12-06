import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(), // Start with the LoginPage
    );
  }
}