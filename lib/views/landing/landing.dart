import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sim_data/sim_data.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/dialogs/language_dialog.dart';
import 'package:sinam/views/login/login.dart';
import 'package:sinam/views/register/register.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {

  late String selectedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedLanguage = AppLocalizations.of(context)!.locale.toString().split('_')[0];
  }

  getSimData() async{
    AppConfig.simData = await SimDataPlugin.getSimData();
  }

  @override
  Widget build(BuildContext context){
    getSimData();
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        toolbarHeight: 0,
        toolbarOpacity: 0,
        backgroundColor: AppColors.gradiantBlueColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: landingBody(context),
    );
  }

  Widget landingBody(BuildContext context){
    return Container(
      decoration: Helper.appBackgroundDecoration(),
      child: Stack(
        children: [
          Positioned(left: 15, top: 15, child: SizedBox(width: ScreenUtil().setWidth(65), height: ScreenUtil().setWidth(65), child: TextButton(
            onPressed: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              showDialog(context: context, builder: (context){
                return LanguageDialog(onSelect: (language) => setState(() { selectedLanguage = language; }));
              });
            },
            child: FadeInLeft(from: 10, child: Container(
              width: 65,
              height: 65,
              child: Center(child: Text(selectedLanguage.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic))),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[700],
              ),
            )))
          )),
          Align(alignment: Alignment.topCenter, child: topLogo()),
          Center(child: Container(margin: EdgeInsets.only(left: ScreenUtil().setWidth(35)), child: Image.asset('assets/images/hand.png', width: AppConfig.screenWidth - ScreenUtil().setWidth(80)))),
          Positioned(bottom: 25, right: 0, left: 0, child: buttonsView())
        ],
      ),
    );
  }

  Widget topLogo(){
    return Container(
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
    );
  }

  Widget buttonsView(){
    return FadeInUp(
      from: 10,
      child: Column(
        children: [
          GradiantButton(
            title: AppLocalizations.of(context)!.translate('login'),
            radius: 40,
            width: MediaQuery.of(context).size.width - ScreenUtil().setWidth(140),
            onPressed: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              AppNavigator.pushReplace(context: context, page: const Login());
            }
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              AppNavigator.pushReplace(context: context, page: const Register());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
              child: Text(AppLocalizations.of(context)!.translate('or_register'), style: TextStyle(
                fontSize: 14, color: Colors.blue[700]
              )),
            )
          )
        ],
      ),
    );
  }
}