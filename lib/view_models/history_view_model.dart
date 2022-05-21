
import 'package:flutter/material.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/models/transaction_history_model.dart';
import 'package:sinam/models/wallet_refill_history_model.dart';
import 'package:sinam/services/services.dart';

class HistoryViewModel extends ChangeNotifier{

  List<WalletRefillHistoryModel> _walletHistoryList = [];
  List<WalletRefillHistoryModel> get walletHistoryList => _walletHistoryList;

  List<TransactionHistoryModel> _transactionHistoryList = [];
  List<TransactionHistoryModel> get transactionHistoryList => _transactionHistoryList;

  void clearWalletHistory(){
    _walletHistoryList.clear();
    notifyListeners();
  }

  void clearTransactionHistory(){
    _transactionHistoryList.clear();
    notifyListeners();
  }

  void setWalletHistoryList(List<WalletRefillHistoryModel> list){
    _walletHistoryList = list;
    notifyListeners();
  }

  void setTransactionHistoryList(List<TransactionHistoryModel> list){
    _transactionHistoryList = list;
    notifyListeners();
  }

  Future<dynamic> getWalletRefillHistory(BuildContext context, { required String customerID, String? dateFrom, String? dateTo}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'customer_id': customerID, //'228-0725130'
      'date_from': dateFrom,
      'date_to': dateTo,
    };

    try{
      dynamic result = await Services().post(context: context, endPoint: 'Mobile/GetRefillHistory', postData: postData);
      if(result != null){
        return result.map<WalletRefillHistoryModel>((model) => WalletRefillHistoryModel.fromJson(model)).toList();
      }else{
        return false;
      }
    }catch(error){
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> getTransactionHistory(BuildContext context, { required String customerID, String? dateFrom, String? dateTo, String? service, String? transactionId}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'customer_id': customerID, //'228-0725130'
      'date_from': dateFrom,
      'date_to': dateTo,
      'service': service,
      'transaction_id': transactionId,
    };

    try {
      dynamic result = await Services().post(context: context, endPoint: 'Mobile/GetTransactionHistory', postData: postData);
      if(result != null){
        return result.map<TransactionHistoryModel>((model) => TransactionHistoryModel.fromJson(model)).toList();
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }
}