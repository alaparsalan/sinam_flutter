
import 'package:flutter/material.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/models/city_model.dart';
import 'package:sinam/models/currency_exchange_rate_model.dart';
import 'package:sinam/models/currency_model.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/init_model.dart';
import 'package:sinam/models/operator_model.dart';
import 'package:sinam/models/operator_ussd_model.dart';
import 'package:sinam/models/payment_number_model.dart';
import 'package:sinam/services/services.dart';

class InitViewModel extends ChangeNotifier{

  final Storage storage = Storage();

  InitModel? _initModel;
  InitModel? get initModel => _initModel;

  DictionaryModel? _dictionaryModel;
  DictionaryModel? get dictionaryModel => _dictionaryModel;

  String? _token;
  String? get token => _token;

  String? get customerID {
    return initModel?.customerId;
  }

  String? get customerName {
    return initModel?.customerName;
  }

  String? get customerGivenName {
    return initModel?.customerGivenName;
  }

  String? get customerEmail {
    return initModel?.customerEmail;
  }

  String? get customerNumber {
    return initModel?.customerPhoneNumber;
  }

  String? get customerPhonePrefix {
    return initModel?.customerPhonePrefix;
  }

  double? get customerBalance {
    return initModel?.customerBalance;
  }

  String? get customerSelectedCurrencySymbol {
    return initModel?.customerSelectedCurrencySymbol;
  }

  String? get customerSelectedCurrencyCode {
    return initModel?.customerSelectedCurrencyCode;
  }

  List<CurrencyExchangeRateModel>? get currencyExchangeRate {
    return initModel?.currencyExchangeRate;
  }

  String? get customerCountryCode {
    return initModel?.customerCountryCode;
  }

  String? get helpUrl {
    return initModel?.helpUrl;
  }

  String? get supportEmail {
    return initModel?.supportEmail;
  }

  String? get supportPhone {
    return initModel?.supportPhone;
  }

  String? get facebookUrl {
    return initModel?.facebookUrl;
  }

  String? get termsUrl {
    return initModel?.termsUrl;
  }

  String? get connectionErrorEn {
    return initModel?.conexionErrorEn;
  }

  String? get connectionErrorFr {
    return initModel?.conexionErrorFr;
  }

  String? get getTermsUrl {
    return initModel?.termsUrl;
  }

  List<CityModel>? get cities {
    return initModel?.cities;
  }

  List<CurrencyModel>? get currencies {
    return initModel?.currencies;
  }

  void setToken(String value) {
    _token = value;
  }

  void setInitModel(InitModel? model){
    _initModel = model;
    notifyListeners();
  }

  void setDictionaryModel(DictionaryModel? model){
    _dictionaryModel = model;
    notifyListeners();
  }

  void setCustomerName(String? value){
    initModel?.customerName = value;
    initModel?.customerGivenName = value;
    notifyListeners();
  }

  void setCustomerID(String value) {
    initModel?.customerId = value;
  }

  void setCustomerSelectedCurrencySymbol(String value) {
    initModel?.customerSelectedCurrencySymbol = value;
  }

  Future<dynamic> getInit(BuildContext context, String? customerID) async {
    Map<String, dynamic> postData = {
      'customer_id': customerID,
      'api_key': AppConfig.apiKey,
      'country_code': !AppConfig.isPublished ? 'TG' : AppConfig.isoCountryCode,
    };

    if(AppConfig.simData!.cards.length == 1){
      postData['sim1_name'] = AppConfig.simData!.cards[0].carrierName;
    }else if(AppConfig.simData!.cards.length == 2){
      postData['sim1_name'] = AppConfig.simData!.cards[0].carrierName;
      postData['sim2_name'] = AppConfig.simData!.cards[1].carrierName;
    }

    try{
      dynamic result = await Services().post(context: context, isInit: true, endPoint: 'Mobile/init', postData: postData);
      _initModel = InitModel.fromJson(result);

      if(_initModel != null && (_initModel!.customerPhoneNumber != null && _initModel!.customerPhoneNumber != '')){
        storage.saveString('phone_number', _initModel!.customerPhoneNumber!);
      }

      if((_initModel != null && (_initModel!.conexionErrorFr != null && _initModel!.conexionErrorFr != ''))){
        AppConfig.connectionErrorFr = _initModel!.conexionErrorFr;
      }

      if((_initModel != null && (_initModel!.conexionErrorEn != null && _initModel!.conexionErrorEn != ''))){
        AppConfig.connectionErrorEn = _initModel!.conexionErrorEn;
      }

      if(_initModel != null){
        storage.saveString('init', _initModel!.toJson());
      }

      notifyListeners();
      return true;
    }catch(error){
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> login(BuildContext context, {String? email, String? prefix, String? phone, required String password}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'email': email,
      'phone_prefix': prefix,
      'phone_number': phone,
      'password': password,
    };

    try {
      final result = await Services().post(isInit: true, endPoint: 'Mobile/login', context: context, postData: postData);
      if(result != null){
        storage.saveString('customer_id', result['customer_id']);
        storage.saveString('access_token', result['access_token']);
        storage.saveString('name', result['username']);

        if(email != null){ storage.saveString('email', email); }
        if(phone != null){ storage.saveString('phone_number', phone); }
        if(prefix != null){ storage.saveString('phone_prefix', prefix); }

        storage.saveBool('is_login', true);
        notifyListeners();
        return true;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> changePassword(BuildContext context, { required String oldPass, required String newPass}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'customer_id': customerID,
      'old_password': oldPass,
      'new_password': newPass,
    };
    try {
      final result = await Services().post(context: context, endPoint: 'Mobile/ChangePassword', postData: postData);
      if(result != null){
        return result;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> resetPassword(BuildContext context, { required String email}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'customer_id': customerID,
      'email': email,
    };

    try {
      final result = await Services().post(context: context, endPoint: 'Mobile/ResetPassword', postData: postData, isInit: true);
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

  Future<dynamic> updateProfile(BuildContext context, { required dynamic postData}) async {
    try {
      final result = await Services().post(context: context, endPoint: 'Mobile/UpdateProfile', postData: postData);
      if(result != null){
        return result;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> totpConfirm(BuildContext context, {required String totpCode, required String accessToken1fa}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'totp_code': totpCode,
      'access_token_1fa': accessToken1fa,
    };

    try {
      final result = await Services().post(isInit: true, context: context, endPoint: 'Mobile/TotpConfirm', postData: postData);
      if(result != null){
        storage.saveString('access_token', result['access_token']);
        storage.saveString('name', result['username']);
        storage.saveBool('first_confirm', true);
        notifyListeners();
        return true;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> webOtpCheck(BuildContext context, {required String totpCode, required String prefix, required String phone}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'totp_code': totpCode,
      'phone_prefix': prefix,
      'phone_number': phone,
    };

    try {
      final result = await Services().post(isInit: true, context: context, endPoint: 'Mobile/WebOtpCheck', postData: postData);
      if(result != null){
        storage.saveString('access_token', result['access_token']);
        storage.saveString('name', result['username']);
        storage.saveBool('first_confirm', true);
        notifyListeners();
        return true;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> totpResend(BuildContext context, {required String phonePrefix, required String phoneNumber}) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'phone_prefix': phonePrefix,
      'phone_number': phoneNumber,
    };

    try {
      final result = await Services().post(isInit: true, context: context, endPoint: 'Mobile/WebOtpCheck', postData: postData);
      if(result != null){
        AppConfig.resendTotpCodeWaitTime = result['wait_time'];
        return true;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> registration(BuildContext context, {required String email, required String prefix, required String phone, required String password,
    required String language, String? sexCode, required String name, String? city, required currencyCode
    }) async {
    Map<String, dynamic> postData = {
      'country_code': AppConfig.isoCountryCode,
      'password': password,
      'email': email,
      'api_key': AppConfig.apiKey,
      'phone_prefix': prefix,
      'phone_number': phone,
      'language': language,
      'imei_code': AppConfig.imei,
      'mobile_operator': AppConfig.carrierName,
      'sex_code': sexCode,
      'name': name,
      'given_name': name,
      'city': city,
      'currency_code': currencyCode,
    };

    try {
      final result = await Services().post(isInit: true, context: context, endPoint: 'Mobile/registration', postData: postData);
      if(result != null){
        storage.saveString('customer_id', result['customer_id']);
        storage.saveString('access_token_1fa', result['access_token_1fa']);

        storage.saveString('email', email);
        storage.saveString('phone_number', phone);
        storage.saveString('phone_prefix', prefix);
        storage.saveString('name', name);

        AppConfig.resendTotpCodeWaitTime = result['wait_time'];

        Map<String, dynamic> response = {
          'wait_time': result['wait_time'],
          'access_token_1fa': result['access_token_1fa'],
          'message': result['message'],
        };

        storage.saveBool('is_login', true);
        storage.saveBool('first_confirm', false);
        notifyListeners();
        return response;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> logout(BuildContext context) async {
    try {
      String? phone = await storage.getString('phone_number');
      String? prefix = await storage.getString('phone_prefix');

      if(phone != null && prefix != null && token != null){
        Map<String, dynamic> postData = {
          'api_key': AppConfig.apiKey,
          'phone_prefix': prefix,
          'phone_number': phone,
        };

        final result = await Services().post(context: context, endPoint: 'logout', postData: postData);
        if(result != null){
          storage.saveBool('is_login', false);
          notifyListeners();
          return true;
        }else{
          return false;
        }
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> getDictionary(BuildContext context, String? customerID) async {
    Map<String, dynamic> postData = {
      'api_key': AppConfig.apiKey,
      'customer_id': customerID,
      'country_code': !AppConfig.isPublished ? 'TG' : AppConfig.isoCountryCode
    };

    try {
      final result = await Services().post(isInit: true, context: context, endPoint: 'Mobile/GetDictionary', postData: postData);
      print(result);
      if(result != null){
        _dictionaryModel = DictionaryModel.fromJson(result);
        if(_dictionaryModel != null){
          storage.saveString('dictionary', _dictionaryModel!.toJson());
        }
        notifyListeners();
        return true;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }

  Future<dynamic> confirmMobilePayment(BuildContext context, { String? customerID, PaymentNumberModel? selectedNumberList, String? amount, String? date }) async {

    Map<String, dynamic>? postData;
    if(AppConfig.confirmPaymentSt = true && AppConfig.confirmPaymentPostData != null){
      postData = AppConfig.confirmPaymentPostData;
    }else{
      postData = {
        'api_key':        AppConfig.apiKey,
        'customer_id':    customerID,
        'country_code':   selectedNumberList!.countryCode,
        'operator_id':    selectedNumberList.operatorCode,
        'number':         selectedNumberList.number,
        'amount':         amount,
        'payment_date':   date
      };
    }

    AppConfig.confirmPaymentPostData = postData;

    try {
      final result = await Services().post(context: context, endPoint: 'Mobile/ConfirmMobilePayment', postData: postData);
      if(result != null){
        return result;
      }else{
        return false;
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
      return error.toString();
    }
  }
}