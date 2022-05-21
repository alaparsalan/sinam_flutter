import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
import 'package:sinam/views/help/help.dart';
import 'package:sinam/views/history/history.dart';
import 'package:sinam/views/pin_form/pin_form.dart';
import 'package:sinam/views/recharge/recharge.dart';
import 'package:sinam/views/send_money/send_money.dart';
import 'package:sinam/views/wallet_refill/fragments/card_payment_fragment.dart';
import 'package:sinam/views/wallet_refill/fragments/mobile_payment_fragment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class WalletRefill extends StatefulWidget {
  const WalletRefill({Key? key}) : super(key: key);

  @override
  _WalletRefillState createState() => _WalletRefillState();
}

class _WalletRefillState extends State<WalletRefill> {

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  bool submitSt = true;
  late InitViewModel initViewModel;
  bool walletPinCreated = false;

  @override
  void initState() {
    super.initState();
    initViewModel = context.read<InitViewModel>();
  }

  @override
  Widget build(BuildContext context) {

    if(initViewModel.initModel != null){
      switch(initViewModel.initModel!.customerPinCreated){
        case 0:
          walletPinCreated = false;
          break;
        case 1:
          walletPinCreated = true;
          break;
        default:
          walletPinCreated = false;
          break;
      }
    }

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
        body: walletRefillBody(),
      ),
    );
  }

  Widget walletRefillBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Padding(
        //padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(20.0), right: ScreenUtil().setWidth(15.0), left: ScreenUtil().setWidth(15.0)),
        child: Column(
          children: [
            CustomAppBar(
              title: AppLocalizations.of(context)!.translate('wallet_refill'),
              submitSt: submitSt,
              innerDrawerKey: _innerDrawerKey,
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Expanded(
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                gradientFractionOnEnd: 0.07,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: ScrollController(),
                  child: Container(
                    height: 0,
                    constraints: BoxConstraints(
                      minHeight: ScreenUtil().setHeight(570)
                    ),
                    child: FadeInUp(
                      from: 10,
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            SizedBox(height:  ScreenUtil().setHeight(10)),
                            SizedBox(width: ScreenUtil().setWidth(85), child: Image.asset('assets/images/mob.png')),
                            SizedBox(height:  ScreenUtil().setHeight(20)),
                            totalBalanceView(),
                            SizedBox(height:  ScreenUtil().setHeight(20)),
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned(
                                    top:  47,
                                    right: 0,
                                    left: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            Color(0xff66a7e3),
                                            Color(0xff243b92),
                                          ],
                                        ),
                                      ),
                                      child: const TabBarView(
                                        //physics: BouncingScrollPhysics(),
                                        physics: NeverScrollableScrollPhysics(),
                                        children: [
                                          MobilePaymentFragment(),
                                          CardPaymentFragment()
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 65,
                                    child: TabBar(
                                      labelColor: Colors.white,
                                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.clip),
                                      unselectedLabelColor: Colors.grey[700],
                                      unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.clip),
                                      indicator: const BoxDecoration(
                                        color: Color(0xff62a2df),
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                      ),
                                      tabs: [
                                        SizedBox(height: 67 ,child: Tab(child: Column( children: [ const SizedBox(height: 18), Text(AppLocalizations.of(context)!.translate('mobile_payment'), textScaleFactor: 1.1, maxLines: 1, textAlign: TextAlign.center), const SizedBox(height: 8)]))),
                                        SizedBox(height: 67 ,child: Tab(child: Column( children: [ const SizedBox(height: 18), Text(AppLocalizations.of(context)!.translate('card_payment'), textScaleFactor: 1.1, maxLines: 1, textAlign: TextAlign.center), const SizedBox(height: 8)]))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /*Widget walletRefillBody(){
    return Container(
      constraints: BoxConstraints(
        minHeight: AppConfig.screenHeight
      ),
      decoration: Helper.appBackgroundDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
        child: Column(
          children: [
            CustomAppBar(
              title: AppLocalizations.of(context)!.translate('wallet_refill'),
              submitSt: submitSt,
              innerDrawerKey: _innerDrawerKey,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                gradientFractionOnEnd: 0.07,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: ScrollController(),
                  child: FadeInUp(
                    from: 10,
                    child: DefaultTabController(
                      length: 2,
                      child: SizedBox(
                        height: AppConfig.screenHeight - 150,
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            SizedBox(width: AppConfig.screenWidth / 3.4, child: Image.asset('assets/images/mob.png')),
                            const SizedBox(height: 30),
                            totalBalanceView(),
                            const SizedBox(height: 30),
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 47,
                                    right: 0,
                                    left: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            Color(0xff66a7e3),
                                            Color(0xff243b92),
                                          ],
                                        ),
                                      ),
                                      child: const TabBarView(
                                        //physics: BouncingScrollPhysics(),
                                        physics: NeverScrollableScrollPhysics(),
                                        children: [
                                          MobilePaymentFragment(),
                                          CardPaymentFragment()
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 65,
                                    child: TabBar(
                                      labelColor: Colors.white,
                                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      unselectedLabelColor: Colors.grey[700],
                                      unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      indicator: const BoxDecoration(
                                        color: Color(0xff62a2df),
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                      ),
                                      tabs: [
                                        SizedBox(height:67 ,child: Tab(child: Column( children: [ const SizedBox(height: 18), Text(AppLocalizations.of(context)!.translate('mobile_payment'), textScaleFactor: 1.2), const SizedBox(height: 8)]))),
                                        SizedBox(height:67 ,child: Tab(child: Column( children: [ const SizedBox(height: 18), Text(AppLocalizations.of(context)!.translate('card_payment'), textScaleFactor: 1.2), const SizedBox(height: 8)]))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  Widget totalBalanceView(){
    return Container(
        width: double.maxFinite,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(25.0), vertical: ScreenUtil().setHeight(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.translate('your_total_balance'), style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 0.0,
                      runSpacing: 0.0,
                      direction: Axis.horizontal,
                      children: [
                        if(initViewModel.customerSelectedCurrencySymbol != null && initViewModel.customerSelectedCurrencySymbol!.contains(r'\')) ...[
                          Text(initViewModel.customerSelectedCurrencySymbol != null ? String.fromCharCodes((
                              initViewModel.customerSelectedCurrencySymbol!.split('u')..removeAt(0)).map<int>((hex) => int.parse(hex, radix: 16)),
                          ) : '', style: TextStyle(fontSize: 22, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                          const SizedBox(width: 5),
                          Text('${initViewModel.customerBalance != null ? NumberFormat.currency(decimalDigits: 2, symbol: '').format(initViewModel.customerBalance!) : 0.0}', style: TextStyle(fontSize: 22, color: Colors.grey[700], fontWeight: FontWeight.bold, overflow: TextOverflow.clip), maxLines: 1),
                        ] else ...[
                          Text('${initViewModel.customerBalance != null ? (initViewModel.customerSelectedCurrencySymbol == 'CFA' ? initViewModel.customerBalance!.toInt() : NumberFormat.currency(decimalDigits: 2, symbol: '').format(initViewModel.customerBalance!)) : (initViewModel.customerSelectedCurrencySymbol == 'CFA' ? 0 : 0.00)}', style: TextStyle(fontSize: 22, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Text(initViewModel.customerSelectedCurrencySymbol ?? '', style: TextStyle(fontSize: 17, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: ScreenUtil().setWidth(90),
                    child: TextButton(
                      onPressed: () async{
                        await Future.delayed(const Duration(milliseconds: 250));
                        AppNavigator.push(context: context, page: PinForm(isOptional: true, backSt: true, isUpdate: walletPinCreated ? true : false, onFinish: (){
                          setState(() {});
                        }));
                      },
                      child: Text(AppLocalizations.of(context)!.translate(walletPinCreated ? 'update_wallet_pin' : 'create_wallet_pin'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textAlign: TextAlign.center),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xfff8fdff),
              Color(0xffc0e8fd),
            ],
          ),
        )
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
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const Help());
          break;
      }
    });
  }

  void setSideMenu(){
    for (var element in AppConfig.sideMenu!) {
      if(element.id == 8){
        element.active = true;
      }else{
        element.active = false;
      }
    }
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
}
