import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  Widget build(BuildContext context) {
    String _aboutText =
        "The ESRGAN is an algorithm that is capable of generating realistic textures during single image super-resolution, like GANs in general, the idea is to train two neural networks to work against each other. The ESRGAN algorithm compares the generated image to a real image, and tries to determine which is more real.";
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeScreen(user: _user, screenIndex: 1)));
          },
        ),
        title: Text("About"),
      ),
      backgroundColor: Color(0xFFeeeeee),
      body: Container(
          child: ListView(
        padding: EdgeInsets.all(8),
        children: [
          Column(children: <Widget>[
            Container(
              child: Image.asset(
                'assets/images/esrganFlutterLogo.png',
                height: 150,
              ),
            ),
            Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                child: Text(
                  "Application of Enhanced Super Resolution Generative Adversarial Network Algorithm for Image Processing.",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                )),
            Container(
              margin: EdgeInsets.all(8),
              child: Text(_aboutText,
                  style: TextStyle(
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                child: Text("Contact us at:")),
            Container(
              margin: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Izekiel C. David",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text("09760547612"),
                    Text("icdavid@student.hau.edu.ph")
                  ]),
            ),
            Container(
              margin: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Miguel Angelo P. Santos",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text("09652343566"),
                    Text("mpsantos@student.hau.edu.ph")
                  ]),
            ),
            Container(
              margin: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Robin Andrei H. Serrano",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text("09477894219"),
                    Text("rhserrano1@student.hau.edu.ph")
                  ]),
            ),
            Container(
              margin: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jay Ivan M. Sosa",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text("09454763582"),
                    Text("jmsosa@student.hau.edu.ph")
                  ]),
            ),
          ]),
        ],
      )),
    ));
  }
}
