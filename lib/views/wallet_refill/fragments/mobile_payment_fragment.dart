
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/dialogs/fail_dialog.dart';
import 'package:sinam/dialogs/message_dialog.dart';
import 'package:sinam/dialogs/success_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/models/operator_ussd_model.dart';
import 'package:sinam/models/payment_number_model.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/wallet_refill/components/add_payment_number_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

class MobilePaymentFragment extends StatefulWidget {
  const MobilePaymentFragment({Key? key}) : super(key: key);

  @override
  _MobilePaymentFragmentState createState() => _MobilePaymentFragmentState();
}


class _MobilePaymentFragmentState extends State<MobilePaymentFragment> with AutomaticKeepAliveClientMixin<MobilePaymentFragment>, TickerProviderStateMixin  {

  final _formKey = GlobalKey<FormState>();
  String? amount;
  bool submitSt = true;
  bool? termsSt = false;
  int? selectedSim = 0;
  String selectedSimName = '';
  List<Widget> simList = [];
  bool noSimSt = false;
  late InitViewModel initViewModel;
  final Storage storage = Storage();

  List<PaymentNumberModel> numberList = [];
  PaymentNumberModel? selectedNumberList;

  @override
  void initState() {
    super.initState();
    initViewModel = context.read<InitViewModel>();
    if(initViewModel.initModel!.paymentNumbers != null && initViewModel.initModel!.paymentNumbers!.isNotEmpty){
      numberList = initViewModel.initModel!.paymentNumbers!;
    }
    loadSims();
  }

  void loadSims(){
    simList.clear();
    if(AppConfig.simData != null){
      if(AppConfig.simData!.cards.isNotEmpty){
        for (var element in AppConfig.simData!.cards) {
          simList.add(
            SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(element.carrierName, style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)]))),
          );
        }
        selectedSimName =  AppConfig.simData!.cards.first.carrierName;
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: ScreenUtil().setHeight(18)),
        Expanded(
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            child: SingleChildScrollView(
              controller: ScrollController(),
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20), horizontal: ScreenUtil().setWidth(20.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.translate('refill_numbers'), style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () => addNumberTapped(),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.add_circle_outline, size: 20),
                                      const SizedBox(width: 6),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 1.0),
                                        child: Text(AppLocalizations.of(context)!.translate('add_refill_number'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: ScreenUtil().setHeight(6)),
                          Focus(
                            descendantsAreFocusable: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: DropdownButtonFormField(
                                style: const TextStyle(fontSize: 17, color: Colors.grey),
                                iconEnabledColor: Colors.grey[600],
                                decoration: Helper.roundDropDownInputDecoration(),
                                items: numberList.map((PaymentNumberModel value) {
                                  return DropdownMenuItem<PaymentNumberModel>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: Text('${value.countryDialPrefix} ${value.number}', style: const TextStyle(color: Colors.black, fontSize: 14)),
                                    ),
                                  );
                                }).toList(),
                                dropdownColor: Colors.grey[200],
                                isExpanded: true,
                                hint: Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Text(AppLocalizations.of(context)!.translate('select_number'), style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                                ),
                                onChanged: submitSt ? (value) => setState(() { selectedNumberList = value as PaymentNumberModel?; FocusManager.instance.primaryFocus!.unfocus(); } ) : null,
                                validator: (value){
                                  if(value == null || value == 'null'){
                                    return AppLocalizations.of(context)!.translate('refill_number_empty_validate');
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            labelText: AppLocalizations.of(context)!.translate('enter_refill_amount'),
                            borderRadius: 30,
                            borderColor: const Color(0xffc3efff),
                            backgroundColor: const Color(0xffc3efff),
                            textInputType: TextInputType.number,
                            inputAction: TextInputAction.done,
                            onChanged: (value){ setState(() { amount = value; });},
                            onValidate: (value){
                              if(value.isEmpty){
                                return AppLocalizations.of(context)!.translate('amount_empty_validate');
                              }
                              return null;
                            },
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Text(initViewModel.initModel?.customerSelectedCurrencyCode ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500]),),
                            ),
                          ),
                          termsView(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GradiantButton(
                      title: AppLocalizations.of(context)!.translate('send'),
                      radius: 40,
                      width: double.maxFinite,
                      endColor: const Color(0xff3b7acc),
                      onPressed: () async{
                        await Future.delayed(const Duration(milliseconds: 250));
                        submitForm();
                      }
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget termsView(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: GestureDetector(
        onTap: () => setState(() { termsSt = termsSt != null ? !termsSt! : true;}),
        child: Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: const Color(0xffc3efff),
              ),child: Checkbox(value: termsSt, onChanged: (value) => setState(() { termsSt = value; }), checkColor: Colors.blue[700], activeColor: const Color(0xffc3efff))
            ),
            Text(AppLocalizations.of(context)!.translate('terms_agree'), style: const TextStyle(fontSize: 13, color: Colors.white)),
            const SizedBox(width: 2),
            GestureDetector(
                onTap: () async{
                  await Future.delayed(const Duration(milliseconds: 250));
                  if(initViewModel.getTermsUrl != null){
                    openURL(initViewModel.getTermsUrl!);
                  }else{
                    Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
                  }
                },
                child: Text(AppLocalizations.of(context)!.translate('terms_and_policies'), style: TextStyle(color: Colors.blue[200]!, fontSize: 13, decoration: TextDecoration.underline), maxLines: 1, overflow: TextOverflow.ellipsis)
            ),
          ],
        ),
      ),
    );
  }

  void submitForm() async{
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if(termsSt != null && termsSt!){
        try{
          String? customerID = await storage.getString('customer_id');
          if(initViewModel.dictionaryModel != null && initViewModel.dictionaryModel!.operatorsUssd != null && initViewModel.dictionaryModel!.operatorsUssd!.isNotEmpty && customerID != null){
            OperatorUssdModel? operatorUssdModel;
            for (var element in initViewModel.dictionaryModel!.operatorsUssd!) {
              if((int.parse(element.operatorCode).toString() == int.parse(selectedNumberList!.operatorCode.toString()).toString()) && (element.service == 'REFILL') && (element.countryCode.toLowerCase() == selectedNumberList!.countryCode.toLowerCase())){
                operatorUssdModel = element;
              }
            }

            if(operatorUssdModel != null){
              int subscriptionId = -1;
              showDialog(context: context, builder: (cntx) => MessageDialog(title: AppLocalizations.of(context)!.translate('ussd_notified_message'), onDonePressed: () async{
                callUssd(subscriptionId, operatorUssdModel!, customerID);
              }));
            }else{
              Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
            }
          }else{
            Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
          }
        }catch(error){
          if(!AppConfig.isPublished){ print('error: $error'); }
          Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
        }
      }else{
        Message.show(context, AppLocalizations.of(context)!.translate('terms_agree_validate'));
      }
    }
  }

  void callUssd(int subscriptionId, OperatorUssdModel operatorUssdModel, String customerID) async{
    try{
      if(AppConfig.simData!.cards.isNotEmpty && AppConfig.simData!.cards.length > 1){
        if(selectedSim == 0){
          subscriptionId = 1;
        }else if(selectedSim == 1){
          subscriptionId = 2;
        }
      }
      if(!AppConfig.isPublished){
        print('subscriptionId: $subscriptionId');
        print('ussd: ${operatorUssdModel.ussdString.replaceAll('{amount}', amount!)}');
      }
      await UssdAdvanced.sendUssd(code: operatorUssdModel.ussdString.replaceAll('{amount}', amount!), subscriptionId: subscriptionId).timeout(const Duration(seconds: 8));
      AppConfig.confirmPaymentSt = true;
      dynamic res = await initViewModel.confirmMobilePayment(context, customerID: customerID, selectedNumberList: selectedNumberList,amount: amount, date: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()));
      if(res is bool && res == false){
        AppConfig.confirmPaymentSt == false;
        showDialog(context: context, builder: (cntx) => MessageDialog(title: AppLocalizations.of(context)!.translate('went_wrong_contact'), onDonePressed: (){
          AppConfig.forceLogoutSt = true;
          Navigator.pop(context);
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
    }catch(error){
      if(!AppConfig.isPublished){ print('error: $error'); }
      if(!error.toString().startsWith('PlatformException(error, Unsupported value: ')){
        Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
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

  void addNumberTapped() async{
    await Future.delayed(const Duration(milliseconds: 250));
    showMaterialModalBottomSheet(
        context: context,
        barrierColor: Colors.black.withAlpha(140),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius:BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25)),
        ),
        builder: (BuildContext builder) {
          return SizedBox(
            height: AppConfig.screenHeight - ScreenUtil().setHeight(100),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 4,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.translate('add_refill_number')),
                      SizedBox(width: 40, child: TextButton(onPressed: () async{
                        await Future.delayed(const Duration(milliseconds: 250));
                        Navigator.of(context).pop();
                      }, child: Icon(Icons.clear, size: 26, color: Colors.grey[500]))),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: AddPaymentNumberView(onReload: () => setState(() {})),
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  bool get wantKeepAlive => true;
}
