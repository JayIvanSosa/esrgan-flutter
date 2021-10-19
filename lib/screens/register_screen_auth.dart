import 'package:email_validator/email_validator.dart';
import 'package:esrgan_flutter2_ocean_app/screens/login_screen_auth.dart';
import 'package:esrgan_flutter2_ocean_app/screens/verify_screen.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/scaler.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreenAuth extends StatefulWidget {
  const RegisterScreenAuth({Key? key}) : super(key: key);

  @override
  _RegisterScreenAuthState createState() => _RegisterScreenAuthState();
}

class _RegisterScreenAuthState extends State<RegisterScreenAuth> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _success = false;
  String _userEmail = "";
  bool _isObscure = true;

  void _register() async {
    final authUser = (await _auth
            .createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    )
            .catchError((error) {
      showSnackBar(context, error.toString().split("]")[1], Colors.red, 3000);
    }))
        .user;
    if (authUser != null) {
      setState(() {
        _success = true;
        _userEmail = authUser.email!;
      });
      //   showSnackBar(
      //       context, "Account created successfully.", Colors.green, 3000);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => VerifyScreen()));
    } else {
      setState(() {
        _success = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler()..init(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Color(0xFF001e36),
        centerTitle: true,
        title: Text("Register"),
        leading: IconButton(
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreenAuth())),
            color: Colors.white,
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: scaler.getHeight(30),
                      child:
                          Image.asset('assets/images/esrganFlutterLogo.png')),
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
                  SizedBox(height: 16),
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
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _register();
                        } else {
                          print('the login form is not valid');
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
                        'Create Account',
                        style: TextStyle(fontSize: 16),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
