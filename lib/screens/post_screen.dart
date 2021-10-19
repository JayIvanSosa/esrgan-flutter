import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/post.dart';
import '../widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String imageId;

  PostScreen({required this.userId, required this.imageId});

  final postsRef = FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef.doc(userId).collection('userPosts').doc(imageId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post =
            Post.fromDocument(snapshot.data as DocumentSnapshot<Object>);
        return Center(
          child: Scaffold(
            appBar: AppBar(
              leading: InkWell(
                child: Icon(Icons.arrow_back_ios),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              title: Text("Enhanced Image"),
            ),
            backgroundColor: Color(0xffffffff),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
