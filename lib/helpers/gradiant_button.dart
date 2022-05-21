import 'package:flutter/material.dart';

class GradiantButton extends StatelessWidget {
  final String title;
  final Function() onPressed;
  final Color? startColor;
  final Color? endColor;
  final double? radius;
  final double? width;
  final double? height;
  const GradiantButton({Key? key, required this.title, required this.onPressed, this.startColor, this.endColor, this.radius, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 10.0),
      child: Container(
        width: width ?? 200,
        height: height ?? 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 10.0),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              startColor ?? const Color(0xff60b5df),
              endColor ?? const Color(0xff0d5bc6),
            ],
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.transparent, onSurface: Colors.transparent, shadowColor: Colors.transparent),
          onPressed: () => onPressed(),
          child: Center(child: Text(title, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        ),
      ),
    );
  }
}
