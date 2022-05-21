import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/pin_form/pin_form.dart';
import 'package:timer_count_down/timer_count_down.dart';

class TotpConfirm extends StatefulWidget {

  final Map<String, dynamic> data;
  final bool? force;

  const TotpConfirm({Key? key, required this.data, this.force}) : super(key: key);

  @override
  _TotpConfirmState createState() => _TotpConfirmState();
}

class _TotpConfirmState extends State<TotpConfirm> {
  final Storage storage = Storage();
  final _formKey = GlobalKey<FormState>();
  String? verifyCode;
  bool submitSt = true, counterSt = true;
  bool toggleVisible = true;

  late TextEditingController pinController;

  String _commingSms = 'Unknown';

  Future<void> initSmsListener() async {
    String? commingSms;
    try {
      commingSms = await AltSmsAutofill().listenForSms;
    } on PlatformException {
      commingSms = 'Failed to get Sms.';
    }
    if (!mounted) return;
    _commingSms = commingSms!.substring(0,8).replaceAll('-', '').replaceAll(' ', '');
    if(Helper.isNumeric(_commingSms)){ setState(() { pinController.text = _commingSms;}); await Future.delayed(const Duration(milliseconds: 250));
    if(submitSt){ submitForm();}}
  }

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
    initSmsListener();

    if(widget.data.containsKey('wait_time')){
      AppConfig.resendTotpCodeWaitTime = widget.data['wait_time'];
    }
  }

  @override
  void dispose() {
    AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.force == null && widget.force == false){
          Navigator.pop(context);
        }
        return false;
      },
      child: FocusWatcher(
        child: Scaffold(
          backgroundColor: AppColors.primaryColor,
          appBar: AppBar(
            toolbarHeight: 0,
            toolbarOpacity: 0,
            backgroundColor: AppColors.gradiantBlueColor,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: totpConfirmBody(),
        ),
      ),
    );
  }

  Widget totpConfirmBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Stack(
        children: [
          if(widget.force == null && widget.force == false)
          Positioned(left: 15, top: 15, child: SizedBox(width: 50, height: 50, child: TextButton(
              onPressed: () async{
                await Future.delayed(const Duration(milliseconds: 250));
                Navigator.pop(context);
              },
              child: FadeInLeft(from: 10, child: const Icon(Icons.keyboard_arrow_left, size: 35, color: Colors.white,)))
          )),
          Align(alignment: Alignment.topCenter, child: topLogo()),
          Align(alignment: Alignment.topCenter, child: FadeIn(child: Container(margin: EdgeInsets.only(top: ScreenUtil().setHeight(120)), child: Image.asset('assets/images/slogo.png' , width: ScreenUtil().setWidth(70))))),
          Align(alignment: Alignment.topCenter, child: Container(margin: EdgeInsets.only(top: ScreenUtil().setHeight(220)), child: totpContainer())),
        ],
      ),
    );
  }

  Widget topLogo(){
    return FadeInDown(
      from: 30,
      child: Container(
          width: ScreenUtil().setWidth(180),
          height: ScreenUtil().setHeight(130),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15.0), vertical: ScreenUtil().setHeight(35)),
            child: Align(alignment: Alignment.center, child: Text(AppLocalizations.of(context)!.translate('phone_confirm'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey[700]), textAlign: TextAlign.center)),
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
                Color(0xfff8fdff),
                Color(0xffc0e8fd),
              ],
            ),
          )
      ),
    );
  }

  Widget totpContainer(){
    return FadeInUp(
      from: 30,
      child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          controller: ScrollController(),
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(18.0), vertical: ScreenUtil().setHeight(20)),
              width: double.maxFinite,
              height: ScreenUtil().setHeight(420),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(AppLocalizations.of(context)!.translate('verify_code'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                              const SizedBox(width: 4),
                              const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                            ],
                          ),
                          //toggleButton(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    PinCodeTextField(
                      length: 7,
                      animationType: AnimationType.fade,
                      keyboardType: TextInputType.number,
                      textStyle: const TextStyle(fontSize: 14),
                      controller: pinController,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.underline,
                        inactiveColor: Colors.grey,
                        fieldWidth: 15,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      onCompleted: (v) {
                        if(!AppConfig.isPublished){ print("Completed");}
                        if(verifyCode != null && verifyCode != '' && submitSt){ submitForm();}
                      },
                      onChanged: (value) {
                        if(!AppConfig.isPublished){ print(value);}
                        setState(() { verifyCode = value; });
                      },
                      beforeTextPaste: (text) {
                        if(!AppConfig.isPublished){ print("Allowing to paste $text");}
                        return true;
                      }, appContext: context,
                    ),
                    const SizedBox(height: 40),
                    if(AppConfig.allowResendTotpCode)
                    Column(
                      children: [
                        Center(child: Text(AppLocalizations.of(context)!.translate('not_receive_code'), style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
                        const SizedBox(height: 10),
                        if (counterSt == false) Center(
                          child: SizedBox(
                              height: 40,
                              width: 200,
                              child: TextButton(
                                onPressed: submitSt ? () {
                                  sendCode();
                                } : null,
                                child: Text(
                                    AppLocalizations.of(context)!.translate('send_code_again'),
                                    style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.normal)
                                ),
                              )
                          ),
                        ) else Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 10),
                            child: Countdown(
                              seconds: AppConfig.resendTotpCodeWaitTime,
                              build: (BuildContext context, double time) {
                                var minutes = (time.toInt() % 3600 ~/ 60)
                                    .toInt()
                                    .toString()
                                    .padLeft(2, '0');
                                var seconds = (time.toInt() % 60)
                                    .toInt()
                                    .toString()
                                    .padLeft(2, '0');
                                return Text("$minutes:$seconds",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600]));
                              },
                              interval: const Duration(milliseconds: 100),
                              onFinished: () {
                                if(!AppConfig.isPublished){ print('Timer is done!');}
                                setState(() { counterSt = false; });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),

                    Center(
                      child: Column(
                        children: [
                          GradiantButton(
                            title: AppLocalizations.of(context)!.translate('submit'),
                            radius: 40,
                            width: MediaQuery.of(context).size.width - 150,
                            onPressed: () async{
                              await Future.delayed(const Duration(milliseconds: 250));
                              if(submitSt){ submitForm();}
                            }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }

  Widget toggleButton(){
    return GestureDetector( onTap: (){ setState(() { toggleVisible = !toggleVisible; }); }, child: Container(margin: const EdgeInsets.only(right: 5), child: Icon(toggleVisible ? Icons.remove_red_eye_outlined : Icons.remove_red_eye_rounded, size: 26, color: Colors.grey[400])));
  }

  void submitForm() async{
    FocusScope.of(context).unfocus();
    if(verifyCode != null && verifyCode! != ''){
      if(verifyCode!.length == 7){
        setState(() {submitSt = false;});
        showDialog(context: context, builder: (context) => const LoadingDialog());
        try{
          dynamic result;
          if(widget.force != null && widget.force == true){

            String? phoneNumber = await storage.getString('phone_number');
            String? phonePrefix = await storage.getString('phone_prefix');
            if(phoneNumber != null && phonePrefix != null){
              result = await Provider.of<InitViewModel>(context, listen: false).webOtpCheck(context,
                totpCode: verifyCode!,
                prefix: phonePrefix,
                phone: phoneNumber
              );  
            }else{
              setState(() {submitSt = true;});
              Navigator.pop(context);
              Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
            }
          }else{
            result = await Provider.of<InitViewModel>(context, listen: false).totpConfirm(context,
              totpCode: verifyCode!,
              accessToken1fa: widget.data['access_token_1fa'],
            );
          }

          if(result is bool && result){
            await Future.delayed(const Duration(milliseconds: 250));
            if(widget.force != null && widget.force == true){
              Navigator.pop(context);
            }else{
              AppNavigator.pushReplace(context: context, page: const PinForm(from: 'confirm', backSt: false, isOptional: true));
            }
          }else{
            setState(() {submitSt = true;});
            Navigator.pop(context);
            Message.show(context, result.toString());
          }
        }catch(error){
          if(!AppConfig.isPublished){print('error: $error');}
          setState(() { submitSt = true;});
          Navigator.pop(context);
          if(error == 'connection_error_description'){
            String? connectionError;
            if(AppConfig.selectedLanguage == 'en'){
              if(AppConfig.connectionErrorEn != null){
                connectionError = AppConfig.connectionErrorEn;
              }
            }else{
              if(AppConfig.connectionErrorFr != null){
                connectionError = AppConfig.connectionErrorFr;
              }
            }
            Message.show(context, AppLocalizations.of(context)!.translate(connectionError ?? error.toString()));
          }else{
            Message.show(context, AppLocalizations.of(context)!.translate(error.toString()));
          }
        }
      }else{
        Message.show(context, AppLocalizations.of(context)!.translate('verify_code_len_validate'));
      }
    }else{
      Message.show(context, AppLocalizations.of(context)!.translate('verify_code_empty_validate'));
    }
  }

  void sendCode() async{
    await Future.delayed(const Duration(milliseconds: 250));
    showDialog(context: context, builder: (context) => const LoadingDialog());
    try{
      String? phoneNumber = await storage.getString('phone_number');
      String? phonePrefix = await storage.getString('phone_prefix');

      if(phoneNumber != null && phonePrefix != null){
        dynamic result = await Provider.of<InitViewModel>(context, listen: false).totpResend(context,
          phoneNumber: phoneNumber,
          phonePrefix: phonePrefix,
        );
        if(result is bool && result){
          setState(() { counterSt = true; });
        }else{
          setState(() {submitSt = true;});
          Navigator.pop(context);
          Message.show(context, result.toString());
        }
      }else{
        setState(() { submitSt = true;});
        Navigator.pop(context);
        Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
      }
    }catch(error){
      if(!AppConfig.isPublished){print('$error');}
      setState(() { submitSt = true;});
      Navigator.pop(context);
      if(error == 'connection_error_description'){
        String? connectionError;
        if(AppConfig.selectedLanguage == 'en'){
          if(AppConfig.connectionErrorEn != null){
            connectionError = AppConfig.connectionErrorEn;
          }
        }else{
          if(AppConfig.connectionErrorFr != null){
            connectionError = AppConfig.connectionErrorFr;
          }
        }
        Message.show(context, AppLocalizations.of(context)!.translate(connectionError ?? error.toString()));
      }else{
        Message.show(context, AppLocalizations.of(context)!.translate(error.toString()));
      }
    }
  }
}
