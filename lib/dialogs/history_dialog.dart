import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/success_dialog.dart';
import 'package:sinam/helpers/line_painter.dart';
import 'package:sinam/helpers/ticket_clipper.dart';

import '../helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class HistoryDialog extends StatefulWidget {

  final String? phoneNumber;
  final String? operator;
  final String? explain;
  final double? amount;
  final double? total;
  final double? serviceFee;
  final double? smsFee;
  final double? totalCharge;
  final String? currency;
  final String? countryCode;
  final String? paymentMethod;
  final String? status;
  final String  date;
  final String  transactionID;

  const HistoryDialog({ Key? key, this.phoneNumber, this.countryCode, required this.date,
                       this.operator, this.amount, this.explain, required this.transactionID,
                       this.totalCharge, this.paymentMethod, this.status, this.smsFee, this.serviceFee, this.currency,
                       this.total
  }) : super(key: key);
  @override
  _HistoryDialogState createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<HistoryDialog> with SingleTickerProviderStateMixin {

  AnimationController? controller;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller!, curve: Curves.linearToEaseOut);
    controller!.addListener(() {setState(() {});});
    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: SizedBox(
        width: AppConfig.screenWidth - ScreenUtil().setWidth(30),
        child: ScaleTransition(
          scale: scaleAnimation!,
          child: Dialog(
            insetPadding: const EdgeInsets.all(10),
            backgroundColor: Colors.transparent,
            child: ClipPath(
              clipper: TicketClipper(holeRadius: 40, bottom: widget.phoneNumber != null ? 430 : 310),
              child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Center(child: Text(AppLocalizations.of(context)!.translate('transaction'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]), textScaleFactor: 1.0)),
                            const SizedBox(height: 10),
                            Center(child: Text(widget.transactionID, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[500]), textScaleFactor: 1.0)),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.maxFinite,
                              height: 20,
                              child: CustomPaint(
                                painter: LinePainter(color: Colors.grey[300]!),
                              ),
                            ),
                            if(widget.phoneNumber != null) ...[
                              const SizedBox(height: 20),
                              Text(AppLocalizations.of(context)!.translate('sent_to'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                              const SizedBox(height: 5),
                              Text(widget.phoneNumber!, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.translate('date'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                const SizedBox(height: 5),
                                Text(widget.date, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if(widget.operator != null) ...[
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.translate('operator'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                  const SizedBox(height: 5),
                                  Text(widget.operator!, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                            if(widget.explain != null) ...[
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.translate('explain'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                  const SizedBox(height: 5),
                                  Text(widget.explain!, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if(widget.paymentMethod != null) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppLocalizations.of(context)!.translate('payment_method'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                      const SizedBox(height: 5),
                                      Text(widget.paymentMethod!, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                                const SizedBox(width: 20),
                                if(widget.status != null) ...[
                                  SizedBox(
                                    width: 110,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(AppLocalizations.of(context)!.translate('status'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                        const SizedBox(height: 5),
                                        Text(widget.status!, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if(widget.serviceFee != null) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppLocalizations.of(context)!.translate('service_fee'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(AppConfig.numberFormat.format(widget.serviceFee!), style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 3),
                                          Text(widget.currency!, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis), maxLines: 1,),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(width: 20),
                                if(widget.smsFee != null) ...[
                                  SizedBox(
                                    width: 110,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(AppLocalizations.of(context)!.translate('sms_fee'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(AppConfig.numberFormat.format(widget.smsFee!), style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 3),
                                            Expanded(child: Text(widget.currency!, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis), maxLines: 1,)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if(widget.totalCharge != null) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppLocalizations.of(context)!.translate('total_charge'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(AppConfig.numberFormat.format(widget.totalCharge!), style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 3),
                                          Text(widget.currency!, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis), maxLines: 1,),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(width: 20),
                                if(widget.total != null) ...[
                                  SizedBox(
                                    width: 110,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(AppLocalizations.of(context)!.translate('amount'), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(AppConfig.numberFormat.format(widget.total!), style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 3),
                                            Expanded(child: Text(widget.currency!, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis), maxLines: 1,)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
            ),
          ),
        ),
      ),
    );
  }
}