import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/views/login_page.dart';
import 'package:project/views/my_pledged_gifts_page.dart';
import 'package:project/views/profile_page.dart';
import 'package:project/views/home_page.dart';
import 'package:project/views/event_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login', // Start with the LoginPage
      routes: {
        '/login': (context) => LoginPage(),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => HomePage(),
        '/event': (context) => EventListPage(),
        '/mygift': (context) => MyPledgedGiftsPage(),
        // Add other routes here as needed
      },
    );
  }
}
