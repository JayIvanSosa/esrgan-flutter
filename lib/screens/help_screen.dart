import 'package:esrgan_flutter2_ocean_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text("Help"),
      ),
      backgroundColor: Color(0xFFeeeeee),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Image enhancement: ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  "Step 1:  Go to the image enhancement tab then select an image.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  "Step 2: Press the enhance image button.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  "Step 3: Choose either to save image to your account or export to your device the enhanced image.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  "Step 4: Saved images are stored in your account, it can be viewed in the image gallery tab.\n              Exported images are directed to your devices' storage.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 17,
              ),
              Text(
                "Export an Image in Gallery Tab: ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  "Step 1:  Go to gallery tab and select an image.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  "Step 2:  Click export button to save the image to your device.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  "Step 3:  You can delete an image by clicking the delete button.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: () {
                  _launchInBrowser(
                      "https://drive.google.com/file/d/1AEBpnxF4iTbp0RHb_FLcOGGHmMrGNO8M/view?fbclid=IwAR0Q8L_Dk1BgcdJh09uDKTQu716ESv06gCY7FRrxBQh1uob1iUKWrfBST7I");
                },
                child: RichText(
                  text: TextSpan(
                    text: "For additional information, click to view",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                    children: const <TextSpan>[
                      TextSpan(
                        text: " User Manual",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await _launchURL(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> _launchInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    );
  } else {
    throw 'Could not launch $url';
  }
}
