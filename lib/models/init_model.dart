import 'dart:convert';
import 'package:sinam/models/payment_number_model.dart';
import 'package:sinam/models/saved_number_model.dart';

import 'city_model.dart';
import 'currency_exchange_rate_model.dart';
import 'currency_model.dart';

class InitModel{
  String?                   customerId;
  int?                      customerStatus;
  int?                      customerInterMoney;
  int?                      customerInitCountryCode;
  int?                      customerRefreshData;
  String?                   customerNotification;
  int?                      customerVerified;
  String?                   customerDisabledMessage;
  double?                   customerBalance;
  int?                      customerPinCreated;
  int?                      customerForceOtp;
  String?                   customerCountryCode;
  String?                   customerName;
  String?                   customerGivenName;
  String?                   customerPhonePrefix;
  String?                   customerPhoneNumber;
  String?                   customerCity;
  String?                   customerDateOfBirth;
  String?                   customerAddress;
  String?                   customerSexCode;
  String?                   customerLanguage;
  String?                   customerEmail;
  String?                   customerSelectedCurrencyCode;
  String?                   customerSelectedCurrencySymbol;
  String?                   countryPrefix;
  String?                   notificationMessage;
  int?                      forceReinstall;
  int?                      countryChanged;
  int?                      internationalEnabled;
  int?                      nationalEnabled;
  double                    internalSendMoneyFee;
  int?                      selfRechargeEnabled;
  int?                      useBalanceEnabled;
  double                    internalRechargeFee;
  String                    profileUpdateUrl;
  String?                   supportPhone;
  String?                   socialNumber;
  String?                   supportEmail;
  String?                   helpUrl;
  String?                   facebookUrl;
  String?                   termsUrl;
  String?                   conexionErrorFr;
  String?                   conexionErrorEn;
  List<CurrencyModel>       currencies;
  List<CurrencyExchangeRateModel>       currencyExchangeRate;
  List<CityModel>           cities;
  List<SavedNumberModel>?   savedNumbers;
  List<PaymentNumberModel>? paymentNumbers;
  String?                   globalSim1Name;
  String?                   globalSim2Name;

  InitModel({ required this.customerId, required this.customerStatus, this.customerInterMoney, required this.customerVerified,
    this.customerDisabledMessage, required this.customerBalance, required this.customerForceOtp, this.customerInitCountryCode,
    required this.customerCountryCode, required this.customerName, required this.customerGivenName, this.customerRefreshData,
    required this.customerPhonePrefix, required this.customerPhoneNumber, required this.customerCity, this.customerNotification,
    this.customerDateOfBirth, this.customerAddress, required this.customerSexCode, required this.customerLanguage, this.customerPinCreated,
    required this.customerEmail, this.currencyExchangeRate = const [], this.countryPrefix, required this.countryChanged, required this.internationalEnabled, required this.nationalEnabled,
    required this.internalSendMoneyFee, required this.internalRechargeFee, required this.profileUpdateUrl, required this.currencies, required this.cities,
    this.supportPhone, this.socialNumber, this.supportEmail, this.helpUrl, this.facebookUrl, this.termsUrl, this.conexionErrorEn, this.conexionErrorFr,
    this.customerSelectedCurrencyCode, this.customerSelectedCurrencySymbol, this.savedNumbers, this.notificationMessage, this.globalSim1Name, this.globalSim2Name, this.selfRechargeEnabled, this.useBalanceEnabled, this.forceReinstall, this.paymentNumbers
  });

  factory InitModel.fromJson(Map<String, dynamic> json) {
    return InitModel(
      customerId:                       json["customer"]["customer_id"],
      customerStatus:                   /*json["customer"]["status"]*/1,
      customerInterMoney:               json["customer"]["inter_money"],
      customerInitCountryCode:          json["customer"]["init_country_code"],
      customerRefreshData:              json["customer"]["refresh_data"],
      customerNotification:             json["customer"]["notification"],
      customerVerified:                 json["customer"]["verified"],
      customerDisabledMessage:          json["customer"]["disabled_message"],
      customerBalance:                  double.parse(json["customer"]["balance"].toString()),
      customerForceOtp:                 json["customer"]["force_otp"],
      customerPinCreated:               json["customer"]["pin_created"],
      customerCountryCode:              json["customer"]["country_code"],
      customerName:                     json["customer"]["name"],
      customerGivenName:                json["customer"]["given_name"],
      customerPhonePrefix:              json["customer"]["phone_prefix"],
      customerPhoneNumber:              json["customer"]["phone_number"],
      customerCity:                     json["customer"]["city"],
      customerDateOfBirth:              json["customer"]["date_of_birth"],
      customerAddress:                  json["customer"]["adresse"],
      customerSexCode:                  json["customer"]["sexe_code"],
      customerLanguage:                 json["customer"]["language"],
      customerEmail:                    json["customer"]["email"],
      customerSelectedCurrencyCode:     json["customer"]["selected_currency_code"],
      customerSelectedCurrencySymbol:   json["customer"]["selected_currency_symbol"],
      countryPrefix:                    json["country_prefix"],
      countryChanged:                   json["country_changed"],
      internationalEnabled:             json["international_enabled"],
      nationalEnabled:                  json["national_enabled"],
      internalSendMoneyFee:             double.parse(json["internal_send_money_fee"].toString()),
      internalRechargeFee:              double.parse(json["internal_recharge_fee"].toString()),
      selfRechargeEnabled:              json["self_recharge_enabled"],
      profileUpdateUrl:                 json["profile_update_url"],
      supportPhone:                     json["support_phone"],
      socialNumber:                     json["social_number"],
      supportEmail:                     json["support_email"],
      helpUrl:                          json["help_url"],
      facebookUrl:                      json["facebook_url"],
      termsUrl:                         json["terms-url"],
      conexionErrorFr:                  json["conexion_error_fr"],
      conexionErrorEn:                  json["conexion_error_en"],
      notificationMessage:              json["notification_message"],
      forceReinstall:                   json["force_reinstall"],
      cities:                           json["cities"].map<CityModel>((model) => CityModel.fromJson(model)).toList(),
      currencies:                       json["currencies"].map<CurrencyModel>((model) => CurrencyModel.fromJson(model)).toList(),
      currencyExchangeRate:             json["currency_exchange_rate"].map<CurrencyExchangeRateModel>((model) => CurrencyExchangeRateModel.fromJson(model)).toList(),
      savedNumbers:                     json["saved_numbers"] != null ? json["saved_numbers"]!.map<SavedNumberModel>((model) => SavedNumberModel.fromJson(model)).toList() : null,
      paymentNumbers:                   json["payment_numbers"] != null ? json["payment_numbers"]!.map<PaymentNumberModel>((model) => PaymentNumberModel.fromJson(model)).toList() : null,
      globalSim1Name:                   json["global_sim1_name"],
      globalSim2Name:                   json["global_sim2_name"],
    );
  }

  //"currency_exchange_rate": [{"customer_currency": "EUR", "destination_currency": "CFA", "rate": 655.957}

  Map<String, dynamic> toMap(){
    return{
      'customer': {
        'customer_id':              customerId,
        'status':                   customerStatus,
        'inter_money':              customerInterMoney,
        'init_country_code':        customerInitCountryCode,
        'refresh_data':             customerRefreshData,
        'notification':             customerNotification,
        'verified':                 customerVerified,
        'disabled_message':         customerDisabledMessage,
        'balance':                  customerBalance,
        'pin_created':              customerPinCreated,
        'force_otp':                customerForceOtp,
        'country_code':             customerCountryCode,
        'name':                     customerName,
        'given_name':               customerGivenName,
        'phone_prefix':             customerPhonePrefix,
        'phone_number':             customerPhoneNumber,
        'city':                     customerCity,
        'date_of_birth':            customerDateOfBirth,
        'adresse':                  customerAddress,
        'sexe_code':                customerSexCode,
        'language':                 customerLanguage,
        'email':                    customerEmail,
        'selected_currency_code':   customerSelectedCurrencyCode,
        'selected_currency_symbol': customerSelectedCurrencySymbol,
      },
      'notification_message':     notificationMessage,
      'force_reinstall':          forceReinstall,
      'country_prefix':           countryPrefix,
      'country_changed':          countryChanged,
      'international_enabled':    internationalEnabled,
      'national_enabled':         nationalEnabled,
      'internal_send_money_fee':  internalSendMoneyFee,
      'internal_recharge_fee':    internalRechargeFee,
      'self_recharge_enabled':    selfRechargeEnabled,
      'use_balance_enabled':      useBalanceEnabled,
      'profile_update_url':       profileUpdateUrl,
      'support_phone':            supportPhone,
      'social_number':            socialNumber,
      'support_email':            supportEmail,
      'help_url':                 helpUrl,
      'facebook_url':             facebookUrl,
      'terms-url':                termsUrl,
      'conexion_error_fr':        conexionErrorFr,
      'conexion_error_en':        conexionErrorEn,
      'currencies':               currencies,
      'cities':                   cities,
      'saved_numbers':            savedNumbers,
      'global_sim1_name':         globalSim1Name,
      'global_sim2_name':         globalSim2Name,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'InitModel(customerId: $customerId, customerStatus: $customerStatus, customerVerified: $customerVerified, customerInterMoney: $customerInterMoney, '
           'customerDisabledMessage: $customerDisabledMessage, customerBalance: $customerBalance, customerPinCreated: $customerPinCreated, customerForceOtp: $customerForceOtp, customerInitCountryCode: $customerInitCountryCode, '
           'customerCountryCode: $customerCountryCode, customerName: $customerName, customerGivenName: $customerGivenName, customerRefreshData: $customerRefreshData, '
           'customerPhonePrefix: $customerPhonePrefix, customerPhoneNumber: $customerPhoneNumber, customerCity: $customerCity, customerNotification: $customerNotification, '
           'customerDateOfBirth: $customerDateOfBirth, customerAddress: $customerAddress, customerSexCode: $customerSexCode, customerLanguage: $customerLanguage, '
           'customerEmail: $customerEmail, countryPrefix: $countryPrefix, countryChanged: $countryChanged, internationalEnabled: $internationalEnabled, '
           'nationalEnabled: $nationalEnabled, internalSendMoneyFee: $internalSendMoneyFee, internalRechargeFee: $internalRechargeFee, profileUpdateUrl: $profileUpdateUrl, '
           'currencies: $currencies, cities: $cities, supportPhone: $supportPhone, socialNumber: $socialNumber, supportEmail: $supportEmail, '
           'helpUrl: $helpUrl, facebookUrl: $facebookUrl, termsUrl: $termsUrl, conexionErrorFr: $conexionErrorFr, conexionErrorEn: $conexionErrorEn, customerSelectedCurrencyCode: $customerSelectedCurrencyCode, '
           'customerSelectedCurrencySymbol: $customerSelectedCurrencySymbol , savedNumbers: $savedNumbers, notificationMessage: $notificationMessage, globalSim1Name: $globalSim1Name, globalSim2Name: $globalSim2Name'
           'selfRechargeEnabled: $selfRechargeEnabled, useBalanceEnabled: $useBalanceEnabled, forceReinstall: $forceReinstall'
    ')';
  }
}