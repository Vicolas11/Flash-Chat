import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/welcome_screen.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flash Chat',
      initialRoute: 'welcome_screen',
      routes: {
        'chat_screen': (context) => ChatScreen(),
        'login_screen' : (context) => LoginScreen(),
        'registration_screen' : (context) =>  RegistrationScreen(),
        'welcome_screen' : (context) => WelcomeScreen()
      },
    );
  }
}
