import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {

  final Color color;

  LinePainter({ required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
    ..color = color
    ..strokeCap = StrokeCap.square
    ..strokeWidth = 1.5;
    _drawDashedLine(canvas, size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _drawDashedLine(Canvas canvas, Size size, Paint paint) {

    const int dashWidth = 8;
    const int dashSpace = 8;

    double startX = 0;
    double y = 10;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }
}