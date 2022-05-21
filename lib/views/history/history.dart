import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/cupertino_date_picker_field.dart';
import 'package:sinam/helpers/custom_app_bar.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/menu.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/helpers/search_bar.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/transaction_history_model.dart';
import 'package:sinam/models/wallet_refill_history_model.dart';
import 'package:sinam/view_models/history_view_model.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/help/help.dart';
import 'package:sinam/views/history/fragments/transaction_fragment.dart';
import 'package:sinam/views/history/fragments/wallet_refill_fragment.dart';
import 'package:sinam/views/recharge/recharge.dart';
import 'package:sinam/views/send_money/send_money.dart';
import 'package:sinam/views/wallet_refill/wallet_refill.dart';
import 'package:url_launcher/url_launcher.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with TickerProviderStateMixin {

  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  final Storage storage = Storage();
  DateTime? startDate, endDate;
  bool submitSt = true;
  List<String?> serviceList = [];
  String? selectedService;
  bool isLoading = true;

  HistoryViewModel historyViewModel = HistoryViewModel();
  List<WalletRefillHistoryModel> originalWalletList = [];
  List<WalletRefillHistoryModel> walletList = [];

  List<TransactionHistoryModel> originalTransactionList = [];
  List<TransactionHistoryModel> transactionList = [];

  DictionaryModel? dictionaryModel;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    serviceList.add(null);
    dictionaryModel = context.read<InitViewModel>().dictionaryModel;
    tabController = TabController(length: 2, vsync: this);
    if(dictionaryModel != null && dictionaryModel!.services != null){
      for (var element in dictionaryModel!.services!) {
        serviceList.add(AppConfig.selectedLanguage == 'en' ? element.serviceNameEn : element.serviceNameFr);
      }}

    getData();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 0,
          toolbarOpacity: 0,
          backgroundColor: AppColors.gradiantBlueColor,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: historyBody(),
      ),
    );
  }

  Widget historyBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(20.0), right: ScreenUtil().setWidth(15.0), left: ScreenUtil().setWidth(15.0)),
        child: Column(
          children: [
            CustomAppBar(
              title: AppLocalizations.of(context)!.translate('history'),
              submitSt: true,
              innerDrawerKey: _innerDrawerKey,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0, right: 10.0, left: 10.0),
                child: isLoading ? loadingView() : FadeInUp(
                  from: 10,
                  child: Column(
                    children: [
                      //SearchBar(labelText: AppLocalizations.of(context)!.translate('search'), onChanged: (value) => search(value)),
                      //const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(child: startDatePickerView()),
                          const SizedBox(width: 15),
                          Expanded(child: endDatePickerView()),
                        ],
                      ),
                      const SizedBox(height: 25),
                      serviceView(),
                      const SizedBox(height: 25),
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
                                      Color(0xffc8f5fe),
                                      Color(0xffffffff),
                                    ],
                                  ),
                                ),
                                child: TabBarView(
                                  controller: tabController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    WalletRefillFragment(walletList: walletList),
                                    TransactionFragment(historyList: transactionList)
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 65,
                              child: TabBar(
                                controller: tabController,
                                labelColor: Colors.grey[700],
                                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                unselectedLabelColor: Colors.grey[700],
                                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                indicator: const BoxDecoration(
                                  color: Color(0xffc8f5fe),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                ),
                                tabs: [
                                  SizedBox(height:67 ,child: Tab(child: Column( children: [ const SizedBox(height: 18), Text(AppLocalizations.of(context)!.translate('wallet_refill'), textScaleFactor: 1.2), const SizedBox(height: 8)]))),
                                  SizedBox(height:67 ,child: Tab(child: Column( children: [ const SizedBox(height: 18), Text(AppLocalizations.of(context)!.translate('transaction'), textScaleFactor: 1.2), const SizedBox(height: 8)]))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
  Widget startDatePickerView(){
    return CupertinoDatePickerField(
      mode: CupertinoDatePickerMode.date,
      onDatePicked: (dateTime){ setState(() { startDate = dateTime; endDate = null; });},
      disableMessage: null,
      enabled: true,
      value: startDate,
      hint: 'Date',
      bordered: true,
      hasIcon: false,
      helpText: AppLocalizations.of(context)!.translate('from'),
    );
  }
  Widget endDatePickerView(){
    return CupertinoDatePickerField(
      mode: CupertinoDatePickerMode.date,
      onDatePicked: (dateTime) async{
        if(dateTime == null){
          setState(() { endDate = null; });
        }else{
          if(dateTime == startDate || dateTime.isAfter(startDate!)){
            setState(() { endDate = dateTime; });
          }else{
            Message.show(context, AppLocalizations.of(context)!.translate('to_date_validate'));
            setState(() { endDate = null; });
          }
        }

        if(startDate != null && endDate != null){
          await Future.delayed(const Duration(milliseconds: 1000));
          setState(() { selectedService = null;});
          getData(startDate: startDate, endDate: endDate);
        }
      },
      disableMessage: startDate == null ? AppLocalizations.of(context)!.translate('select_from') : null,
      enabled: true,
      value: endDate,
      hint: 'Date',
      bordered: true,
      hasIcon: false,
      helpText: AppLocalizations.of(context)!.translate('to'),
    );
  }
  Widget serviceView(){
    return Focus(
      descendantsAreFocusable: false,
      child: DropdownButtonFormField(
        style: const TextStyle(fontSize: 17, color: Colors.grey),
        iconEnabledColor: Colors.grey[600],
        decoration: Helper.roundDropDownInputDecoration(),
        isExpanded: true,
        items: serviceList.map((String? value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(value ?? AppLocalizations.of(context)!.translate('service'), style: TextStyle(color: value == null ? Colors.grey[500] : Colors.black, fontSize: 14)),
            ),
          );
        }).toList(),
        dropdownColor: Colors.grey[200],
        hint: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Text(AppLocalizations.of(context)!.translate('service'), style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ),
        onChanged: submitSt ? (value) async{
          List<TransactionHistoryModel> newTransactionList = [];
          tabController.animateTo(1);
          await Future.delayed(const Duration(milliseconds: 800));
          setState(() {
            String search = '';
            if(value == 'Cash Transfert' || value == "Tranfert d'argent"){
              search = 'Send Money';
            }else{
              search = value.toString();
            }
            selectedService = value.toString();
            FocusManager.instance.primaryFocus!.unfocus();
            if(value == null){
              newTransactionList = originalTransactionList;
            }else{
              if(originalTransactionList.isNotEmpty){
                for (var element in originalTransactionList) {
                  if((AppConfig.selectedLanguage == 'en' ? element.serviceEn : element.servicdeFr) == search){
                    newTransactionList.add(element);
                  }
                }
              }
            }
            transactionList = newTransactionList;
          });
        } : null,
      ),
    );
  }
  Widget loadingView() {
    return FadeInUp(
      from: 10,
      child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 70),
            width: 280,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                        color: AppColors.accentColor, strokeWidth: 3)),
                const SizedBox(height: 25),
                Text(AppLocalizations.of(context)!.translate('loading'),
                    style: const TextStyle(fontSize: 15,
                        color: AppColors.accentColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
      ),
    );
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
      if(element.id == 7){
        element.active = true;
      }else{
        element.active = false;
      }
    }
  }

  void getData({DateTime? startDate, DateTime? endDate}) async{
    try{
      originalTransactionList.clear(); transactionList.clear();
      originalWalletList.clear(); walletList.clear();
      setState(() { isLoading = true; submitSt = false; });
      String? customerID = await storage.getString('customer_id');
      if(customerID != null){
        dynamic walletRefillResult = await historyViewModel.getWalletRefillHistory(context, customerID: customerID, dateFrom: startDate != null ? DateFormat('dd-MM-yyyy').format(startDate) : null, dateTo: endDate != null ? DateFormat('dd-MM-yyyy').format(endDate) : null);
        dynamic transactionResult = await historyViewModel.getTransactionHistory(context, customerID: customerID, dateFrom: startDate != null ? DateFormat('dd-MM-yyyy').format(startDate) : null, dateTo: endDate != null ? DateFormat('dd-MM-yyyy').format(endDate) : null);
        setState(() { isLoading = false; submitSt = true; });
        if(walletRefillResult is List<WalletRefillHistoryModel>){
          setState(() { originalWalletList = walletRefillResult; walletList = walletRefillResult; });
        }
        if(transactionResult is List<TransactionHistoryModel>){
          setState(() { originalTransactionList = transactionResult; transactionList = transactionResult; });
        }
      }else{
        Message.show(context, AppLocalizations.of(context)!.translate('receive_error'));
      }
    }catch(error){
      if(!AppConfig.isPublished){print('Error: $error');}
      setState(() { isLoading = false; submitSt = true;});
      Message.show(context, AppLocalizations.of(context)!.translate('receive_error'));
    }
  }
}
