import 'dart:async';
import 'package:esrgan_flutter2_ocean_app/screens/home_screen.dart';
import 'package:esrgan_flutter2_ocean_app/screens/login_screen_auth.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;

  @override
  void initState() {
    user = auth.currentUser;
    user!.sendEmailVerification();

    checkEmailVerified();
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreenAuth()));
          },
        ),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(bottom: 10),
                //padding: EdgeInsets.all(2),
                child: Image.asset("assets/images/esrganFlutterLogo.png",
                    fit: BoxFit.cover, height: 75)),
            Text(
              "Verify your Email",
              style: GoogleFonts.sourceSansPro(
                  color: Colors.black87,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "\nWe have sent an email to ${user!.email}",
              style: GoogleFonts.sourceSansPro(
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
            Text(
              '\nYou need to verify your email to continue. If you have not received the verification email, please check your "Spam" or "Bulk Email" folder. You can also click the resend button below to have another email sent to you.',
              style: GoogleFonts.sourceSansPro(
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 32),
              child: ElevatedButton(
                onPressed: () {
                  checkEmailVerified();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "Check again and continue",
                    style: GoogleFonts.sourceSansPro(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue)))),
              ),
            ),
            InkWell(
              onTap: () {
                showSnackBar(
                    context,
                    "Email verification was re-sent, please check your email.",
                    Colors.blue,
                    3000);
                user!.sendEmailVerification();
              },
              child: Text(
                "Resend verification Email",
                style: GoogleFonts.sourceSansPro(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            )
          ],
        ),
      )),
    );
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user!.reload();
    print("AAAAAAAAAAAAA" + user!.emailVerified.toString());
    if (user!.emailVerified == true) {
      showSnackBar(
          context,
          "Your email has been verified. You can now use your account.",
          Colors.green,
          3000);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => HomeScreen(user: user!, screenIndex: 0)));
    } else if (user!.emailVerified == false) {}
  }
}
