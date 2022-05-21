
import 'dart:convert';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/models/city_model.dart';
import 'package:sinam/models/currency_model.dart';
import 'package:sinam/models/destination_country_model.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/init_model.dart';
import 'package:sinam/models/operator_model.dart';
import 'package:sinam/models/operator_prefix_model.dart';
import 'package:sinam/models/operator_ussd_model.dart';
import 'package:sinam/models/payment_method_model.dart';
import 'package:sinam/models/saved_number_model.dart';
import 'package:sinam/models/service_model.dart';
import 'package:sinam/models/transfert_reason_model.dart';
import 'package:sinam/models/voucher_model.dart';
import 'package:sinam/models/wallet_refill_method_model.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/splash/splash.dart';
import 'package:sinam/views/welcome/welcome.dart';
import '../../helpers/app_localizations.dart';
import '../../helpers/app_navigator.dart';
import 'package:flutter/material.dart';
import '../../helpers/fading_edge_scrollview.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';

class ErrorPage extends StatefulWidget {

  final String title;
  final String description;
  final bool? offlineSt;
  final bool? openSettingsSt;

  const ErrorPage({Key? key,  required this.title, required this.description, this.offlineSt, this.openSettingsSt }) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> with TickerProviderStateMixin{

  final Storage storage = Storage();
  bool? isLogin = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async{
    bool? st = await storage.getBool('is_login');
    setState(() { isLogin = st; });
  }

  @override
  Widget build(BuildContext context) {

    return FocusWatcher(
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: errorBody(context),
      ),
    );
  }

  Widget errorBody(BuildContext context){
    return Column(
      children: <Widget>[
        const SizedBox(height: 150),
        FadeInDown(from: 10, child: Image.asset('assets/images/slogo.png', width: MediaQuery.of(context).size.width / 4)),
        Expanded(
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                controller: ScrollController(),
                child: FadeInUp(
                  from: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 50),
                        Text(widget.title, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        Text(widget.description, style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 130,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () async{
                                  await Future.delayed(const Duration(milliseconds: 250));
                                  AppNavigator.pushReplace(context: context, page: const Splash());
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue[700],
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                ),
                                child: Text(AppLocalizations.of(context)!.translate('retry'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),
                              ),
                            ),
                            Platform.isAndroid ? Row(
                              children: [
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 130,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () async{
                                      await Future.delayed(const Duration(milliseconds: 250));
                                      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.blue[700],
                                      elevation: 0.0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                    ),
                                    child: Text(AppLocalizations.of(context)!.translate('exit'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),

                                  ),
                                ),
                              ],
                            ) : Container()
                          ],
                        ),
                        if(isLogin != null && isLogin == true && (widget.offlineSt == null || widget.offlineSt == true)) ...[
                          const SizedBox(height: 40),
                          TextButton(
                              onPressed: () async{
                                await Future.delayed(const Duration(milliseconds: 250));
                                AppConfig.offlineSt = true;
                                loadOffline();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
                                child: Text(AppLocalizations.of(context)!.translate('use_offline'), style: TextStyle(
                                    fontSize: 14, color: Colors.blue[700]
                                )),
                              )
                          )
                        ],
                        if(widget.openSettingsSt != null && widget.openSettingsSt == true) ...[
                          const SizedBox(height: 40),
                          TextButton(
                              onPressed: () async{
                                await Future.delayed(const Duration(milliseconds: 250));
                                openAppSettings();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
                                child: Text(AppLocalizations.of(context)!.translate('open_settings'), style: TextStyle(
                                    fontSize: 14, color: Colors.blue[700]
                                )),
                              )
                          )
                        ]
                      ],
                    ),
                  ),
                )
            ),
          ),
        ),
      ],
    );
  }

  void loadOffline() async{

    String? init = await storage.getString('init');
    String? dic = await storage.getString('dictionary');

    dynamic initObject = await json.decode(init!);
    dynamic dicObject = await json.decode(dic!);

    InitModel initModel = InitModel(
      customerId:                       initObject["customer"]["customer_id"],
      customerStatus:                   initObject["customer"]["status"],
      customerInterMoney:               initObject["customer"]["inter_money"],
      customerInitCountryCode:          initObject["customer"]["init_country_code"],
      customerRefreshData:              initObject["customer"]["refresh_data"],
      customerNotification:             initObject["customer"]["notification"],
      customerVerified:                 initObject["customer"]["verified"],
      customerDisabledMessage:          initObject["customer"]["disabled_message"],
      customerBalance:                  initObject["customer"]["balance"],
      customerForceOtp:                 initObject["customer"]["force_otp"],
      customerPinCreated:               initObject["customer"]["pin_created"],
      customerCountryCode:              initObject["customer"]["country_code"],
      customerName:                     initObject["customer"]["name"],
      customerGivenName:                initObject["customer"]["given_name"],
      customerPhonePrefix:              initObject["customer"]["phone_prefix"],
      customerPhoneNumber:              initObject["customer"]["phone_number"],
      customerCity:                     initObject["customer"]["city"],
      customerDateOfBirth:              initObject["customer"]["date_of_birth"],
      customerAddress:                  initObject["customer"]["adresse"],
      customerSexCode:                  initObject["customer"]["sexe_code"],
      customerLanguage:                 initObject["customer"]["language"],
      customerEmail:                    initObject["customer"]["email"],
      customerSelectedCurrencyCode:     initObject["customer"]["selected_currency_code"],
      customerSelectedCurrencySymbol:   initObject["customer"]["selected_currency_symbol"],
      countryPrefix:                    initObject["country_prefix"],
      countryChanged:                   initObject["country_changed"],
      internationalEnabled:             initObject["international_enabled"],
      nationalEnabled:                  initObject["national_enabled"],
      internalSendMoneyFee:             initObject["internal_send_money_fee"],
      internalRechargeFee:              initObject["internal_recharge_fee"],
      selfRechargeEnabled:              initObject["self_recharge_enabled"],
      useBalanceEnabled:                initObject["use_balance_enabled"],
      profileUpdateUrl:                 initObject["profile_update_url"],
      supportPhone:                     initObject["support_phone"],
      socialNumber:                     initObject["social_number"],
      supportEmail:                     initObject["support_email"],
      helpUrl:                          initObject["help_url"],
      facebookUrl:                      initObject["facebook_url"],
      termsUrl:                         initObject["terms-url"],
      conexionErrorFr:                  initObject["conexion_error_fr"],
      conexionErrorEn:                  initObject["conexion_error_en"],
      cities:                           initObject["cities"] != null ? (json.decode(initObject["cities"].toString())).map<CityModel>((model) => CityModel.fromJson(model)).toList() : null,
      currencies:                       initObject["currencies"] != null ? (json.decode(initObject["currencies"].toString())).map<CurrencyModel>((model) => CurrencyModel.fromJson(model)).toList() : null,
      savedNumbers:                     initObject["saved_numbers"] != null ? (json.decode(initObject["saved_numbers"].toString())).map<SavedNumberModel>((model) => SavedNumberModel.fromJson(model)).toList() : null,
      globalSim1Name:                   initObject["global_sim1_name"],
      globalSim2Name:                   initObject["global_sim2_name"],
    );

    DictionaryModel dicModel = DictionaryModel(
      destinationCountries:   dicObject["desination_countries"] != null ? (json.decode(dicObject["desination_countries"].toString())).map<DestinationCountryModel>((model) => DestinationCountryModel.fromJson(model)).toList() : null,
      operators:              dicObject["operators"] != null ? (json.decode(dicObject["operators"].toString())).map<OperatorModel>((model) => OperatorModel.fromJson(model)).toList() : null,
      operatorsPrefix:        dicObject["operators_prefix"] != null ? (json.decode(dicObject["operators_prefix"].toString())).map<OperatorPrefixModel>((model) => OperatorPrefixModel.fromJson(model)).toList() : null,
      services:               dicObject["services"] != null ? (json.decode(dicObject["services"].toString())).map<ServiceModel>((model) => ServiceModel.fromJson(model)).toList() : null,
      vouchers:               dicObject["vouchers"] != null ? (json.decode(dicObject["vouchers"].toString())).map<VoucherModel>((model) => VoucherModel.fromJson(model)).toList() : null,
      operatorsUssd:          dicObject["operators_ussd"] != null ? (json.decode(dicObject["operators_ussd"].toString())).map<OperatorUssdModel>((model) => OperatorUssdModel.fromJson(model)).toList() : null,
      walletRefillMethod:     dicObject["wallet_refill_method"] != null ? (json.decode(dicObject["wallet_refill_method"].toString())).map<WalletRefillMethodModel>((model) => WalletRefillMethodModel.fromJson(model)).toList() : null,
      paymentMethod:          dicObject["payment_method"] != null ? (json.decode(dicObject["payment_method"].toString())).map<PaymentMethodModel>((model) => PaymentMethodModel.fromJson(model)).toList() : null,
      transferReasons:        dicObject["transfert_reasons"] != null ? (json.decode(dicObject["transfert_reasons"].toString())).map<TransferReasonModel>((model) => TransferReasonModel.fromJson(model)).toList() : null,
    );

    context.read<InitViewModel>().setInitModel(initModel);
    context.read<InitViewModel>().setDictionaryModel(dicModel);

    AppNavigator.pushReplace(context: context, page: const Welcome());
  }
}