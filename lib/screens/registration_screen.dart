import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../button.dart';
import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email, password;
  bool showSpinner = false;
  bool autoValidate = false;
  bool _passwordVisibility = true;
  final emailRegExp = RegExp(patternQuery);
  final passwordRegExp = RegExp(strongPassword);
  final textController = TextEditingController();
  final textControllerPwd = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    textControllerPwd.dispose();
    showSpinner = false;
  }


  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    //Display cancel IconButton on text Changed
    textControllerPwd.addListener(() {
      kTextFieldDecoration.copyWith(
        suffixIcon: IconButton(
          icon: Icon(Icons.cancel, color: Colors.lightBlue,),
          onPressed: () => textControllerPwd.clear(),
        )
      );
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: false,
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
                autovalidate: autoValidate,
                child: Column(
                  children: [
                        TextFormField(
                        controller: textController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          email = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return '*Required';
                            } else if (!emailRegExp.hasMatch(value)) {
                              return 'Please Enter a Valid Email!';
                            } else {
                              return null;
                            }
                          },
                          autofocus: true,
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
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return '*Required!';
                        } else if (value.length < 6) {
                          return 'Password Length must be more than 6';
                        } else if (!passwordRegExp.hasMatch(value)) {
                          return 'Password must contain Numbers, Lowercase '
                              '& UpperCase Alphabets and Symbols';
                        } else {
                          return null;
                        }
                      },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter your Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.lightBlue),
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
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    RoundButton(
                        buttonTitle: 'Register',
                        buttonColor: Colors.blueAccent,
                        onPressed: () async {
                          try {
                           if (_formKey.currentState.validate()) {
                             final user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                             setState(() {
                               showSpinner = true;
                             });
                             if (user != null) {
                               Navigator.pushNamed(context, 'login_screen');
                              }
                            } else {
                             setState(() {
                               autoValidate = true;
                             });
                           }
                          } catch (error) {
                            print(error);
                            switch (error.code) {
                              case "ERROR_EMAIL_ALREADY_IN_USE": {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ShowAlertDialog(
                                        onPressedNavigate: () => Navigator.pushNamed(
                                            context, 'registration_screen'),
                                        alertTitle: 'ACOUNT CREATED ALREADY!',
                                        alertTitleSecond: 'Create New Account',
                                        alertContent: 'Sorry $email already exit!\nCreate a new account',
                                      );
                                    });
                              }
                              break;
                              case "ERROR_WEAK_PASSWORD": {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ShowAlertDialog(
                                        alertTitle: 'WEAK PASSWORD',
                                        alertContent: 'Sorry your password is weak\nTry include '
                                            'numbers, lower and uppercase alphabets!',
                                      );
                                    }
                                    );
                              }
                              break;
                            }
                          }
                        }),
                  ]
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShowAlertDialog extends StatelessWidget {
  ShowAlertDialog({this.alertTitle, this.alertTitleSecond, this.alertContent, this.onPressedNavigate});
  final String alertTitle, alertTitleSecond, alertContent;
  final Function onPressedNavigate;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        alertTitle,
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
        FlatButton(
            onPressed: onPressedNavigate,
            child: Text(
              alertTitleSecond,
              style: TextStyle(
                  color: Colors.lightBlue),
            ))
      ],
      content: Material(
        child: Text(alertContent),
      ),
    );
  }
}

