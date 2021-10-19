import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esrgan_flutter2_ocean_app/screens/gallery_screen.dart';
import 'package:esrgan_flutter2_ocean_app/screens/home_screen.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/snackbar.dart';
//import 'package:esrgan_flutter2_ocean_app/screens/gallery_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';

final Reference storageRef = FirebaseStorage.instance.ref();
//final postsRef = Firestore.instance.collection('posts');

final postsRef = FirebaseFirestore.instance.collection('posts');
var timestamp;

class ImageView extends StatefulWidget {
  final User user;
  final File image;
  final File orgImage;

  ImageView({required this.image, required this.orgImage, required this.user});

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  double controller = 0.5;
  var newImage;

  Future<void> uploadImage() async {
    showSnackBar(context, "Saving image please wait...", Colors.blue, 5000);
    String postId =
        widget.user.uid + "_" + timestamp.toString().split(' ').join();
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(widget.image);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    createPostInFirestore(mediaUrl: downloadUrl);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => imageSaved(
            context, "Image has been successfully saved to your account.", 1));
  }

  createPostInFirestore({
    required String mediaUrl,
  }) {
    postsRef
        .doc(widget.user.uid)
        .collection("userPosts")
        .doc(widget.user.uid + "_" + timestamp.toString().split(' ').join())
        .set({
      "imageId": widget.user.uid + "_" + timestamp.toString().split(' ').join(),
      "userId": widget.user.uid,
      "ownerId": widget.user.email,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
    });
  }

  @override
  void initState() {
    setState(() {
      timestamp = DateTime.now();
      print("TIMESTAMP: " + timestamp.toString());
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TensorImage imgProp = TensorImage.fromFile(widget.image);

    Widget btnUploadToFirebase = Container(
      child: TextButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xff3765f8))),
          onPressed: () => {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Save Image'),
                          content: const Text(
                              'Do you want to save this image in the cloud?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(), //Navigator.pop(context, 'Cancel'),

                              child: const Text(
                                'No',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: uploadImage,
                              child: const Text('Yes'),
                            ),
                          ],
                        ))
              },
          icon: FaIcon(
            FontAwesomeIcons.cloudDownloadAlt,
            color: Colors.white,
          ),
          label: Text("Save Image",
              style: TextStyle(
                color: Colors.white,
              ))),
    );

    Widget btnSaveImageToDevice = Container(
      child: TextButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xff3765f8))),
          onPressed: () => {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Export Image'),
                          content: const Text(
                              'Do you want to export this image to your device?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'No',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                GallerySaver.saveImage(widget.image.path);
                                print('Saved');
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => imageSaved(
                                        context,
                                        "Image has been successfully exported to your device.",
                                        0));
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        ))
              },
          icon: FaIcon(
            FontAwesomeIcons.fileExport,
            color: Colors.white,
          ),
          label: Text("Export Image",
              style: TextStyle(
                color: Colors.white,
              ))),
    );

    return Scaffold(
        appBar: AppBar(
          leading: Container(
              margin: EdgeInsets.only(left: 5),
              padding: EdgeInsets.all(2),
              child: Image.asset(
                "assets/images/esrganFlutterLogo.png",
                fit: BoxFit.cover,
                //height: 10
              )),
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF001e36),
          title: Text('Enhanced Image'),
          actions: [
            IconButton(
              icon: FaIcon(FontAwesomeIcons.times),
              onPressed: () {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Discard Image'),
                          content:
                              const Text('Do you want to discard the image?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'No',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen(
                                            user: widget.user,
                                            screenIndex: 0)));
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              child: PhotoView.customChild(
                minScale: PhotoViewComputedScale.contained * 0.8,
                initialScale: PhotoViewComputedScale.contained,
                enableRotation: true,
                childSize:
                    Size(imgProp.width.toDouble(), imgProp.height.toDouble()),
                child: Container(
                  child: Stack(
                    children: [
                      Container(
                        height: imgProp.height.toDouble(),
                        width: imgProp.width.toDouble(),
                        child: Image.file(
                          widget.image,
                          height: imgProp.height.toDouble(),
                          alignment: Alignment.topLeft,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      AnimatedContainer(
                          duration: Duration(milliseconds: 1),
                          height: imgProp.height.toDouble(),
                          width: imgProp.width.toDouble() * controller,
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 4.0, color: Colors.black))),
                          child: Container(
                              child: Image.file(
                            widget.orgImage,
                            alignment: Alignment.topLeft,
                            fit: BoxFit.cover,
                          ))),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: 50,
                left: 10,
                right: 10,
                bottom: 5,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  "BEFORE",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.longArrowAltRight,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "|",
                            style: TextStyle(color: Colors.white, fontSize: 50),
                          ),
                          Container(
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.longArrowAltLeft,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "AFTER",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            Positioned(
                left: 10,
                right: 10,
                bottom: 5,
                child: Column(
                  children: [
                    Slider(
                      value: controller,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (newVal) {
                        setState(() {
                          controller = newVal;
                        });
                      },
                    ),
                    Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          btnUploadToFirebase,
                          SizedBox(
                            width: 10,
                          ),
                          btnSaveImageToDevice,
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ));
  }

  AlertDialog imageSaved(context, String message, int pageIndex) {
    return AlertDialog(
      titlePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      title: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeScreen(user: widget.user, screenIndex: pageIndex)));
          },
          child: Text('Ok'),
        ),
      ],
    );
  }
}
