import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/views/forget_pass/forget_pass.dart';
import 'package:sinam/views/landing/landing.dart';
import 'package:sinam/views/welcome/welcome.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formKey = GlobalKey<FormState>();
  String? email, password;
  bool submitSt = true;

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
          Align(alignment: Alignment.topCenter, child: FadeIn(child: Container(margin: EdgeInsets.only(top: AppConfig.screenWidth / 3 + 35), child: Image.asset('assets/images/slogo.png' ,width: AppConfig.screenWidth / 3)))),
          Align(alignment: Alignment.topCenter, child: Container(margin: EdgeInsets.only(top: AppConfig.screenWidth - 15), child: loginContainer())),
        ],
      ),
    );
  }

  Widget topLogo(){
    return FadeInDown(
      from: 30,
      child: Container(
          width: AppConfig.screenWidth / 2,
          height: AppConfig.screenWidth / 2 - 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50),
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
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(25.0),
            width: double.maxFinite,
            constraints: BoxConstraints(minHeight: AppConfig.screenHeight/2),
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
                    child: Text(AppLocalizations.of(context)!.translate('email_or_phone'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
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
                        if (value.length < 11) {
                          return AppLocalizations.of(context)!.translate('phone_len_validate');
                        }
                        if (!value.startsWith('0')){
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
                    onChanged: (value){ email = value; },
                    suffixIcon: Container(
                      width: 40, height: 40,
                      child: const Icon(Icons.person, color: Colors.white, size: 23),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(AppLocalizations.of(context)!.translate('password'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ),
                  AppTextField(
                    isEnable: submitSt,
                    borderRadius: 10,
                    borderColor: Colors.grey[300],
                    labelText: AppLocalizations.of(context)!.translate('enter_your_password'),
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
        await Future.delayed(const Duration(milliseconds: 2000));
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 250));
        AppNavigator.pushReplace(context: context, page: const Welcome());
      }catch(error){
        if(!AppConfig.isPublished){print('$error');}
        setState(() { submitSt = true;});
        Message.show(context, error.toString());
      }
    }
  }

  Future<void> getData() async{

  }
}
