import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar = PreferredSize(
    child: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFF001e36),
      leading: Container(
          margin: EdgeInsets.only(left: 5),
          padding: EdgeInsets.all(2),
          child: Image.asset("assets/images/esrganFlutterLogo.png",
              fit: BoxFit.cover, height: 75)),
    ),
    preferredSize: Size.fromHeight(60.0));
