import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:silah_app/services/auth_manager.dart';
import 'package:silah_app/views/login.dart';
import 'package:silah_app/views/profile.dart';
import 'package:silah_app/views/register.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn = false;

  @override
  void initState() {
    String? userId = AuthManager().getIdForCurrentUser();
    if ( userId != null) {
      print("Welcome: $userId");
      setState(() {
        userIsLoggedIn = true;
      });
    } else {
      print("No user logged in");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        "login": (context) => const Login(),
        "register": (context) => const Register(),
        "profile": (context) => const Profile()
      },
      home: userIsLoggedIn ? Profile() : Login(),
    );
  }
}