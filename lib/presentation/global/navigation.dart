import 'package:flutter/material.dart';

Future<T?> changeScreen<T>(BuildContext context, Widget widget) {
  return Navigator.push<T>(context, MaterialPageRoute(builder: (context) => widget));
}

void changeScreenReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => widget));
}

void changeScreenUntill(BuildContext context, Widget widget) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false);
}

void changeScreenForAuth(BuildContext context, Widget widget) {
  // Use pushReplacement for authentication flows to avoid navigation stack issues
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => widget));
}
