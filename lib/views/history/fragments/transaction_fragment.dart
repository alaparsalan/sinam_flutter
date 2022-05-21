import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/history_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/models/transaction_history_model.dart';

class TransactionFragment extends StatefulWidget {
  final List<TransactionHistoryModel> historyList;
  final String? selectedService;

  const TransactionFragment({Key? key, required this.historyList, this.selectedService}) : super(key: key);

  @override
  _TransactionFragmentState createState() => _TransactionFragmentState();
}

class _TransactionFragmentState extends State<TransactionFragment> with AutomaticKeepAliveClientMixin<TransactionFragment> {

  @override
  Widget build(BuildContext context) {
    return widget.historyList.isEmpty ? notFoundView() : FadingEdgeScrollView.fromListView(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        physics: const BouncingScrollPhysics(),
        controller: ScrollController(),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              showDialog(context: context, builder: (context) => HistoryDialog(
                phoneNumber: widget.historyList[index].destinationNumber,
                operator: widget.historyList[index].operatorName!,
                //amount: widget.historyList[index].amount,
                paymentMethod: widget.historyList[index].paymentMethod,
                serviceFee: widget.historyList[index].serviceFee,
                smsFee: widget.historyList[index].smsFee,
                total: widget.historyList[index].totalToReceiver,
                totalCharge: widget.historyList[index].totalCharge,
                currency: widget.historyList[index].receiverCurrency,
                status: widget.historyList[index].processStatus,
                date: DateFormat.yMMMd().add_jm().format(HttpDate.parse(widget.historyList[index].transactionDate).toLocal()),
                transactionID: widget.historyList[index].orderId,
              ));
            },
            child: historyItem(
              AppConfig.selectedLanguage == 'en' ? widget.historyList[index].serviceEn : widget.historyList[index].servicdeFr,
              DateFormat.yMMMd().add_jm().format(HttpDate.parse(widget.historyList[index].transactionDate).toLocal()),
              AppConfig.numberFormat.format(widget.historyList[index].totalToReceiver),
              widget.historyList[index].receiverCurrency,
              widget.historyList[index].processStatus != null ? '(${widget.historyList[index].processStatus})' : '',
            ),
          );
        },
        separatorBuilder: (context, itemIndex) => Divider(height: 1, thickness: 1, color: Colors.grey[300]!),
        itemCount: widget.historyList.length
      )
    );

  }
  Widget historyItem(String service, String date, String amount, String currency, String status){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      width: double.maxFinite,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(amount, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                  const SizedBox(width: 3),
                  Text(currency, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ],
          ),
          Text(status, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget notFoundView(){
    return Center(
        child: FadeInUp(
          from: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Opacity(opacity: 0.4, child: Image.asset('assets/images/notfound.png', width: MediaQuery.of(context).size.width / 1.7)),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.translate('nothing_to_show'), style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            ],
          ),
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
