import 'package:animate_do/animate_do.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/fail_dialog.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/dialogs/message_dialog.dart';
import 'package:sinam/dialogs/question_dialog.dart';
import 'package:sinam/dialogs/recharge_detail_dialog.dart';
import 'package:sinam/dialogs/success_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/custom_app_bar.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/menu.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/helpers/recent_item.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/voucher_model.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/help/help.dart';
import 'package:sinam/views/history/history.dart';
import 'package:sinam/views/recharge/components/voucher_picker_field.dart';
import 'package:sinam/views/send_money/send_money.dart';
import 'package:sinam/views/wallet_refill/wallet_refill.dart';
import 'package:sinam/helpers/expansion_tile.dart' as customExpTile;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

class Recharge extends StatefulWidget {
  const Recharge({Key? key}) : super(key: key);

  @override
  _RechargeState createState() => _RechargeState();
}

class _RechargeState extends State<Recharge> with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  PhoneContact? phoneContact;
  bool submitSt = true;
  bool? termsSt = true;
  String? selectedCountryCode;
  String? selectedPhonePrefix;
  String? phoneNumber, name, explain;
  bool selfChargeSt = true, anotherNumberSt = false;
  DictionaryModel? dictionaryModel;
  InitViewModel? initViewModel;
  VoucherModel? selectedVoucher;

  Map<int, String> operatorList = {};
  int? selectedOperatorList;
  int? selectedType = 0;
  int? selectedSim = 0;
  int? selectedPayMethod = 0;
  String selectedSimName = '';
  List<String> availableCountries = [];
  List<String> favoriteCountries = [];
  List<Widget> recentList = [];
  List<Widget> simList = [];
  bool noSimSt = false;
  int phoneLength = 7;
  String mobileMoneyTitle = '';
  bool localRestrict = false;

  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    dictionaryModel = context.read<InitViewModel>().dictionaryModel;
    initViewModel = context.read<InitViewModel>();

    ///// remove this line
    //initViewModel!.initModel!.selfRechargeEnabled = 1;
    //initViewModel!.initModel!.internationalEnabled = 0;

    if(initViewModel!.initModel!.internationalEnabled == 0){
      localRestrict = true;
    }

    if(dictionaryModel != null){
      if(dictionaryModel!.destinationCountries != null && dictionaryModel!.destinationCountries!.isNotEmpty){
        for (var element in dictionaryModel!.destinationCountries!) {
          availableCountries.add(element.phonePrefix);
          if(element.phonePrefix == '+228' || element.phonePrefix == '+33'){
            favoriteCountries.add(element.phonePrefix);
          }
        }
        if(initViewModel!.initModel!.nationalEnabled != null && initViewModel!.initModel!.nationalEnabled == 1 && initViewModel!.initModel!.countryPrefix != null){
          selectedCountryCode = initViewModel!.initModel!.customerCountryCode;
          selectedPhonePrefix = initViewModel!.initModel!.customerPhonePrefix;
        }else{
          selectedCountryCode = dictionaryModel!.destinationCountries![0].countryCode;
          selectedPhonePrefix = dictionaryModel!.destinationCountries![0].phonePrefix;
        }
        getValidPhoneLength();
      }
      loadOperators();
    }
    if(initViewModel!.initModel != null){
      loadRecent();
    }
    loadSims();
  }

  void getValidPhoneLength(){
    if(dictionaryModel!.destinationCountries != null && dictionaryModel!.destinationCountries!.isNotEmpty){
      for (var element in dictionaryModel!.destinationCountries!) {
        if(element.phonePrefix == selectedPhonePrefix){
          setState(() { phoneLength = element.phoneLength; });
        }
      }
    }
  }

  void loadOperators({int? operatorCode, String? operatorName}){
    operatorList.clear();
    selectedOperatorList = null;
    selectedSimName = '';
    if(dictionaryModel != null && dictionaryModel!.operators != null && dictionaryModel!.operators!.isNotEmpty){
      for (var element in dictionaryModel!.operators!){
        if(initViewModel!.initModel!.nationalEnabled != null && initViewModel!.initModel!.nationalEnabled == 0){
          if(element.countryCode == selectedCountryCode && (initViewModel!.initModel!.globalSim1Name == element.simName || initViewModel!.initModel!.globalSim1Name == element.simName)){
            operatorList[element.operatorCode] = element.simName;
          }
        }else{
          if(element.countryCode == selectedCountryCode){
            operatorList[element.operatorCode] = element.simName;
          }
        }
      }
      if(operatorList.isNotEmpty){
        if(operatorCode != null){
          selectedOperatorList = operatorCode;
        }else{
          selectedOperatorList = operatorList.entries.first.key;
        }
        if(operatorName != null){
          selectedSimName = operatorName;
        }else{
          selectedSimName = operatorList.entries.first.value;
        }
      }
      setState(() {});
    }
  }

  void loadRecent(){
    if(initViewModel!.initModel!.savedNumbers != null && initViewModel!.initModel!.savedNumbers!.isNotEmpty){
      for (var element in initViewModel!.initModel!.savedNumbers!){
        recentList.add(
          GestureDetector(
            onTap: () async{
              if(availableCountries.contains(element.countryCode)){
                setState(() {
                  phoneContact = null;
                  selectedVoucher = null;
                  selectedPhonePrefix = element.countryCode;

                  if(dictionaryModel!.destinationCountries != null && dictionaryModel!.destinationCountries!.isNotEmpty){
                    for (var cc in dictionaryModel!.destinationCountries!){
                      if(cc.phonePrefix == element.countryCode){
                        selectedCountryCode = cc.countryCode;
                      }
                    }
                  }
                  selectedPhonePrefix = element.countryCode;
                  phoneNumberController.text = element.recipientNumber;
                  phoneNumber = element.recipientNumber;
                });
                getValidPhoneLength();
                String? operatorName;
                if(dictionaryModel!.operators != null && dictionaryModel!.operators!.isNotEmpty) {
                  for (var operator in dictionaryModel!.operators!) {
                    if (operator.countryCode == selectedCountryCode && operator.operatorCode == element.operatorCode) {
                      operatorName = operator.simName;
                    }
                  }
                }
                loadOperators(
                  operatorCode: element.operatorCode,
                  operatorName: operatorName
                );
              }else{
                Message.show(context, 'selected_number_not_supported');
                setState(() {
                  phoneNumber = null;
                  phoneNumberController.text = '';
                });
              }
            },
            child: RecentItem(number: element, avatar: dictionaryModel!.operators!.where((e) => e.operatorCode == element.operatorCode).first.sendMoneyFlag,),
          )
        );
      }
    }
  }

  void loadSims(){
    simList.clear();
    if(AppConfig.simData != null){
      if(AppConfig.simData!.cards.isNotEmpty){
        for (var element in AppConfig.simData!.cards) {
          simList.add(
            SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(element.carrierName, style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)])))
          );
        }
        //selectedSimName =  AppConfig.simData!.cards.first.carrierName;
        selectedSimName =  initViewModel!.initModel!.globalSim1Name != null ? initViewModel!.initModel!.globalSim1Name! : AppConfig.simData!.cards.first.carrierName;
        selectedCountryCode =  AppConfig.simData!.cards.first.countryCode.toUpperCase();
      }else{
        noSimSt = true;
        simList.add(
            SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(AppLocalizations.of(context)!.translate('no_sim'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)])))
        );
      }
    }else{
      noSimSt = true;
      simList.add(
          SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(AppLocalizations.of(context)!.translate('no_sim'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)])))
      );
    }
    loadOperators();
    Future.delayed(Duration.zero, () {
      loadMobileMoneyTitle();
    });
    setState(() {});
  }

  void loadMobileMoneyTitle(){
    if(dictionaryModel != null && dictionaryModel!.operators != null && dictionaryModel!.operators!.isNotEmpty) {
      for (var element in dictionaryModel!.operators!) {
        if (element.simName.toLowerCase() == selectedSimName.toLowerCase()) {
          setState(() { mobileMoneyTitle = element.sendMoneyName; });
        }
      }
      if(mobileMoneyTitle == ''){
        setState(() { mobileMoneyTitle = AppLocalizations.of(context)!.translate('mobile_money');});
      }
    }else{
      if(mounted){
        setState(() {mobileMoneyTitle = AppLocalizations.of(context)!.translate('mobile_money'); });
      }
    }
  }

  @override
  Widget build(BuildContext context){
    print('national ${initViewModel!.initModel!.nationalEnabled}');
    print('selectedPayMethod $selectedPayMethod');
    setSideMenu();
    return FocusWatcher(
      child: InnerDrawer(
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
          body: rechargeBody(),
        ),
      ),
    );
  }

  Widget rechargeBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Padding(
        //padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(20.0), bottom: ScreenUtil().setHeight(10.0), right: ScreenUtil().setWidth(15.0), left: ScreenUtil().setWidth(15.0)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomAppBar(
                title: AppLocalizations.of(context)!.translate('recharge'),
                submitSt: submitSt,
                innerDrawerKey: _innerDrawerKey,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FadeInUp(
                  from: 10,
                  child: FadingEdgeScrollView.fromSingleChildScrollView(
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          if(!AppConfig.offlineSt) ...[
                            if((initViewModel!.initModel!.selfRechargeEnabled != null && initViewModel!.initModel!.selfRechargeEnabled == 1)) ...[
                              selfRechargeView(),
                              anotherNumberView(),
                            ] else ...[
                              anotherNumberView(st: true),
                            ],
                          ]else ...[
                            if((initViewModel!.initModel!.selfRechargeEnabled != null && initViewModel!.initModel!.selfRechargeEnabled == 1))
                            selfRechargeOfflineView()
                          ],
                          rechargeTypeView(),
                          voucherView(),
                          termsView(),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              FadeInUp(
                from: 10,
                child: GradiantButton(
                  title: AppLocalizations.of(context)!.translate('recharge'),
                  radius: 40,
                  width: ScreenUtil().setWidth(230),
                  onPressed: () async{
                    await Future.delayed(const Duration(milliseconds: 250));
                    submitForm();
                  }
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget selfRechargeOfflineView(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xffcbf5ff),
            Color(0xffdefdff),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.translate('self_recharge'), style: TextStyle(fontSize: 16, color: Colors.blue[700])),
          const SizedBox(height: 20),
          selectSimCardView(),
          const SizedBox(height: 25)
        ],
      )
    );
  }

  Widget selfRechargeView(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xffcbf5ff),
            Color(0xffdefdff),
          ],
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: customExpTile.ExpansionTile(
          isExpanded: selfChargeSt,
          onExpansionChanged: (value){
            if(value){
              setState(() {
                anotherNumberSt = false;
                selfChargeSt = true;
                selectedVoucher = null;
              });
              loadSims();
              //loadVouchers();
            }else{
              setState(() {
                anotherNumberSt = true;
                selfChargeSt = false;
                if(initViewModel!.initModel!.nationalEnabled != null && initViewModel!.initModel!.nationalEnabled == 1 && initViewModel!.initModel!.countryPrefix != null){
                  selectedSimName = operatorList[initViewModel!.initModel!.countryPrefix].toString();
                  selectedCountryCode = initViewModel!.initModel!.customerCountryCode;
                }else{
                  selectedSimName = operatorList[selectedOperatorList].toString();
                }
                selectedVoucher = null;
                loadOperators();
              });
              //loadVouchers();
            }
          },
          title: Text(AppLocalizations.of(context)!.translate('self_recharge')),
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  selectSimCardView(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(AppLocalizations.of(context)!.translate('payment_method'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),
                  selectPaymentView(),
                  const SizedBox(height: 25)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget anotherNumberView({bool? st}){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xffcbf5ff),
            Color(0xffdefdff),
          ],
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: customExpTile.ExpansionTile(
          isExpanded: st ?? anotherNumberSt,
          onExpansionChanged: (value){
            if(value){
              setState(() {
                anotherNumberSt = true;
                selfChargeSt = false;
                if(initViewModel!.initModel!.nationalEnabled != null && initViewModel!.initModel!.nationalEnabled == 1 && initViewModel!.initModel!.countryPrefix != null){
                  selectedSimName = operatorList[initViewModel!.initModel!.countryPrefix].toString();
                  selectedCountryCode = initViewModel!.initModel!.customerCountryCode;
                }else{
                  selectedSimName = operatorList[selectedOperatorList].toString();
                }
                selectedVoucher = null;
                loadOperators();
              });
            }else{
              setState(() {
                anotherNumberSt = false;
                selfChargeSt = true;
                selectedVoucher = null;
              });
              loadSims();
            }
          },
          title: Text(AppLocalizations.of(context)!.translate('another_number')),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.translate('phone_number'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () async{
                          final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
                          if(contact.phoneNumber != null){
                            bool found = false;
                            if(dictionaryModel != null){
                              if(dictionaryModel!.destinationCountries != null && dictionaryModel!.destinationCountries!.isNotEmpty){
                                for (var element in dictionaryModel!.destinationCountries!) {
                                  if(contact.phoneNumber!.number!.startsWith('+')){
                                    if(contact.phoneNumber!.number!.contains(element.phonePrefix)){
                                      setState(() {
                                        found = true;
                                        phoneContact = contact;
                                        name = contact.fullName;
                                        phoneNumber = contact.phoneNumber!.number!.replaceAll(element.phonePrefix, '').replaceAll(' ', '');
                                        phoneNumberController.text = phoneNumber!;
                                        selectedPhonePrefix = element.phonePrefix;
                                        selectedCountryCode = element.countryCode;
                                      });
                                      getValidPhoneLength();
                                      loadOperators();
                                    }
                                  }else if(contact.phoneNumber!.number!.startsWith('00')){
                                    if(contact.phoneNumber!.number!.replaceFirst('00', '+').replaceAll(' ', '').contains(element.phonePrefix)){
                                      setState(() {
                                        found = true;
                                        phoneContact = contact;
                                        name = contact.fullName;
                                        phoneNumber = contact.phoneNumber!.number!.replaceFirst('00', '+').replaceAll(' ', '').replaceAll(element.phonePrefix, '');
                                        phoneNumberController.text = phoneNumber!;
                                        selectedPhonePrefix = element.phonePrefix;
                                        selectedCountryCode = element.countryCode;
                                      });
                                      getValidPhoneLength();
                                      loadOperators();
                                    }
                                  }else if(contact.phoneNumber!.number![0] == '0' && contact.phoneNumber!.number![1] != '0'){
                                    setState(() {
                                      found = true;
                                      phoneContact = contact;
                                      name = contact.fullName;
                                      phoneNumber = contact.phoneNumber!.number!.replaceFirst('0', '').replaceAll(' ', '');
                                      phoneNumberController.text = phoneNumber!;
                                      selectedPhonePrefix = element.phonePrefix;
                                      selectedCountryCode = element.countryCode;
                                    });
                                    getValidPhoneLength();
                                    loadOperators();
                                  }
                                }
                                if(!found){
                                  setState(() {
                                    phoneContact = contact;
                                    name = contact.fullName;
                                    phoneNumber = contact.phoneNumber!.number!.replaceAll(' ', '');
                                    phoneNumberController.text = phoneNumber!;
                                  });
                                  /*setState(() {
                                    phoneContact = null;
                                    name = null;
                                    phoneNumber = null;
                                    phoneNumberController.text = '';
                                  });
                                  Message.show(context, AppLocalizations.of(context)!.translate('selected_number_not_supported'));*/
                                }
                              }else{
                                Message.show(context, AppLocalizations.of(context)!.translate('receive_error'));
                              }
                            }else{
                              Message.show(context, AppLocalizations.of(context)!.translate('receive_error'));
                            }
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.translate('contacts'), style: const TextStyle(color: Colors.blue),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      //if(phoneContact == null)
                      Row(
                        children: [
                          Container(
                            height: 52,
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1, color: Colors.grey[500]!))
                            ),
                            child: CountryCodePicker(
                              onChanged: (countryCode) {
                                setState(() {selectedCountryCode = countryCode.code; selectedPhonePrefix = countryCode.dialCode!; selectedVoucher = null; });
                                loadOperators();
                              },
                              initialSelection: selectedCountryCode,
                              favorite: favoriteCountries,
                              countryFilter: localRestrict ? [initViewModel!.initModel!.countryPrefix!] : availableCountries,
                              showCountryOnly: true,
                              alignLeft: false,
                              dialogSize: Size(AppConfig.screenWidth - 60, AppConfig.screenHeight - 290)
                            ),
                          ),
                          const SizedBox(width: 15),
                        ],
                      ),
                      Expanded(child: TextFormField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        onChanged: (value){ if(value.isEmpty){ setState(() { phoneContact = null; name = null; });}else{ setState(() { phoneNumber = value; }); }},
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          hintText: '2654822145',
                        ),
                        validator: (value){
                          if (value == null) {
                            return AppLocalizations.of(context)!.translate('phone_number_empty_validate');
                          }
                          if(!Helper.isNumeric(value)){
                            return AppLocalizations.of(context)!.translate('phone_validate');
                          }

                          if (value.length < phoneLength) {
                            return AppLocalizations.of(context)!.translate('phone_len_validate_param').replaceAll(RegExp(r'\${len}'), '$phoneLength');
                          }
                          return null;
                        },
                      )),
                    ],
                  ),
                  const SizedBox(height: 25),
                  selectOperatorView(),
                  const SizedBox(height: 25),
                  recentView(),
                  const SizedBox(height: 25)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  
  Widget recentView(){
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.translate('recent'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          recentList.isEmpty ? Text(AppLocalizations.of(context)!.translate('nothing_to_show'), style: TextStyle(color: Colors.grey[500])) : FadingEdgeScrollView.fromSingleChildScrollView(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: ScrollController(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: recentList,
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget termsView(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: GestureDetector(
        onTap: () => setState(() { termsSt = termsSt != null ? !termsSt! : true;}),
        child: Row(
          children: [
            Checkbox(value: termsSt, onChanged: (value) => setState(() { termsSt = value; })),
            Text(AppLocalizations.of(context)!.translate('terms_agree'), style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 2),
            Expanded(
              child: GestureDetector(
                onTap: () async{
                  await Future.delayed(const Duration(milliseconds: 250));
                  if(initViewModel!.getTermsUrl != null){
                    openURL(initViewModel!.getTermsUrl!);
                  }else{
                    Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
                  }
                },
                child: Text(AppLocalizations.of(context)!.translate('terms_and_policies'), style: const TextStyle(color: Colors.blue, fontSize: 13, decoration: TextDecoration.underline, overflow: TextOverflow.ellipsis), maxLines: 1)
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget selectOperatorView(){
    return Focus(
      descendantsAreFocusable: false,
      child: DropdownButtonFormField(
        style: const TextStyle(fontSize: 17, color: Colors.grey),
        iconEnabledColor: Colors.grey[600],
        decoration: Helper.dropDownInputDecoration(),
        items: operatorList.map((int index, String value) {
          return MapEntry(value, DropdownMenuItem<String>(
            value: index.toString(),
            child: Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Row(
                children: [
                  Image.network(dictionaryModel!.operators!.where((element) => element.simName == value).first.sendMoneyFlag!, width: 40,),
                  const SizedBox(width: 8),
                  Text(value, style: const TextStyle(color: Colors.black, fontSize: 14)),
                ],
              ),
            ),
          ));
        }).values.toList(),
        value: selectedOperatorList.toString(),
        dropdownColor: Colors.white,
        isExpanded: true,
        hint: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Text(AppLocalizations.of(context)!.translate('select_operator'), style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ),
        onChanged: submitSt ? (value) {
          var mp = operatorList[int.parse(value.toString())];
          setState(() {
            selectedVoucher = null;
            selectedSimName = mp.toString();
            selectedOperatorList = int.parse(value.toString()); FocusManager.instance.primaryFocus!.unfocus(); //loadVouchers();
          });
        } : null,
        validator: (value){
          if(value == null){
            return AppLocalizations.of(context)!.translate('select_operator');
          }
          return null;
        },
      ),
    );
  }
  Widget selectSimCardView(){
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: const Color(0xffc3efff),
          borderRadius: BorderRadius.circular(30)
      ),
      child: SizedBox(
        width: double.infinity,
        height: ScreenUtil().setHeight(40),
        child: DefaultTabController(
          length: simList.length,
          child: TabBar(
            onTap: (value){
              setState(() {
                selectedSim = value;
                selectedVoucher = null;
                if(!noSimSt){
                  switch(value){
                    case 0:
                      selectedSimName =  initViewModel!.initModel!.globalSim1Name != null ? initViewModel!.initModel!.globalSim1Name! : AppConfig.simData!.cards[0].carrierName;
                      selectedCountryCode =  AppConfig.simData!.cards[0].countryCode.toUpperCase();
                      break;
                    case 1:
                      selectedSimName =  initViewModel!.initModel!.globalSim2Name != null ? initViewModel!.initModel!.globalSim2Name! : AppConfig.simData!.cards[1].carrierName;
                      selectedCountryCode =  AppConfig.simData!.cards[1].countryCode.toUpperCase();
                      break;
                    default:
                      selectedSimName =  AppConfig.simData!.cards[value].carrierName;
                      selectedCountryCode =  AppConfig.simData!.cards[value].countryCode.toUpperCase();
                      break;
                  }
                }
              });
              loadMobileMoneyTitle();
            },
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey[700],
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            indicator: BoxDecoration(
              color: const Color(0xff5197dd),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            tabs: simList,
          ),
        ),
      ),
    );
  }
  Widget selectPaymentView(){
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: const Color(0xffc3efff),
          borderRadius: BorderRadius.circular(30)
      ),
      child: SizedBox(
        width: double.infinity,
        height: ScreenUtil().setHeight(40),
        child: DefaultTabController(
          length: initViewModel!.initModel!.useBalanceEnabled != null && initViewModel!.initModel!.useBalanceEnabled == 1 ? 2 : 1,
          child: TabBar(
            onTap: (value) => setState(() { selectedPayMethod = value; selectedVoucher = null; }),
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey[700],
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            indicator: BoxDecoration(
              color: const Color(0xff5197dd),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            tabs: [
              if(initViewModel!.initModel!.useBalanceEnabled != null && (initViewModel!.initModel!.useBalanceEnabled != 0))
              SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(AppLocalizations.of(context)!.translate('credit'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)]))),
              SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(mobileMoneyTitle, style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)])))
            ],
          ),
        ),
      ),
    );
  }
  Widget rechargeTypeView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(AppLocalizations.of(context)!.translate('recharge_type'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: const Color(0xfff6ffff),
              borderRadius: BorderRadius.circular(30)
          ),
          child: SizedBox(
            width: double.infinity,
            height: ScreenUtil().setHeight(40),
            child: DefaultTabController(
              length: 2,
              child: TabBar(
                onTap: (value){
                  setState(() { selectedType = value; selectedVoucher = null;});
                },
                labelColor: Colors.white,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.grey[700],
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                indicator: BoxDecoration(
                  color: const Color(0xff5197dd),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                tabs: [
                  SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(AppLocalizations.of(context)!.translate('credit_recharge'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1)]))),
                  SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(AppLocalizations.of(context)!.translate('forfait'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1)]))),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
  Widget voucherView(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xffcbf5ff),
            Color(0xffdefdff),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.translate('voucher'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          VoucherPickerField(
            initModel : initViewModel!,
            dictionaryModel: dictionaryModel!,
            onVoucherPicked: (VoucherModel voucherModel) async{
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 250));
              setState(() { selectedVoucher = voucherModel; });
            },
            value: selectedVoucher,
            voucherList: dictionaryModel!.vouchers,
            selectedCountryCode: selectedCountryCode,
            rechargeType: selectedType == 0 ? 'RECHARGE' : 'FORFAIT',
            selectedSimName: selectedSimName,
            selectedPaymentMethod: selectedPayMethod,
            isSelfRecharge: selfChargeSt,
            hint: AppLocalizations.of(context)!.translate('select_voucher'),
          ),
        ],
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
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const Help());
          break;
      }
    });
  }

  void setSideMenu(){
    for (var element in AppConfig.sideMenu!) {
      if(element.id == 2){
        element.active = true;
      }else{
        element.active = false;
      }
    }
  }
  void submitForm() async{
    FocusScope.of(context).unfocus();
    if(selectedVoucher != null){
      if(selfChargeSt){
        selfChargeSubmit();
      }else if(anotherNumberSt){
        anotherNumberSubmit();
      }
    }else{
      Message.show(context, AppLocalizations.of(context)!.translate('voucher_empty_validate'));
    }
  }

  void selfChargeSubmit() async{
    if(termsSt != null && termsSt!){
      try{
        if(initViewModel?.initModel?.customerBalance != null && initViewModel!.initModel!.customerBalance! >= initViewModel!.initModel!.internalRechargeFee){
          await Future.delayed(const Duration(milliseconds: 400));
          showDialog(context: context, builder: (cntx) => QuestionDialog(
            title: '\n\n${AppLocalizations.of(context)!.translate('price')}: ${selectedVoucher!.price} \n\n ${AppLocalizations.of(context)!.translate('service_fee')}: ${initViewModel!.initModel!.internalRechargeFee}\n\n',
            noTitle: AppLocalizations.of(context)!.translate('cancel'),
            yesTitle: AppLocalizations.of(context)!.translate('proceed'),
            onYes: () async{
              await Future.delayed(const Duration(milliseconds: 800));
              callUssd();
          }));
        }else{
          showDialog(context: context, builder: (cntx) => MessageDialog(title: AppLocalizations.of(context)!.translate('not_enough_balance').replaceAll('\'service\'', 'recharge'), onDonePressed: () async{
            await Future.delayed(const Duration(milliseconds: 800));
            AppNavigator.pushReplace(context: context, page: const WalletRefill());
          }));
        }
      }catch(error){
        Navigator.pop(context);
        if(!AppConfig.isPublished){ print('error: $error'); }
      }
    }else{
      Message.show(context, AppLocalizations.of(context)!.translate('terms_agree_validate'));
    }
  }

  void anotherNumberSubmit(){
    if (_formKey.currentState!.validate()) {
      if(termsSt != null && termsSt!){
        try{
          showDialog(context: context, builder: (context) => RechargeDetailDialog(
            operator: operatorList[selectedOperatorList]!,
            explain: selectedVoucher!.voucherNameEn,
            phoneNumber: phoneNumber!,
            amount: selectedVoucher!.price.toString(),
            countryCode: selectedCountryCode,
            onPaypalClicked: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 250));
              paypalClicked();
            },
            onWalletClicked: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 250));
              walletClicked();
            },
          ));
        }catch(error){
          if(!AppConfig.isPublished){ print('error: $error'); }
        }
      }else{
        Message.show(context, AppLocalizations.of(context)!.translate('terms_agree_validate'));
      }
    }
  }

  void callUssd() async{
    try{
      int payMethod = selectedPayMethod!;
      if(initViewModel!.initModel!.useBalanceEnabled == null || initViewModel!.initModel!.useBalanceEnabled == 0){
        payMethod = 1;
      }

      int subscriptionId = -1;
      if(AppConfig.simData!.cards.isNotEmpty && AppConfig.simData!.cards.length > 1){
        if(selectedSim == 0){
          subscriptionId = 1;
        }else if(selectedSim == 1){
          subscriptionId = 2;
        }
      }
      print('subscriptionId: $subscriptionId');
      String? res = await UssdAdvanced.sendAdvancedUssd(code: '*141*3#', subscriptionId: subscriptionId);
      if(res != null){
        if(!AppConfig.isPublished){ print('res: $res');}
        Message.show(context, res);
      }

      /*if(payMethod == 0){
        if(selectedVoucher!.selfRechargeUssdBalance != null && selectedVoucher!.selfRechargeUssdBalance != ''){
          showDialog(context: context, builder: (context) => const LoadingDialog());
          if(!AppConfig.isPublished){ print('ussd: ${selectedVoucher!.selfRechargeUssdBalance}');}
          int subscriptionId = -1;
          if(AppConfig.simData!.cards.isNotEmpty && AppConfig.simData!.cards.length > 1){
            if(selectedSim == 0){
              subscriptionId = 1;
            }else if(selectedSim == 1){
              subscriptionId = 2;
            }
          }
          String? res = await UssdAdvanced.sendAdvancedUssd(code: selectedVoucher!.selfRechargeUssdBalance!, subscriptionId: subscriptionId).whenComplete(() => null);
          Navigator.pop(context);
          if(res != null){
            if(!AppConfig.isPublished){ print('res: $res');}
            Message.show(context, res);
          }
        }else{
          Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
        }
      }else{
        if(selectedVoucher!.selfRechargeUssdMoney != null && selectedVoucher!.selfRechargeUssdMoney != ''){
          showDialog(context: context, builder: (context) => const LoadingDialog());
          if(!AppConfig.isPublished){ print('ussd: ${selectedVoucher!.selfRechargeUssdMoney}');}
          int subscriptionId = -1;
          if(AppConfig.simData!.cards.isNotEmpty && AppConfig.simData!.cards.length > 1){
            if(selectedSim == 0){
              subscriptionId = 1;
            }else if(selectedSim == 1){
              subscriptionId = 2;
            }
          }
          String? res = await UssdAdvanced.sendAdvancedUssd(code: selectedVoucher!.selfRechargeUssdMoney!, subscriptionId: subscriptionId);
          Navigator.pop(context);
          if(res != null){
            if(!AppConfig.isPublished){ print('res: $res');}
            Message.show(context, res);
          }
        }else{
          Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
        }
      }*/
    }catch(error){
      if(!AppConfig.isPublished){ print('error: $error'); }
      Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
    }
  }

  void paypalClicked() async{
    showDialog(context: context, builder: (context) => const LoadingDialog());
    await Future.delayed(const Duration(milliseconds: 3000));
    Navigator.pop(context);
    showDialog(context: context, builder: (context) => SuccessDialog(title: AppLocalizations.of(context)!.translate('transaction_succeeded'), receiptNumber: '#U672Y8974'));
  }

  void walletClicked() async{
    showDialog(context: context, builder: (context) => const LoadingDialog());
    await Future.delayed(const Duration(milliseconds: 3000));
    Navigator.pop(context);
    showDialog(context: context, builder: (context) => FailDialog(title: AppLocalizations.of(context)!.translate('transaction_failed') + '!'));
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