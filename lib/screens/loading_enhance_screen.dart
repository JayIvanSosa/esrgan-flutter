import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:esrgan_flutter2_ocean_app/screens/home_screen.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'image_view.dart';

class LoadingEnhanceScreen extends StatefulWidget {
  const LoadingEnhanceScreen(
      {Key? key,
      required User user,
      required File selectedImage,
      required String imgResolution})
      : _user = user,
        _selectedImage = selectedImage,
        _imgResolution = imgResolution;

  final User _user;
  final File _selectedImage;
  final String _imgResolution;

  @override
  _LoadingEnhanceScreenState createState() => _LoadingEnhanceScreenState();
}

class _LoadingEnhanceScreenState extends State<LoadingEnhanceScreen> {
  File? upscaledImage;
  String? message = "";
  bool isEnhancing = false;
  bool isEnhanced = false;
  final DateTime timestamp = DateTime.now();
  String serverUrl = "http://162.243.173.48:8080";

  _onTimeOut(BuildContext context) {
    showSnackBar(
        context,
        "Connection timeout, please try again or select another image.",
        Colors.red,
        7000);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomeScreen(user: widget._user, screenIndex: 0)));
  }

  uploadImage(BuildContext context) async {
    setState(() => isEnhancing = true);

    final request =
        http.MultipartRequest("POST", Uri.parse("$serverUrl/upload"));

    final headers = {
      "Content-type": "multipart/form-data",
      "Connection": "keep-alive"
    };

    request.files.add(http.MultipartFile(
        'image',
        widget._selectedImage.readAsBytes().asStream(),
        widget._selectedImage.lengthSync(),
        filename: widget._user.uid +
            "_input_image" +
            "_res_" +
            widget._imgResolution));

    request.headers.addAll(headers);

    Duration duration = const Duration(seconds: 60);
    try {
      final response = await request
          .send()
          .timeout(duration, onTimeout: () => _onTimeOut(context));
      http.Response res = await http.Response.fromStream(response);
      final resJson = jsonDecode(res.body);
      message = resJson['result'];
      upscaledImage = await _fileFromImageUrl(message!);

      setState(() => isEnhanced = true);
      if (isEnhanced) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ImageView(
                    image: upscaledImage!,
                    orgImage: widget._selectedImage,
                    user: widget._user,
                  )),
        );
      }
    } catch (e) {
      print(e);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(user: widget._user, screenIndex: 0)));

      showSnackBar(
          context,
          "The connection to the server has timed out, please try to again or select another image.",
          Colors.red,
          5000);
    }
  }

  Future<File> _fileFromImageUrl(String imageUrl) async {
    Uri url = Uri.parse('$serverUrl/download/' + imageUrl);
    print("Downloading from this url: " + url.toString());
    final response = await http.get(url);

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(join(documentDirectory.path,
        'imagetest' + timestamp.toString().split(' ').join() + '.png'));

    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  @override
  void initState() {
    uploadImage(this.context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCubeGrid(
            color: Colors.blue,
            size: 80.0,
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 250.0,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 17.0,
                fontFamily: 'Agne',
              ),
              child: AnimatedTextKit(
                totalRepeatCount: 10,
                animatedTexts: [
                  TypewriterAnimatedText('Enhancing image, please wait...'),
                ],
                onTap: () {
                  print("Tap Event");
                },
              ),
            ),
          )
        ],
      ),
    ));
  }
}
