import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:carrier_info/carrier_info.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sim_data/sim_data.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/models/city_model.dart';
import 'package:sinam/models/destination_country_model.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/operator_model.dart';
import 'package:sinam/models/operator_prefix_model.dart';
import 'package:sinam/models/operator_ussd_model.dart';
import 'package:sinam/models/payment_method_model.dart';
import 'package:sinam/models/service_model.dart';
import 'package:sinam/models/transfert_reason_model.dart';
import 'package:sinam/models/voucher_model.dart';
import 'package:sinam/models/wallet_refill_method_model.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/error/error.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/views/landing/landing.dart';
import 'package:sinam/views/welcome/welcome.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppConfig.screenWidth = MediaQuery.of(context).size.width;
    AppConfig.screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        toolbarHeight: 0,
        toolbarOpacity: 0,
        backgroundColor: AppColors.gradiantBlueColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: splashBody(context),
    );
  }

  Widget splashBody(BuildContext context){
    return Container(
      decoration: Helper.appBackgroundDecoration(),
      child: Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: topLogo()),
          Center(child: Container(margin: EdgeInsets.only(left: ScreenUtil().setWidth(35)), child: FadeInUp(from: 10, child: Image.asset('assets/images/hand.png', width: AppConfig.screenWidth - ScreenUtil().setWidth(80))))),
          Positioned(bottom: 40, right: 0, left: 0, child: loadingView())
        ],
      ),
    );
  }

  Widget topLogo(){
    return FadeInDown(
      from: 10,
      child: Container(
        width: ScreenUtil().setWidth(180),
        height: ScreenUtil().setHeight(130),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(25), vertical: ScreenUtil().setHeight(45)),
          child: Align(alignment: Alignment.bottomCenter, child: Image.asset('assets/images/logo.png')),
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30)
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xff4ea6de),
              Color(0xffbfe8fd),
            ],
          ),
        )
      ),
    );
  }

  Widget loadingView(){
    return FadeInUp(
      from: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 5.0,
            valueColor: AlwaysStoppedAnimation(AppColors.accentColor)
          ),
          const SizedBox(height: 25),
          Text(AppLocalizations.of(context)!.translate('loading'), style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  void getData() async{
    try{
      var phoneStatus = await Permission.phone.status;
      if (!phoneStatus.isGranted || phoneStatus.isRestricted || phoneStatus.isDenied || phoneStatus.isLimited || phoneStatus.isPermanentlyDenied) {
        bool isGranted = await Permission.phone.request().isGranted;
        if (!isGranted) {
          AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context)!.translate('receive_error'), description: AppLocalizations.of(context)!.translate('permission_required_message'), offlineSt: false, openSettingsSt: true));
          return;
        }
      }
      await getSimInfo();
      if(await Helper.isNetAvailable()){
        bool? isLogin = await storage.getBool('is_login');
        String? customerID = await storage.getString('customer_id');
        await Provider.of<InitViewModel>(context, listen: false).getInit(context, customerID);

        if(Provider.of<InitViewModel>(context, listen: false).initModel != null ){

          /////// remove on production
          //if(!AppConfig.isPublished){
          //  Provider.of<InitViewModel>(context, listen: false).initModel!.forceReinstall = 0;
         // }

          if(Provider.of<InitViewModel>(context, listen: false).initModel!.forceReinstall != null && Provider.of<InitViewModel>(context, listen: false).initModel!.forceReinstall == 1){
            AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context)!.translate('update_title'), description: AppLocalizations.of(context)!.translate('update_desc'), offlineSt: false, openSettingsSt: false));
            return;
          }

          if(customerID != null){
            if(Provider.of<InitViewModel>(context, listen: false).initModel!.customerStatus != null && Provider.of<InitViewModel>(context, listen: false).initModel!.customerStatus == 0){
              AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context)!.translate('went_wrong_title'), description: context.read<InitViewModel>().initModel!.customerDisabledMessage != null ? context.read<InitViewModel>().initModel!.customerDisabledMessage! : AppLocalizations.of(context)!.translate('deactivated_message'), offlineSt: false, openSettingsSt: false));
              return;
            }
          }
        } else{
          AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context)!.translate('receive_error'), description: AppLocalizations.of(context)!.translate('receive_error_description')));
          return;
        }

        if(isLogin != null && isLogin){
          await Provider.of<InitViewModel>(context, listen: false).getDictionary(context, customerID);
          if(context.read<InitViewModel>().dictionaryModel != null){
            AppNavigator.pushReplace(context: context, page: const Welcome());
          }else{
            loadOfflineData();
          }
        }else{
          await Provider.of<InitViewModel>(context, listen: false).getInit(context, customerID);
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushReplacement(context, PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const Landing(),
            transitionDuration: Duration.zero,
          ));
        }
      }else{
        await Future.delayed(const Duration(seconds: 2));
        AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context)!.translate('connection_error_title'), description: AppLocalizations.of(context)!.translate('connection_error_description')));
      }
    }catch(error){
      if(!AppConfig.isPublished){ print('error: $error'); }
      AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context)!.translate('receive_error'), description: AppLocalizations.of(context)!.translate('receive_error_description')));
    }
  }

  Future<void> getSimInfo() async {
    try{
      AppConfig.carrierName = await CarrierInfo.carrierName;
      AppConfig.isoCountryCode = await CarrierInfo.isoCountryCode;
	  AppConfig.isoCountryCode = AppConfig.isoCountryCode?.toUpperCase();
      AppConfig.simData = await SimDataPlugin.getSimData();
      AppConfig.imei = await DeviceInformation.deviceIMEINumber;
    }catch(error){
      if(!AppConfig.isPublished){ print('get sim error: $error'); }
    }
  }

  void loadOfflineData() async{

    String? dic = await storage.getString('dictionary');

    if(dic != null){
      dynamic dicObject = await json.decode(dic);

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

      context.read<InitViewModel>().setDictionaryModel(dicModel);
      AppNavigator.pushReplace(context: context, page: const Welcome());
    }else{
      AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context)!.translate('receive_error'), description: AppLocalizations.of(context)!.translate('receive_error_description')));
    }
  }
}