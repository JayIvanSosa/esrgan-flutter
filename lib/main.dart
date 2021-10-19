import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'package:esrgan_flutter2_ocean_app/screens/login_screen_auth.dart';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance
      .activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
//   late Permission permission;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFF1f2430),
          buttonTheme: ButtonThemeData(buttonColor: Color(0xFF31a8ff)),
          appBarTheme: AppBarTheme(color: Color(0xFF001e36))),
      title: 'Esrgan Flutter',
      home: AnimatedSplashScreen(
        duration: 3000,
        splash: 'assets/images/esrganFlutterLogo.png',
        nextScreen: LoginScreenAuth(), //LoginScreenAuth(), //NewApp(),
        splashTransition: SplashTransition.fadeTransition,
        //pageTransitionType: PageTransitionType.scale,
        backgroundColor: Color(0xFF001e36),
        splashIconSize: 300,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
