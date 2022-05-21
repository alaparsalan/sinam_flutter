import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/dialogs/fail_dialog.dart';
import 'package:sinam/dialogs/message_dialog.dart';
import 'package:sinam/dialogs/question_dialog.dart';
import 'package:sinam/dialogs/success_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/menu.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/side_menu.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/help/help.dart';
import 'package:sinam/views/history/history.dart';
import 'package:sinam/views/landing/landing.dart';
import 'package:sinam/views/recharge/recharge.dart';
import 'package:sinam/views/send_money/send_money.dart';
import 'package:sinam/views/totp_confirm/totp_confirm.dart';
import 'package:sinam/views/wallet_refill/wallet_refill.dart';
import 'package:sinam/views/welcome/components/cash_power_slider_item.dart';
import 'package:sinam/views/welcome/components/recharge_slider_item.dart';
import 'package:sinam/views/welcome/components/send_money_slider_item.dart';
import 'package:sinam/views/welcome/components/tv_renew_slider_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'components/pay_bill_slider_item.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  final Storage storage = Storage();
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  int _backPress = 0;
  bool drawerSt = false;
  List<Widget> sliderList = [];
  Timer? timer;

  late InitViewModel initViewModel;
  DictionaryModel? dictionaryModel;
  String notifMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppConfig.selectedLanguage = AppLocalizations.of(context)!.locale.toString().split('_')[0];
    createSideMenu();
  }

  @override
  void initState() {
    super.initState();
    initViewModel = context.read<InitViewModel>();
    dictionaryModel = context.read<InitViewModel>().dictionaryModel;

    if(initViewModel.initModel != null){
      if(initViewModel.initModel!.customerNotification != null){
        notifMessage = initViewModel.initModel!.customerNotification ?? '';
      }

      if(initViewModel.initModel!.notificationMessage != null){
        notifMessage = initViewModel.initModel!.notificationMessage ?? '';
      }

      if(initViewModel.initModel!.customerDisabledMessage != null){
        notifMessage = initViewModel.initModel!.customerDisabledMessage ?? '';
      }

      if(notifMessage != ''){ showNotif();}

      if(initViewModel.initModel!.customerForceOtp != null && initViewModel.initModel!.customerForceOtp == 1){
        //forceOtp();
      }
    }

    sliderList.add(const RechargeSliderItem());
    if(!AppConfig.offlineSt){
      sliderList.add(const SendMoneySliderItem());
      sliderList.add(const PayBillSliderItem());
      sliderList.add(const CashPowerSliderItem());
      sliderList.add(const TvRenewSliderItem());
    }

    if(dictionaryModel != null){
      if(dictionaryModel!.services != null && dictionaryModel!.services!.isNotEmpty){
        for (var element in dictionaryModel!.services!) {
          if(element.serviceNameEn == 'Prepaid Cash Power' && element.redirectURL != null){
            AppConfig.cashPowerURL = element.redirectURL!;
          }

          if(element.serviceNameEn == 'TV Subsription' && element.redirectURL != null){
            AppConfig.tvRenewURL = element.redirectURL!;
          }

          if(element.serviceNameEn == 'Invoice Payment' && element.redirectURL != null){
            AppConfig.payBillsURL = element.redirectURL!;
          }
        }
      }
    }

    timer = Timer.periodic(const Duration(seconds: 5), (Timer t){
      print('checkkkkk');
      if(AppConfig.confirmPaymentSt == true){ confirmMobilePayments();}
      if(AppConfig.forceLogoutSt){ AppConfig.forceLogoutSt = false;logout();}
    });
  }

  void confirmMobilePayments() async{
    try{
      if(AppConfig.confirmPaymentPostData != null){
        if(await Helper.isNetAvailable()) {
          dynamic res = await initViewModel.confirmMobilePayment(context);
          print('confirmMobilePayments ressss: $res');
          if(res is bool && res == false){
            AppConfig.confirmPaymentSt == false;
            showDialog(context: context, builder: (cntx) => MessageDialog(title: AppLocalizations.of(context)!.translate('went_wrong_contact'), onDonePressed: (){
              logout();
            }));
          }else{
            if(res['status'] == 1){
              String customerID = AppConfig.confirmPaymentPostData!['customer_id'];
              AppConfig.confirmPaymentSt == false;
              AppConfig.confirmPaymentPostData == null;
              showDialog(context: context, builder: (cntx) => SuccessDialog(title: AppLocalizations.of(context)!.translate('success_payment_message')));
              await initViewModel.getInit(context, customerID);
              setState(() {
                initViewModel = context.read<InitViewModel>();
              });
            }else if(res['status'] == 2){
              AppConfig.confirmPaymentSt == false;
              AppConfig.confirmPaymentPostData == null;
              showDialog(context: context, builder: (cntx) => FailDialog(title: AppLocalizations.of(context)!.translate('failure_payment_message')));
            }
          }
        }else{
          AppConfig.confirmPaymentSt == false;
          showDialog(context: context, builder: (cntx) => MessageDialog(title: AppLocalizations.of(context)!.translate('went_wrong_contact'), onDonePressed: (){
            logout();
          }));
        }
      }
    }catch(error){
      if(!AppConfig.isPublished){ print('error: $error'); }
      AppConfig.confirmPaymentSt == false;
      showDialog(context: context, builder: (cntx) => MessageDialog(title: AppLocalizations.of(context)!.translate('went_wrong_contact'), onDonePressed: (){
        logout();
      }));
    }
  }

  void showNotif() async{
    await Future.delayed(const Duration(milliseconds: 3000));
    showDialog(context: context, builder: (context) => MessageDialog(title: notifMessage));
  }

  void forceOtp() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    try{
      String? phoneNumber = await storage.getString('phone_number');
      String? phonePrefix = await storage.getString('phone_prefix');
      String? accessToken1fa = await storage.getString('access_token_1fa');
      if(phoneNumber != null && phonePrefix != null){
        initViewModel.totpResend(context, phonePrefix: phonePrefix, phoneNumber: phoneNumber);
        AppNavigator.push(context: context, page: TotpConfirm(data: {
          'access_token_1fa': accessToken1fa,
        }, force: true));
      }
    }catch(error){
      if(!AppConfig.isPublished){ print('error: $error');}
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _backPress = 0;
    createSideMenu();
    setSideMenu();

    // map from hex string to code point int, and create string
    return FocusWatcher(
      child: InnerDrawer(
        key: _innerDrawerKey,
        onTapClose: true,
        swipe: true,
        colorTransitionScaffold: Colors.transparent,
        offset: const IDOffset.only(bottom: 0.0, right: 0.5, left: 0.0),
        borderRadius: 30,
        innerDrawerCallback: (value) => setState(() { drawerSt = value; }),
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
        scaffold: WillPopScope(
          onWillPop: () async{
            if(drawerSt){
              _innerDrawerKey.currentState!.close();
            }else{
              if (_backPress == 0) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Message.show(context, AppLocalizations.of(context)!.translate('exit_message'));
                _backPress++;
              } else {
                return true;
              }
            }
            return false;
          },
          child: Scaffold(
            backgroundColor: AppColors.primaryColor,
            appBar: AppBar(
              toolbarHeight: 0,
              toolbarOpacity: 0,
              backgroundColor: AppColors.gradiantBlueColor,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            body: welcomeBody(),
          ),
        ),
      ),
    );
  }

  Widget welcomeBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Column(
        children: [
          Align(alignment: Alignment.topCenter, child: topView()),
          Expanded(
            child: FadingEdgeScrollView.fromSingleChildScrollView(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                controller: ScrollController(),
                child: Column(
                  children: [
                    slideView(),
                    if(!AppConfig.offlineSt)
                    bottomView(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget topView(){
    return FadeInDown(
      from: 30,
      child: Column(
        children: [
          Container(
              width: AppConfig.screenWidth - ScreenUtil().setWidth(45),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 15, bottom: 20, top: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Center(child: Image.asset('assets/images/logo.png', height: 30,)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //Text(AppLocalizations.of(context)!.translate('welcome'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.grey[700])),
                              Row(
                                children: [
                                  if(!AppConfig.offlineSt)
                                  SizedBox(width: 40, height: 40, child: TextButton(
                                      onPressed: () async{
                                        await Future.delayed(const Duration(milliseconds: 250));
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return QuestionDialog(
                                              title: AppLocalizations.of(context)!.translate('exit_from_account_description'),
                                              onYes: (){
                                                logout();
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(Icons.power_settings_new_rounded, size: 25, color: Colors.grey[600],)
                                   )
                                  ),
                                  const SizedBox(width: 5),
                                  SizedBox(width: 40, height: 40, child: TextButton(
                                      onPressed: () async{
                                        await Future.delayed(const Duration(milliseconds: 250));
                                        _innerDrawerKey.currentState!.toggle();
                                      },
                                      child: Icon(Icons.menu, size: 25, color: Colors.grey[600],)
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(initViewModel.customerGivenName ?? 'Nan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.grey[700], overflow: TextOverflow.clip), maxLines: 1)
                  ],
                ),
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
          if(!AppConfig.offlineSt)
          GestureDetector(
            onTap: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              AppNavigator.push(context: context, page: const WalletRefill());
            },
            child: Container(
                width: AppConfig.screenWidth - ScreenUtil().setWidth(45),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.translate('your_total_balance'), style: TextStyle(fontSize: 15, color: Colors.grey[500])),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 0.0,
                        runSpacing: 0.0,
                        direction: Axis.horizontal,
                          children: [
                            if(initViewModel.customerSelectedCurrencySymbol != null && initViewModel.customerSelectedCurrencySymbol!.contains(r'\')) ...[
                              Text(initViewModel.customerSelectedCurrencySymbol != null ? String.fromCharCodes((
                                  initViewModel.customerSelectedCurrencySymbol!.split('u')..removeAt(0)).map<int>((hex) => int.parse(hex, radix: 16)),
                              ) : '', style: TextStyle(fontSize: 30, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              const SizedBox(width: 5),
                              Text('${initViewModel.customerBalance != null ? NumberFormat.currency(decimalDigits: 2, symbol: '').format(initViewModel.customerBalance!) : 0.0}', style: TextStyle(fontSize: 30, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text('+', style: TextStyle(fontSize: 25, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                              ),
                            ] else ...[
                              Text('${initViewModel.customerBalance != null ? (initViewModel.customerSelectedCurrencySymbol == 'CFA' ? initViewModel.customerBalance!.toInt() : NumberFormat.currency(decimalDigits: 2, symbol: '').format(initViewModel.customerBalance!)) : (initViewModel.customerSelectedCurrencySymbol == 'CFA' ? 0 : 0.00)}', style: TextStyle(fontSize: 30, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 9.0),
                                child: Text(initViewModel.customerSelectedCurrencySymbol ?? '', style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              const Padding(
                                padding: EdgeInsets.only(top: 0.0),
                                child: Text('+', style: TextStyle(fontSize: 30, color: Color(0xff0d5bc6), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),

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
            ),
          ),
        ],
      ),
    );
  }

  Widget slideView(){
    return Align(
      alignment: Alignment.topCenter,
      child: FadeInUp(
        from: 10,
        child: CarouselSlider(
          options: CarouselOptions(
            height: ScreenUtil().setHeight(445),
            enlargeCenterPage: true,
            enableInfiniteScroll: AppConfig.offlineSt ? false : true,
            autoPlay: AppConfig.offlineSt ? false : true,
          ),
          items: sliderList,
        ),
      ),
    );
  }

  Widget bottomView(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: FadeInUp(
        from: 10,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async{
                    await Future.delayed(const Duration(milliseconds: 250));
                    AppNavigator.push(context: context, page: const Recharge());
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(85),
                    height: ScreenUtil().setWidth(45),
                    margin: const EdgeInsets.all(10),
                    child: Center(child: Text(AppLocalizations.of(context)!.translate('recharge'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textAlign: TextAlign.center, maxLines: 1)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 3,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    await Future.delayed(const Duration(milliseconds: 250));
                    AppNavigator.push(context: context, page: const SendMoney());
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(85),
                    height: ScreenUtil().setWidth(45),
                    margin: const EdgeInsets.all(10),
                    child: Center(child: Text(AppLocalizations.of(context)!.translate('send_money'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textAlign: TextAlign.center, maxLines: 1)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 3,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    await Future.delayed(const Duration(milliseconds: 250));
                    AppNavigator.push(context: context, page: const WalletRefill());
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(85),
                    height: ScreenUtil().setWidth(45),
                    margin: const EdgeInsets.all(10),
                    child: Center(child: Text(AppLocalizations.of(context)!.translate('wallet_refill'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textAlign: TextAlign.center, maxLines: 1)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 3,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async{
                    await Future.delayed(const Duration(milliseconds: 250));
                    openURL(AppConfig.payBillsURL);
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(85),
                    height: ScreenUtil().setWidth(45),
                    margin: const EdgeInsets.all(10),
                    child: Center(child: Text(AppLocalizations.of(context)!.translate('pay_bills'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textAlign: TextAlign.center, maxLines: 1)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 3,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    await Future.delayed(const Duration(milliseconds: 250));
                    openURL(AppConfig.cashPowerURL);
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(85),
                    height: ScreenUtil().setWidth(45),
                    margin: const EdgeInsets.all(10),
                    child: Center(child: Text(AppLocalizations.of(context)!.translate('cash_power'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textAlign: TextAlign.center, maxLines: 1)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 3,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    await Future.delayed(const Duration(milliseconds: 250));
                    openURL(AppConfig.tvRenewURL);
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(85),
                    height: ScreenUtil().setWidth(45),
                    margin: const EdgeInsets.all(10),
                    child: Center(child: Text(AppLocalizations.of(context)!.translate('tv_renew'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textAlign: TextAlign.center, maxLines: 1)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 3,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20)
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
          break;
        case 'send_money':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SendMoney()));
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
        case 'recharge':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.push(context: context, page: const Recharge());
          break;
        case 'wallet':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletRefill()));
          break;
        case 'history':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.push(context: context, page: const History());
          break;
        case 'help':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Help()));
          break;
      }
    });
  }

  void createSideMenu(){
    List<SideMenu> sideMenu = [];
    if(!AppConfig.offlineSt){
      SideMenu sideMenu1 = SideMenu(
        id: 1,
        title: AppLocalizations.of(context)!.translate('welcome'),
        page: 'welcome',
        icon: const Icon(Icons.home, color: Colors.white, size: 25),
      );
      sideMenu.add(sideMenu1);

      SideMenu sideMenu2 = SideMenu(
          id: 2,
          title: AppLocalizations.of(context)!.translate('recharge'),
          page: 'recharge',
          icon: const Icon(FontAwesomeIcons.moneyBill, color: Colors.white, size: 22)
      );
      sideMenu.add(sideMenu2);

      SideMenu sideMenu3 = SideMenu(
          id: 3,
          title: AppLocalizations.of(context)!.translate('send_money'),
          page: 'send_money',
          icon: const Icon(Icons.mobile_screen_share_rounded, color: Colors.white, size: 22)
      );
      sideMenu.add(sideMenu3);

      SideMenu sideMenu4 = SideMenu(
          id: 4,
          title: AppLocalizations.of(context)!.translate('pay_bills'),
          page: 'pay_bills',
          icon: const Icon(FontAwesomeIcons.creditCard, color: Colors.white, size: 23)
      );
      sideMenu.add(sideMenu4);

      SideMenu sideMenu5 = SideMenu(
          id: 5,
          title: AppLocalizations.of(context)!.translate('cash_power'),
          page: 'cash_power',
          icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white)
      );
      sideMenu.add(sideMenu5);

      SideMenu sideMenu6 = SideMenu(
          id: 6,
          title: AppLocalizations.of(context)!.translate('tv_renew'),
          page: 'tv_renew',
          icon: const Icon(Icons.reset_tv_rounded, color: Colors.white)
      );
      sideMenu.add(sideMenu6);

      SideMenu sideMenu7 = SideMenu(
          id: 7,
          title: AppLocalizations.of(context)!.translate('history'),
          page: 'history',
          icon: const Icon(Icons.history, color: Colors.white)
      );
      sideMenu.add(sideMenu7);

      SideMenu sideMenu8 = SideMenu(
          id: 8,
          title: AppLocalizations.of(context)!.translate('wallet'),
          page: 'wallet',
          icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white)
      );
      sideMenu.add(sideMenu8);

      SideMenu sideMenu9 = SideMenu(
          id: 9,
          title: AppLocalizations.of(context)!.translate('help'),
          page: 'help',
          icon: const Icon(Icons.help_outline, color: Colors.white)
      );
      sideMenu.add(sideMenu9);
    }else{
      SideMenu sideMenu1 = SideMenu(
        id: 1,
        title: AppLocalizations.of(context)!.translate('welcome'),
        page: 'welcome',
        icon: const Icon(Icons.home, color: Colors.white, size: 25),
      );
      sideMenu.add(sideMenu1);

      SideMenu sideMenu2 = SideMenu(
          id: 2,
          title: AppLocalizations.of(context)!.translate('recharge'),
          page: 'recharge',
          icon: const Icon(FontAwesomeIcons.moneyBill, color: Colors.white, size: 22)
      );
      sideMenu.add(sideMenu2);

      SideMenu sideMenu3 = SideMenu(
          id: 9,
          title: AppLocalizations.of(context)!.translate('help'),
          page: 'help',
          icon: const Icon(Icons.help_outline, color: Colors.white)
      );
      sideMenu.add(sideMenu3);
    }

    AppConfig.sideMenu = sideMenu;
  }

  void openURL(String url) async{
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(body: WebView(
      initialUrl: url,
    ))));
    /*try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Message.show(context, AppLocalizations.of(context)!.translate('browser_error'));
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
    }*/
  }

  void setSideMenu(){
    for (var element in AppConfig.sideMenu!) {
      if(element.id == 1){
        element.active = true;
      }else{
        element.active = false;
      }
    }
  }

  void logout() async{
    try{
      Provider.of<InitViewModel>(context, listen: false).logout(context);
      await Future.delayed(const Duration(milliseconds: 1500));
      storage.clearAll();
      AppNavigator.pushReplace(context: context, page: const Landing());
    }catch(error){
      if(!AppConfig.isPublished){print('$error');}
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