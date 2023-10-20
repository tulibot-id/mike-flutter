import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatBubbleClipperR extends CustomClipper<Path> {

  final double radius;

  ChatBubbleClipperR({this.radius = 15});

  @override
  Path getClip(Size size) {
    var path = Path();

    path.addRRect(RRect.fromLTRBR(
        0, 0, size.width, size.height, Radius.circular(radius)));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
