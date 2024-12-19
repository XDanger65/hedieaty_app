import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/firebase_api.dart';
import 'package:project/views/login_page.dart';
import 'package:project/views/my_pledged_gifts_page.dart';
import 'package:project/views/profile_page.dart';
import 'package:project/views/home_page.dart';
import 'package:project/views/event_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login', // Start with the LoginPage
      routes: {
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/home': (context) => const HomePage(),
        '/event': (context) => const EventListPage(),
        '/mygift': (context) => const MyPledgedGiftsPage(),
        // Add other routes here as needed
      },
    );
  }
}
