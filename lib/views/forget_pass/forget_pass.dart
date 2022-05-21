import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:provider/provider.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({Key? key}) : super(key: key);

  @override
  _ForgetPassState createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {

  final _formKey = GlobalKey<FormState>();
  String? email;
  bool submitSt = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
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
          body: forgetPassBody(),
        ),
      ),
    );
  }

  Widget forgetPassBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Stack(
        children: [
          Positioned(left: 15, top: 15, child: SizedBox(width: 50, height: 50, child: TextButton(
              onPressed: () async{
                await Future.delayed(const Duration(milliseconds: 250));
                if(submitSt){ Navigator.pop(context); }
              },
              child: FadeInLeft(from: 10, child: const Icon(Icons.keyboard_arrow_left, size: 35, color: Colors.white,)))
          )),
          Align(alignment: Alignment.topCenter, child: topLogo()),
          Align(alignment: Alignment.topCenter, child: FadeIn(child: Container(margin: EdgeInsets.only(top: ScreenUtil().setHeight(120)), child: Image.asset('assets/images/slogo.png' , width: ScreenUtil().setWidth(70))))),
          Align(alignment: Alignment.topCenter, child: Container(margin: EdgeInsets.only(top: ScreenUtil().setHeight(220)), child: forgetPassContainer())),
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
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50),
            child: Align(alignment: Alignment.center, child: Text(AppLocalizations.of(context)!.translate('reset_pass'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.grey[700]), textAlign: TextAlign.center)),
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

  Widget forgetPassContainer(){
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
                        children: [
                          Text(AppLocalizations.of(context)!.translate('email'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          const SizedBox(width: 4),
                          const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                    AppTextField(
                      isEnable: submitSt,
                      borderRadius: 10,
                      borderColor: Colors.grey[300],
                      labelText: AppLocalizations.of(context)!.translate('enter_your_email'),
                      inputAction: TextInputAction.done,
                      textInputType: TextInputType.emailAddress,
                      onValidate: (value){
                        Pattern pattern = '[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}';

                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('email_empty_validate');
                        }

                        if (value.length < 3) {
                          return AppLocalizations.of(context)!.translate('email_len_validate');
                        }
                        if (!RegExp(pattern.toString()).hasMatch(value)){
                          return AppLocalizations.of(context)!.translate('email_validate');
                        }
                        return null;
                      },
                      onChanged: (value){ email = value; },
                      onFieldSubmitted: (value){ email = value; submitForm(); },
                      suffixIcon: Container(
                        width: 40, height: 40,
                        child: const Icon(Icons.email_rounded, color: Colors.white, size: 23),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          GradiantButton(
                              title: AppLocalizations.of(context)!.translate('reset_pass_request'),
                              radius: 40,
                              width: ScreenUtil().setWidth(230),
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

  void submitForm() async{
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {submitSt = false;});
      showDialog(context: context, builder: (context) => const LoadingDialog());
      try{
        dynamic result = await context.read<InitViewModel>().resetPassword(context, email: email!);
        Navigator.pop(context);
        setState(() { submitSt = true;});
        print('result: ${result.runtimeType}');
        if(result is Map<String, dynamic>){
          Message.show(context, result['message']);
          await Future.delayed(const Duration(seconds: 4));
          Navigator.pop(context);
        }else{
          Message.show(context, result);
        }
      }catch(error){
        if(!AppConfig.isPublished){print('error $error');}
        setState(() { submitSt = true;});
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
}
