
import 'package:flutter/material.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/services/services.dart';

class WalletViewModel extends ChangeNotifier{

  Future<dynamic> createWalletPin(BuildContext context, { required String customerID, required String pin}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'customer_id': customerID,
      'pin': pin
    };

    try{
      dynamic result = await Services().post(context: context, endPoint: 'Mobile/CreateWalletPin', postData: postData);
      if(result != null){
        return result;
      }else{
        return false;
      }
    }catch(error){
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> changeWalletPin(BuildContext context, { required String customerID, required String oldPin, required String newPin}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'customer_id': customerID,
      'old_pin': oldPin,
      'new_pin': newPin,
    };

    try {
      dynamic result = await Services().post(context: context, endPoint: 'Mobile/ChangeWalletPin', postData: postData);
      if(result != null){
        return result;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error;
    }
  }

  Future<dynamic> addRefillNumber(BuildContext context, { required String customerID, required String countryCode, required String operatorID, required number}) async {
    Map<String, dynamic> postData = {
      'api_key':      AppConfig.apiKey,
      'customer_id':  customerID,
      'country_code': countryCode,
      'operator_id':  operatorID,
      'number':       number,
    };
    try {
      dynamic result = await Services().post(context: context, endPoint: 'Mobile/AddMobilePaymentNumber', postData: postData);
      if(result != null){
        return result;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error;
    }
  }
}