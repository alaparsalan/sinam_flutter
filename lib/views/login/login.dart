import 'package:animate_do/animate_do.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/forget_pass/forget_pass.dart';
import 'package:sinam/views/landing/landing.dart';
import 'package:sinam/views/welcome/welcome.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final Storage storage = Storage();
  final _formKey = GlobalKey<FormState>();
  String? email, password;
  bool isEmail = false;
  bool submitSt = true;
  String? selectedCountryCode;

  @override
  void initState() {
    super.initState();
    if(context.read<InitViewModel>().initModel != null){
      selectedCountryCode = context.read<InitViewModel>().initModel!.countryPrefix;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppNavigator.pushReplace(context: context, page: const Landing());
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
          body: loginBody(),
        ),
      ),
    );
  }

  Widget loginBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Stack(
        children: [
          Positioned(left: 15, top: 15, child: SizedBox(width: 50, height: 50, child: TextButton(
            onPressed: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              if(submitSt){ AppNavigator.pushReplace(context: context, page: const Landing()); }
            },
            child: FadeInLeft(from: 10, child: const Icon(Icons.keyboard_arrow_left, size: 35, color: Colors.white,)))
          )),
          Align(alignment: Alignment.topCenter, child: topLogo()),
          Align(alignment: Alignment.topCenter, child: FadeIn(child: Container(margin: EdgeInsets.only(top: ScreenUtil().setHeight(120)), child: Image.asset('assets/images/slogo.png' , width: ScreenUtil().setWidth(70))))),
          Align(alignment: Alignment.topCenter, child: Container(margin: EdgeInsets.only(top: ScreenUtil().setHeight(220)), child: loginContainer())),
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
            child: Align(alignment: Alignment.center, child: Text(AppLocalizations.of(context)!.translate('login'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.grey[700]),)),
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

  Widget loginContainer(){
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
                        Text(AppLocalizations.of(context)!.translate('email_or_phone'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        const SizedBox(width: 4),
                        const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                  AppTextField(
                    isEnable: submitSt,
                    borderRadius: 10,
                    borderColor: Colors.grey[300],
                    labelText: AppLocalizations.of(context)!.translate('enter_your_email_or_phone'),
                    textInputType: TextInputType.emailAddress,
                    onValidate: (value){
                      Pattern pattern = '[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}';

                      if (value.isEmpty) {
                        return AppLocalizations.of(context)!.translate('email_or_phone_empty_validate');
                      }

                      if(Helper.isNumeric(value)){
                        if (value.length < 7) {
                          return AppLocalizations.of(context)!.translate('phone_validate');
                        }
                      }else{
                        if (value.length < 3) {
                          return AppLocalizations.of(context)!.translate('email_len_validate');
                        }
                        if (!RegExp(pattern.toString()).hasMatch(value)){
                          return AppLocalizations.of(context)!.translate('email_validate');
                        }
                      }
                      return null;
                    },
                    onChanged: (value){
                      if(value.contains('@')){
                        setState(() { isEmail = true; });
                      }else{
                        setState(() { isEmail = false; });
                      }
                      if(Helper.isNumeric(value)){
                        setState(() { isEmail = false; });
                      }else{
                        setState(() { isEmail = true; });
                      }
                      email = value;
                    },
                    prefixIcon: isEmail == false ? CountryCodePicker(
                      onChanged: (countryCode) => setState(() {selectedCountryCode = countryCode.toString();}),
                      initialSelection: selectedCountryCode,
                      favorite: const ['+228','+33'],
                      flagWidth: 25,
                      showCountryOnly: true,
                      alignLeft: false,
                      dialogSize: Size(AppConfig.screenWidth - 60, AppConfig.screenHeight - 290)
                    ) : null,
                    suffixIcon: Container(
                      width: 40, height: 40,
                      child: const Icon(Icons.person, color: Colors.white, size: 23),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.translate('password'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        const SizedBox(width: 4),
                        const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                  AppTextField(
                    isEnable: submitSt,
                    borderRadius: 10,
                    borderColor: Colors.grey[300],
                    labelText: AppLocalizations.of(context)!.translate('enter_your_password'),
                    toggleVisibleSt: true,
                    isPassword: true,
                    inputAction: TextInputAction.done,
                    onValidate: (value){
                      if (value.isEmpty) {
                        return AppLocalizations.of(context)!.translate('password_empty_validate');
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context)!.translate('password_len_validate');
                      }
                      return null;
                    },
                    onFieldSubmitted: (value){ password = value; submitForm(); },
                    onChanged: (value){ password = value; },
                    suffixIcon: Container(
                      width: 40, height: 40,
                      child: const Icon(Icons.lock_rounded, color: Colors.white, size: 23),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        GradiantButton(
                          title: AppLocalizations.of(context)!.translate('login_now'),
                          radius: 40,
                          width: MediaQuery.of(context).size.width - 150,
                          onPressed: () async{
                            await Future.delayed(const Duration(milliseconds: 250));
                            if(submitSt){ submitForm();}
                          }
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () async{
                            await Future.delayed(const Duration(milliseconds: 250));
                            AppNavigator.push(context: context, page: const ForgetPass());
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
                            child: Text(AppLocalizations.of(context)!.translate('forget_your_password'), style: TextStyle(
                                fontSize: 14, color: Colors.blue[700]
                            )),
                          )
                        )
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
        dynamic result = await Provider.of<InitViewModel>(context, listen: false).login(context,
          email: isEmail ? email!.trim() : null,
          phone: isEmail ? null : email!.trim(),
          password: password!.trim(),
          prefix: selectedCountryCode
        );
        if(result is bool && result){
          getData();
        }else{
          setState(() {submitSt = true;});
          Navigator.pop(context);
          Message.show(context, result.toString());
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

  Future<void> getData() async{
    try{
      String? customerID = await storage.getString('customer_id');
      await Provider.of<InitViewModel>(context, listen: false).getInit(context, customerID);
      await Provider.of<InitViewModel>(context, listen: false).getDictionary(context, customerID);
      await Future.delayed(const Duration(milliseconds: 250));
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 250));
      AppNavigator.pushReplace(context: context, page: const Welcome());
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
