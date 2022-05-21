import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool submitSt;
  final GlobalKey<InnerDrawerState>? innerDrawerKey;
  final Widget? actionButton;

  const CustomAppBar({Key? key, required this.title, required this.submitSt, this.innerDrawerKey, this.actionButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 40, height: 40, child: TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero
            ),
            onPressed: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              if(submitSt){ Navigator.pop(context); }
            },
            child: const Icon(Icons.keyboard_arrow_left, size: 35, color: Colors.black))
        ),
        Expanded(child: Text(title, style: const TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        if(innerDrawerKey != null)
        SizedBox(width: 40, height: 40, child: TextButton(
            onPressed: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              if(innerDrawerKey != null){ innerDrawerKey!.currentState!.toggle(); }
            },
            child: const Icon(Icons.menu, size: 25, color: Colors.black)
        )),
        if(actionButton != null)
        actionButton!
      ],
    );
  }
}
