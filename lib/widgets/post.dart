// import 'package:intl/intl.dart';
// import 'package:blackfox/pages/activity_feed.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'
//     as mdi;
// import '../models/user.dart';

// import '../pages/home.dart';

import 'package:esrgan_flutter2_ocean_app/screens/home_screen.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
//import 'package:esrgan_flutter2_ocean_app/widgets/scaler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

//import '../widgets/progress.dart';
final Reference storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');

class Post extends StatefulWidget {
  final String imageId;
  final String mediaUrl;
  final String ownerId;
  final Timestamp timestamp;
  final String userId;

  Post(
      {required this.imageId,
      required this.mediaUrl,
      required this.ownerId,
      required this.timestamp,
      required this.userId});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      imageId: doc['imageId'],
      mediaUrl: doc['mediaUrl'],
      ownerId: doc['ownerId'],
      timestamp: doc['timestamp'],
      userId: doc['userId'],
    );
  }

  @override
  _PostState createState() => _PostState(
        ownerId: this.ownerId,
        timestamp: this.timestamp,
        imageId: this.imageId,
        userId: this.userId,
        mediaUrl: this.mediaUrl,
      );
}

class _PostState extends State<Post> {
  final String imageId;
  final String mediaUrl;
  final String ownerId;
  final Timestamp timestamp;
  final String userId;

  _PostState(
      {required this.imageId,
      required this.mediaUrl,
      required this.ownerId,
      required this.timestamp,
      required this.userId});

  User? user = FirebaseAuth.instance.currentUser;

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably

  String imgFileSize = "";
  String imgResolution = "";
  var imgSize;
  late File imageFile;

  String getFileSize(int fileSize) {
    double kb = fileSize / 1000;
    if (kb > 1000) {
      return (kb /= 1000).toStringAsFixed(2) + " mb";
    } else {
      return kb.toStringAsFixed(2) + " kb";
    }
  }

  String getImageResolution(String imgSize) {
    var imgRes = imgSize.split(" ");
    var height = imgRes[1].split(",");
    var width = imgRes[2];

    return height[0] + "x" + width;
  }

  Future<void> _fileFromImageUrl() async {
    final response = await http.get(Uri.parse(mediaUrl));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(join(documentDirectory.path, 'imagetest.png'));

    file.writeAsBytesSync(response.bodyBytes);
    imageFile = file;

    imgSize = ImageSizeGetter.getSize(FileInput(file));

    var fileSize = await file.length();

    imgFileSize = getFileSize(fileSize);
    imgResolution = getImageResolution(imgSize.toString());
    setState(() {});
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print('liking post'),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 410.0,
            height: 400.0,
            child: Image.network(
              mediaUrl,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog<String>(
        context: parentContext,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete Image'),
              content: const Text('Do you want to delete the photo?'),
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
                  onPressed: () async {
                    Navigator.pop(context);

                    showSnackBar(
                        context,
                        "Imaged has been removed to your device.",
                        Colors.red,
                        3000);
                    await deletePost();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(user: user!, screenIndex: 1)));
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    // delete post itself
    postsRef
        .doc(widget.userId)
        .collection('userPosts')
        .doc(widget.imageId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    storageRef.child("post_$imageId.jpg").delete();
  }

  handleSaveImageToGallery(BuildContext parentContext) {
    showDialog<String>(
        context: parentContext,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Export Image'),
              content: const Text(
                  'Do you want to export this image to your device?'),
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
                  onPressed: () {
                    Navigator.pop(context);
                    showSnackBar(
                        context,
                        "Imaged successfully saved to your device.",
                        Colors.green,
                        3000);
                    GallerySaver.saveImage(imageFile.path);
                    print('Saved');
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  Widget btnSaveImageToGallery(BuildContext parentContext) {
    return Container(
        margin: EdgeInsets.only(top: 12),
        child: TextButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xff3865f8))),
            onPressed: () =>
                handleSaveImageToGallery(parentContext), //getImage,
            icon: FaIcon(FontAwesomeIcons.fileExport, color: Colors.white),
            label: Text("Export Image",
                style: TextStyle(
                  color: Colors.white,
                ))));
  }

  Widget btnDeleteImage(BuildContext parentContext) {
    return Container(
        margin: EdgeInsets.only(top: 12),
        child: TextButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFFcc0000))),
            onPressed: () => handleDeletePost(parentContext), //getImage,
            icon: FaIcon(FontAwesomeIcons.trashAlt, color: Colors.white),
            label: Text("Delete Image",
                style: TextStyle(
                  color: Colors.white,
                ))));
  }

  void initState() {
    _fileFromImageUrl();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Divider(
          color: Colors.grey[600],
        ),
        buildPostImage(),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Image Resolution: " + imgResolution,
                  style: TextStyle(color: Colors.black87)),
              Text("File Size: " + imgFileSize,
                  style: TextStyle(color: Colors.black87)),
            ],
          ),
        ),
        Divider(
          color: Colors.grey[600],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            btnDeleteImage(context),
            btnSaveImageToGallery(context),
          ],
        )
      ],
    );
  }
}
