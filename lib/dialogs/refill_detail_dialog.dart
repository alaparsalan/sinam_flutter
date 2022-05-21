import 'package:intl/intl.dart';
import 'package:sinam/dialogs/success_dialog.dart';
import 'package:sinam/helpers/line_painter.dart';
import 'package:sinam/helpers/ticket_clipper.dart';

import '../helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class RefillDetailDialog extends StatefulWidget {

  final String amount;
  final Function() onCardsOrPaypalClicked;

  const RefillDetailDialog({ Key? key, required this.amount, required this.onCardsOrPaypalClicked }) : super(key: key);
  @override
  _RefillDetailDialogState createState() => _RefillDetailDialogState();
}

class _RefillDetailDialogState extends State<RefillDetailDialog> with SingleTickerProviderStateMixin {

  AnimationController? controller;
  Animation<double>? scaleAnimation;
  DateTime now = DateTime.now();
  var inputFormat = DateFormat('dd-MM-yyyy');

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
          width: MediaQuery.of(context).size.width - 30,
          child: ScaleTransition(
            scale: scaleAnimation!,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: ClipPath(
                clipper: TicketClipper(holeRadius: 40, bottom: 372),
                child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Center(child: Text(AppLocalizations.of(context)!.translate('wallet_refill'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[600]), textScaleFactor: 1.0)),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.maxFinite,
                                height: 20,
                                child: CustomPaint(
                                  painter: LinePainter(color: Colors.grey[300]!),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.translate('date'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                  const SizedBox(height: 5),
                                  Text(inputFormat.format(now).toString(), style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),

                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.translate('amount'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                  const SizedBox(height: 5),
                                  Text(widget.amount, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),

                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(AppLocalizations.of(context)!.translate('explain'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                        const SizedBox(height: 5),
                                        Text(AppLocalizations.of(context)!.translate('wallet_refill'), style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Text(AppLocalizations.of(context)!.translate('payment_method'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => widget.onCardsOrPaypalClicked(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: Text(AppLocalizations.of(context)!.translate('card_payment')),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.amber[700],
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15), // <-- Radius
                                        ),
                                      ),
                                    )
                                  ),
                                ],
                              )
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
                            child: Text(AppLocalizations.of(context)!.translate('cancel'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[500]), textAlign: TextAlign.center)
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}