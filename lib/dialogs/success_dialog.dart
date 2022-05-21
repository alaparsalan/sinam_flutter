import '../helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class SuccessDialog extends StatefulWidget {

  final String title;
  final String? receiptNumber;

  const SuccessDialog({ Key? key, required this.title, this.receiptNumber }) : super(key: key);
  @override
  _SuccessDialogState createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> with SingleTickerProviderStateMixin {

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
          width: 360,
          child: ScaleTransition(
            scale: scaleAnimation!,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                children: [
                  Card(
                    margin: const EdgeInsets.only(top: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 25),
                              Center(child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), textScaleFactor: 1.0)),
                              if(widget.receiptNumber != null)
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Text(AppLocalizations.of(context)!.translate('receipt_number'), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                  const SizedBox(height: 5),
                                  Text(widget.receiptNumber!, style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        Divider(height: 1, color: Colors.grey[300], thickness: 1),
                        Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: 55,
                          child: TextButton(
                            onPressed: () async{
                              await Future.delayed(const Duration(milliseconds: 300));
                              if(mounted){ Navigator.pop(context); }
                            },
                            child: Text(AppLocalizations.of(context)!.translate('done'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[500]), textAlign: TextAlign.center)
                          ),
                        ),
                      ],
                    )
                  ),
                  Positioned(top:0, right:0, left:25, child: Image.asset('assets/images/success.png', width: 40, height: 40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}