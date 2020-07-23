import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../button.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation, animateColor;

  @override
  void initState() {
    super.initState();
      controller = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this,
      );
      controller.forward();
      animation = CurvedAnimation(parent: controller, curve: Curves.bounceIn);
      animateColor = ColorTween(begin: Colors.blueGrey, end: Colors.white)
          .animate(controller);
      controller.addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animateColor.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: animation.value * 100,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundButton(
              buttonTitle: 'Log in',
              buttonColor: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, 'login_screen');
              },
            ),
            RoundButton(
                buttonTitle: 'Register',
                buttonColor: Colors.blueAccent,
              onPressed: () {
                Navigator.pushNamed(context, 'registration_screen');
              },
            ),
          ],
        ),
      ),
    );
  }
}
