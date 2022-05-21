import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({Key? key}) : super(key: key);
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> with SingleTickerProviderStateMixin {

  AnimationController? controller;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller!, curve: Curves.linearToEaseOut);

    controller!.addListener(() {
      setState(() {});
    });

    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: SizedBox(
          width: ScreenUtil().setWidth(350),
          child: ScaleTransition(
            scale: scaleAnimation!,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: ScreenUtil().setHeight(100),
                    child: Stack(
                      children: <Widget>[
                        Container(
                            padding: const EdgeInsets.only(right: 15, left: 25),
                            width: double.infinity,
                            height: ScreenUtil().setHeight(100),
                            color: Colors.white,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(AppLocalizations.of(context)!.translate('please_wait'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], overflow: TextOverflow.clip), textScaleFactor: 1.0, maxLines: 1),
                                  /*SizedBox(width: 15),
                                  Image.asset('assets/images/app_icon.png', width: 80)*/
                                ],
                              ),
                            )
                        ),
                        Positioned(bottom: 0, left: 0, right: 0, child: SizedBox(width: double.infinity, height: 3, child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[500]!))))
                      ],
                    ),
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }
}