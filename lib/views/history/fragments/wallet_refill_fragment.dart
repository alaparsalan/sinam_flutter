import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/history_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/models/wallet_refill_history_model.dart';

class WalletRefillFragment extends StatefulWidget {

  final List<WalletRefillHistoryModel> walletList;

  const WalletRefillFragment({Key? key, required this.walletList}) : super(key: key);

  @override
  _WalletRefillFragmentState createState() => _WalletRefillFragmentState();
}

class _WalletRefillFragmentState extends State<WalletRefillFragment> with AutomaticKeepAliveClientMixin<WalletRefillFragment> {
  @override
  Widget build(BuildContext context) {
    return widget.walletList.isEmpty ? notFoundView() : FadingEdgeScrollView.fromListView(
      child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          physics: const BouncingScrollPhysics(),
          controller: ScrollController(),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async{
                await Future.delayed(const Duration(milliseconds: 250));
                showDialog(context: context, builder: (context) => HistoryDialog(
                  //amount: widget.walletList[index].amountOfDeposit,
                  paymentMethod: widget.walletList[index].paymentMethod,
                  serviceFee: widget.walletList[index].serviceFee,
                  smsFee: widget.walletList[index].smsFee,
                  totalCharge: widget.walletList[index].totalCharge,
                  currency: widget.walletList[index].receiverCurrency,
                  date: DateFormat.yMMMd().add_jm().format(HttpDate.parse(widget.walletList[index].transactionDate).toLocal()),
                  transactionID: widget.walletList[index].orderId,
                ));
              },
              child: historyItem(
                widget.walletList[index].paymentMethod + ' Recharge',
                DateFormat.yMMMd().add_jm().format(HttpDate.parse(widget.walletList[index].transactionDate).toLocal()),
                AppConfig.numberFormat.format(widget.walletList[index].totalCharge),
                widget.walletList[index].receiverCurrency,
              ),
            );
          },
          separatorBuilder: (context, itemIndex) => Divider(height: 1, thickness: 1, color: Colors.grey[300]!),
          itemCount: widget.walletList.length
      )
    );
  }
  Widget historyItem(String service, String date, String amount, String currency){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      width: double.maxFinite,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(amount, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                  const SizedBox(width: 3),
                  Text(currency, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.translate('detail'), style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward, color: Colors.grey[500]!, size: 20)
                ],
              )
            ],
          )
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
