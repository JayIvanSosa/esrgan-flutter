import 'package:flutter/material.dart';

void showSnackBar(
    BuildContext context, String message, Color color, int duration) {
  SnackBar snackBar = new SnackBar(
      backgroundColor: color,
      content: Text(message),
      duration: Duration(milliseconds: duration));

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
