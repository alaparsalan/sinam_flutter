import 'package:flutter/material.dart';

class Message {
  static void show(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      key: UniqueKey(),
      backgroundColor: Colors.grey[900]!.withAlpha(960),
      elevation: 0.0,
      content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
    ));
  }
}