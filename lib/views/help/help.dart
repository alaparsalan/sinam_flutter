import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/custom_app_bar.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/menu.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/history/history.dart';
import 'package:sinam/views/recharge/recharge.dart';
import 'package:sinam/views/send_money/send_money.dart';
import 'package:sinam/views/wallet_refill/wallet_refill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {

  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  late InitViewModel initViewModel;

  @override
  void initState() {
    super.initState();

    initViewModel = context.read<InitViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    setSideMenu();
    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: true,
      swipe: true,
      colorTransitionScaffold: Colors.transparent,
      offset: const IDOffset.only(bottom: 0.0, right: 0.5, left: 0.0),
      borderRadius: 30,
      rightAnimationType: InnerDrawerAnimation.quadratic,
      backgroundDecoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xff0957c5),
            Color(0xff359cd9),
          ],
        ),
      ), // default  Theme.of(context).backgroundColor
      rightChild: menuInit(),
      scaffold: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          toolbarHeight: 0,
          toolbarOpacity: 0,
          backgroundColor: AppColors.gradiantBlueColor,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: helpBody(),
      ),
    );
  }

  Widget helpBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Padding(
        //padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(20.0), bottom: ScreenUtil().setHeight(14.0), right: ScreenUtil().setWidth(15.0), left: ScreenUtil().setWidth(15.0)),
        child: Column(
          children: [
            CustomAppBar(
              title: AppLocalizations.of(context)!.translate('help'),
              submitSt: true,
              innerDrawerKey: _innerDrawerKey,
            ),
            const SizedBox(height: 40),
            Text(AppLocalizations.of(context)!.translate('select_topic')),
            const SizedBox(height: 50),
            Expanded(
              child: FadeInUp(
                from: 10,
                child: FadingEdgeScrollView.fromSingleChildScrollView(
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        helpItem(title: AppLocalizations.of(context)!.translate('getting_started'), desc: AppLocalizations.of(context)!.translate('getting_started_desc')),
                        helpItem(title: AppLocalizations.of(context)!.translate('accounts'), desc: AppLocalizations.of(context)!.translate('accounts_desc')),
                        helpItem(title: AppLocalizations.of(context)!.translate('payment_and_billings'), desc: AppLocalizations.of(context)!.translate('payment_and_billings_desc')),
                        helpItem(title: AppLocalizations.of(context)!.translate('security_and_privacy'), desc: AppLocalizations.of(context)!.translate('security_and_privacy_desc')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 15),
            TextButton(
                onPressed: () async{
                  await Future.delayed(const Duration(milliseconds: 250));
                  if(initViewModel.helpUrl != null){
                    openURL(initViewModel.helpUrl!);
                  }else{
                    Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.translate('online_help'), style: const TextStyle(fontSize: 16)),
                    const Icon(Icons.support, size: 25)
                  ],
                )
            ),
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () async{
                await Future.delayed(const Duration(milliseconds: 250));
                try {
                  if(initViewModel.supportEmail != null){
                    final Uri _emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: initViewModel.supportEmail,
                    );
                    if (await canLaunch(_emailLaunchUri.toString())) {
                      await launch(_emailLaunchUri.toString());
                    } else {
                      Message.show(context, AppLocalizations.of(context)!.translate('email_error'));
                    }
                  }else{
                    Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
                  }
                } catch (error) {
                  if(!AppConfig.isPublished){ print('error: $error'); }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.translate('email_contact'), style: const TextStyle(fontSize: 16)),
                  const Icon(Icons.email, size: 25)
                ],
              )
            ),
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 40, height: 40, child: TextButton(
                  onPressed: () async{
                    await Future.delayed(const Duration(milliseconds: 250));
                    try {
                      if(initViewModel.supportPhone != null){
                        final Uri _callLaunchUri = Uri(
                          scheme: 'tel',
                          path: initViewModel.supportPhone,
                        );
                        if (await canLaunch(_callLaunchUri.toString())) {
                          await launch(_callLaunchUri.toString());
                        } else {Message.show(context, AppLocalizations.of(context)!.translate('call_error'));}
                      }else{
                        Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
                      }
                    } catch (error) {
                      if(!AppConfig.isPublished){ print('error: $error'); }
                    }
                  },
                  child: Icon(Icons.call, size: 25, color: Colors.grey[700]!)
                )),
                const SizedBox(width: 5),
                SizedBox(width: 40, height: 40, child: TextButton(
                    onPressed: () async{
                      await Future.delayed(const Duration(milliseconds: 250));
                      if(initViewModel.facebookUrl != null){
                        openURL(initViewModel.facebookUrl!);
                      }else{
                        Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
                      }
                    },
                    child: Icon(FontAwesomeIcons.facebook, size: 25, color: Colors.grey[700]!)
                )),
                const SizedBox(width: 5),
                SizedBox(width: 40, height: 40, child: TextButton(
                    onPressed: () async{
                      await Future.delayed(const Duration(milliseconds: 250));
                      openURL("https://wa.me/${AppConfig.whatsapp}");
                    },
                    child: Icon(FontAwesomeIcons.whatsapp, size: 25, color: Colors.grey[700]!)
                )),
                const SizedBox(width: 5),
                SizedBox(width: 40, height: 40, child: TextButton(
                    onPressed: () async{
                      await Future.delayed(const Duration(milliseconds: 250));
                      openURL(AppConfig.telegram);
                    },
                    child: Icon(FontAwesomeIcons.telegramPlane, size: 25, color: Colors.grey[700]!)
                )),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget helpItem({required String title, required String desc}){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white38,
            width: 1.0,
          ),
        )
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          expandedAlignment: Alignment.topLeft,
          title: Text('•   $title'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 17.0),
              child: Text(desc, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.left),
            )
          ],
        ),
      ),
    );
  }

  Widget menuInit(){
    return Menu(goToPage: (page) async{
      switch(page){
        case 'welcome':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          Navigator.pop(context);
          break;
        case 'recharge':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const Recharge());
          break;
        case 'send_money':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const SendMoney());
          break;
        case 'pay_bills':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          openURL(AppConfig.payBillsURL);
          break;
        case 'cash_power':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          openURL(AppConfig.cashPowerURL);
          break;
        case 'tv_renew':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          openURL(AppConfig.tvRenewURL);
          break;
        case 'wallet':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const WalletRefill());
          break;
        case 'history':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const History());
          break;
        case 'help':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          break;
      }
    });
  }

  void openURL(String url) async{
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Message.show(context, AppLocalizations.of(context)!.translate('browser_error'));
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
    }
  }

  void setSideMenu(){
    for (var element in AppConfig.sideMenu!) {
      if(element.id == 9){
        element.active = true;
      }else{
        element.active = false;
      }
    }
  }
}
