import 'package:intl/intl.dart';
import 'package:sinam/dialogs/success_dialog.dart';
import 'package:sinam/helpers/line_painter.dart';
import 'package:sinam/helpers/ticket_clipper.dart';

import '../helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class RechargeDetailDialog extends StatefulWidget {

  final String? name;
  final String phoneNumber;
  final String operator;
  final String? explain;
  final String amount;
  final String? countryCode;
  final Function() onPaypalClicked;
  final Function() onWalletClicked;

  const RechargeDetailDialog({ Key? key, this.name, required this.phoneNumber, this.countryCode,
                       required this.operator, required this.amount, this.explain, required this.onPaypalClicked,
                       required this.onWalletClicked }) : super(key: key);
  @override
  _RechargeDetailDialogState createState() => _RechargeDetailDialogState();
}

class _RechargeDetailDialogState extends State<RechargeDetailDialog> with SingleTickerProviderStateMixin {

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
                clipper: TicketClipper(holeRadius: 40, bottom: 428),
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
                              Center(child: Text(AppLocalizations.of(context)!.translate('recharge'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[600]), textScaleFactor: 1.0)),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.maxFinite,
                                height: 20,
                                child: CustomPaint(
                                  painter: LinePainter(color: Colors.grey[300]!),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(AppLocalizations.of(context)!.translate('phone'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(widget.name ?? widget.phoneNumber, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.translate('operator'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                  const SizedBox(height: 5),
                                  Text(widget.operator, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold, overflow: TextOverflow.fade)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppLocalizations.of(context)!.translate('date'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                      const SizedBox(height: 5),
                                      Text(inputFormat.format(now).toString(), style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
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
                                        Text(AppLocalizations.of(context)!.translate('recharge'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                        const SizedBox(height: 5),
                                        Text(widget.explain == null || widget.explain == '' ? 'Not set' : widget.explain!, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
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
                                      onPressed: () => widget.onPaypalClicked(),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                                        child: Text(AppLocalizations.of(context)!.translate('card_payment'), style: const TextStyle(fontSize: 12)),
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
                                  const SizedBox(width: 15),
                                  Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => widget.onWalletClicked(),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(AppLocalizations.of(context)!.translate('wallet'), style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white)),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.account_balance_wallet_outlined, color: Colors.white)
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: const Color(0xff0a59c4),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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