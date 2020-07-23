import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import '../button.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email, password;
  bool showSpinner = false;
  final _scaffoldKeys = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _passwordVisibility = true;
  final textController = TextEditingController();
  final textControllerPwd = TextEditingController();
  final RegExp emailRegExp = RegExp(patternQuery);

  @override
  void dispose() {
    super.dispose();
    showSpinner = false;
  }

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    return WillPopScope(
      onWillPop: () => Navigator.popAndPushNamed(context, 'welcome_screen'),
      child: Scaffold(
        key: _scaffoldKeys,
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: textController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter your Email!';
                            } else if (!emailRegExp.hasMatch(value)) {
                              return 'Please Enter a Valid Email!';
                            } else {
                              return null;
                            }
                          },
                          autofocus: true,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            email = value;
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Enter your Email',
                            prefixIcon:
                                Icon(Icons.email, color: Colors.lightBlue),
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                            controller: textControllerPwd,
                            obscureText: _passwordVisibility,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your password!';
                              } else if (value.length < 6) {
                                return 'Password Length must be more than 6';
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              password = value;
                            },
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Enter your Password',
                              prefixIcon:
                                  Icon(Icons.lock, color: Colors.lightBlue),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                      _passwordVisibility
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.lightBlue),
                                  onPressed: () => setState(() {
                                        _passwordVisibility =
                                            !_passwordVisibility;
                                      })),
                            )),
                        SizedBox(
                          height: 24.0,
                        ),
                        RoundButton(
                          buttonTitle: 'Log in',
                          buttonColor: Colors.lightBlueAccent,
                          onPressed: () async {
                            try {
                              if (_formKey.currentState.validate()) {
                                final user = await _auth.signInWithEmailAndPassword(
                                    email: email, password: password);
                                //showSpinner = true;
                                _formKey.currentState.dispose();
                                if (user != null) {
                                  Navigator.pushNamed(context, 'chat_screen');
                                  setState(() {
                                    showSpinner = false;
                                    textController.clear();
                                    textControllerPwd.clear();
                                  });
                                }
                              } else {
                                _autoValidate = true;
                              }

                            } catch (error) {
                              switch (error.code) {
                                case "ERROR_USER_NOT_FOUND": {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          title: Text(
                                            'ACOUNT NOT FOUND!',
                                            style: TextStyle(
                                              color: Colors.lightBlue,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          actions: [
                                            FlatButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(
                                                'Close',
                                                style:
                                                TextStyle(color: Colors.lightBlue),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            FlatButton(
                                              onPressed: () => Navigator.pushNamed(
                                                  context, 'registration_screen'),
                                              child: Text(
                                                'Create New Account',
                                                style: kAlertTextStyle,
                                              ),
                                            ),
                                          ],
                                          content: Material(
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: Text(
                                                'Sorry $email does not exit!\nCreate a new account.'),
                                          ),
                                        );
                                      });
                                }
                                break;
                                case "ERROR_WRONG_PASSWORD": {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          title: Text(
                                            'WRONG PASSWORD!',
                                            style: kAlertTextStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                          actions: [
                                            FlatButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(
                                                'Close',
                                                style:
                                                TextStyle(color: Colors.lightBlue),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                          content: Material(
                                            child: Text(
                                                'Sorry you entered a wrong password!'),
                                          ),
                                        );
                                      });
                                }
                                break;
                                default: {
                                  Navigator.pushNamed(context, 'chat_screen');
                                }
                              }
                            }
                          },
                        )

                      ],
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
