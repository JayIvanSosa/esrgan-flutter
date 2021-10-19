import 'package:email_validator/email_validator.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/authentication/authentication.dart';
import '/screens/home_screen.dart';
import '/screens/register_screen_auth.dart';
import '/widgets/google_signin_button.dart';
import '/widgets/scaler.dart';

class LoginScreenAuth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenAuthState();
}

class LoginScreenAuthState extends State<LoginScreenAuth> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _success = false;
  String _userEmail = "";
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler()..init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: scaler.getHeight(30),
                    child: Image.asset('assets/images/esrganFlutterLogo.png')),
                Text(
                  "PIXS",
                  style: TextStyle(
                    fontFamily: 'Agency',
                    color: Color(0xFF0001e36),
                    letterSpacing: .5,
                    fontSize: scaler.getHeight(4.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _emailController,
                      decoration: InputDecoration(
                          hintText: 'Email',
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.none,
                              ))),
                      validator: (email) {
                        if (email == null || email.isEmpty) {
                          return 'The email must be provided.';
                        } else if (EmailValidator.validate(email) == false) {
                          return 'A valid email must be provided.';
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: _isObscure,
                      controller: _passwordController,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.none,
                              )),
                          suffixIcon: IconButton(
                              icon: Icon(_isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              })),
                      validator: (password) {
                        if (password!.isEmpty) {
                          return 'The password must be provided.';
                        } else if (password.length < 6) {
                          return 'Password length requires 6 or more characters.';
                        }

                        // bool isPasswordValid =
                        //     ;
                        // return (isPasswordValid)
                        //     ? null
                        //     : 'The password must be provided.';
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _signInWithEmailAndPassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(400, 50),
                      padding: EdgeInsets.all(16),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Log in',
                      style: TextStyle(fontSize: 16),
                    )),
                Row(children: <Widget>[
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 15.0),
                        child: Divider(
                          color: Colors.black,
                          height: 50,
                        )),
                  ),
                  Text("OR"),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 15.0, right: 10.0),
                        child: Divider(
                          color: Colors.black,
                          height: 50,
                        )),
                  ),
                ]),
                FutureBuilder(
                  future: Authentication.initializeFirebase(context: context),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error initializing Firebase');
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return GoogleSignInButton();
                    }
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    );
                  },
                ),
                SizedBox(
                  height: scaler.getHeight(3.0),
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Don\'t have an account? ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w700),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print('Login Text Clicked');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreenAuth()),
                            );
                          }),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signInWithEmailAndPassword() async {
    final authUser = (await _auth
            .signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    )
            .catchError((error) {
      showSnackBar(context, error.toString().split("]")[1].split(".")[0],
          Colors.red, 3000);
    }))
        .user;

    if (authUser != null) {
      setState(() {
        _success = true;
        _userEmail = authUser.email!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              user: authUser,
              screenIndex: 0,
            ),
          ),
        );
      });
    } else {
      setState(() {
        _success = false;
      });
    }
  }
}
