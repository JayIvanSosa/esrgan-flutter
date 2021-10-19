import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/app_drawer.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/appbar_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/post.dart';
import '../widgets/post_tile.dart';
import '../widgets/progress.dart';

final postsRef = FirebaseFirestore.instance.collection('posts');

class Gallery extends StatefulWidget {
  Gallery({required this.user});

  final User user;

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  String postOrientation = "grid";
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getGalleryPosts();
  }

  getGalleryPosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await postsRef
        .doc(widget.user.uid)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildGalleryHeader() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Column(children: <Widget>[
            ClipOval(
                child: Material(
                    color: Colors.blue,
                    child: widget.user.photoURL != null
                        ? Image.network(
                            widget.user.photoURL!,
                            fit: BoxFit.fitHeight,
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 36, vertical: 26),
                            child: Text(widget.user.email.toString()[0],
                                style: TextStyle(
                                    fontSize: 32, color: Colors.white)),
                          ))),
            SizedBox(height: 8),
            widget.user.displayName != null
                ? Text(
                    widget.user.displayName!,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  )
                : Text(
                    widget.user.email.toString().split("@")[0],
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
          ]),
        ],
      ),
    );
  }

  buildGalleryPosts() {
    if (isLoading) {
      return circularProgress();
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar,
      backgroundColor: Color(0xFFEEEEEE),
      endDrawer: CustomAppDawer(user: widget.user),
      body: ListView(
        children: <Widget>[
          buildGalleryHeader(),
          Divider(
            color: Colors.grey,
          ),
          buildGalleryPosts(),
        ],
      ),
    );
  }
}
