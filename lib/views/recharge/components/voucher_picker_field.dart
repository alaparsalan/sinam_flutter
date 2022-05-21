import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/models/destination_country_model.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/voucher_model.dart';
import 'package:sinam/view_models/init_view_model.dart';

class VoucherPickerField extends StatefulWidget {
  final Function(VoucherModel voucherModel) onVoucherPicked;
  final String? hint;
  final bool? enabled;
  final VoucherModel? value;
  final List<VoucherModel>? voucherList;
  final String rechargeType;
  final String? selectedCountryCode;
  final String? selectedSimName;
  final int? selectedPaymentMethod;
  final bool isSelfRecharge;
  final InitViewModel initModel;
  final DictionaryModel dictionaryModel;

  const VoucherPickerField({Key? key,  required this.onVoucherPicked, this.enabled, this.hint, this.value, required this.voucherList, required this.rechargeType,
    this.selectedCountryCode, this.selectedSimName, this.selectedPaymentMethod, required this.isSelfRecharge, required this.initModel, required this.dictionaryModel
  }) : super(key: key);

  @override
  _VoucherPickerFieldState createState() => _VoucherPickerFieldState();
}

class _VoucherPickerFieldState extends State<VoucherPickerField> with AutomaticKeepAliveClientMixin<VoucherPickerField> {

  String? selectedVoucherText;
  List<VoucherModel> rechargeList = [];
  List<VoucherModel> callList = [];
  List<VoucherModel> dataList = [];
  List<VoucherModel> mixedList = [];

  @override
  void initState() {
    super.initState();
    loadVouchers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getDate();
  }

  void loadVouchers(){
    rechargeList.clear();
    callList.clear();
    dataList.clear();
    mixedList.clear();

    if(widget.voucherList != null && widget.voucherList!.isNotEmpty){
      for (var element in widget.voucherList!){
        if(element.voucherType == 'RECHARGE'){
          if(element.countryCode == widget.selectedCountryCode && element.simName.toLowerCase() == widget.selectedSimName!.toLowerCase()){
            rechargeList.add(element);
          }
        }
        if(element.voucherType == 'FORFAIT'){
          if(element.subType != null && element.subType == 'CALL'){
            if(element.countryCode == widget.selectedCountryCode && element.simName.toLowerCase() == widget.selectedSimName!.toLowerCase()){
              if(widget.isSelfRecharge){
                if(widget.selectedPaymentMethod == 0){ // balance
                  if(element.paymentMethod == 'CREDIT'){
                    callList.add(element);
                  }
                }else{
                  if(element.paymentMethod == 'MONEY'){
                    callList.add(element);
                  }
                }
              }else{
                callList.add(element);
              }
            }
          }

          if(element.subType != null && element.subType == 'DATA'){
            if(element.countryCode == widget.selectedCountryCode && element.simName.toLowerCase() == widget.selectedSimName!.toLowerCase()){
              if(widget.isSelfRecharge){
                if(widget.selectedPaymentMethod == 0){ // balance
                  if(element.paymentMethod == 'CREDIT'){
                    dataList.add(element);
                  }
                }else{
                  if(element.paymentMethod == 'MONEY'){
                    dataList.add(element);
                  }
                }
              }else{
                dataList.add(element);
              }
            }
          }

          if(element.subType != null && element.subType == 'MIXED'){
            if(element.countryCode == widget.selectedCountryCode && element.simName.toLowerCase() == widget.selectedSimName!.toLowerCase()){
              if(widget.isSelfRecharge){
                if(widget.selectedPaymentMethod == 0){ // balance
                  if(element.paymentMethod == 'CREDIT'){
                    mixedList.add(element);
                  }
                }else{
                  if(element.paymentMethod == 'MONEY'){
                    mixedList.add(element);
                  }
                }
              }else{
                mixedList.add(element);
              }
            }
          }
        }
      }
    }
  }

  void getDate(){
    if(widget.value != null){
      selectedVoucherText = AppConfig.selectedLanguage == 'en' ? widget.value!.voucherNameEn : widget.value!.voucherNameFr;
    }else{
      selectedVoucherText = widget.hint != null ? widget.hint! : AppLocalizations.of(context)!.translate('select_voucher');
    }
  }

  @override
  Widget build(BuildContext context) {
    loadVouchers();
    getDate();

    print('value: ${widget.value}');
    print('voucherList: ${widget.voucherList.toString()}');
    print('rechargeType: ${widget.rechargeType}');
    print('selectedCountryCode: ${widget.selectedCountryCode}');
    print('selectedSimName: ${widget.selectedSimName}');

    return GestureDetector(
      onTap: () async{
        getSelectedVoucher(title: AppLocalizations.of(context)!.translate('select_voucher'));
      },
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border:  Border.all(color: Colors.grey, width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 2.0, right: 15, left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(selectedVoucherText ?? (widget.hint ?? ''), style: TextStyle(fontSize: 14 ,color: selectedVoucherText == widget.hint ? Colors.grey[500] : Colors.grey[700], overflow: TextOverflow.ellipsis), textAlign: TextAlign.left, maxLines: 1)),
              Icon(Icons.arrow_drop_down_outlined, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void getSelectedVoucher({ String? helpText, required String title }){
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
                      Text(title),
                      SizedBox(width: 40, child: TextButton(onPressed: () async{
                        await Future.delayed(const Duration(milliseconds: 250));
                        Navigator.of(context).pop();
                      }, child: Icon(Icons.clear, size: 26, color: Colors.grey[500]))),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: widget.rechargeType == 'RECHARGE' ? rechargeListView() : forfaitListView(),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget rechargeListView(){
    return rechargeList.isEmpty ? notFoundView() : FadeInUp(
      from: 10,
      child: FadingEdgeScrollView.fromListView(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          controller: ScrollController(),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => voucherView(rechargeList[index]),
          itemCount: rechargeList.length
        ),
      ),
    );
  }

  Widget callListView(){
    return callList.isEmpty ? notFoundView() : FadingEdgeScrollView.fromListView(
      child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
          controller: ScrollController(),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => voucherView(callList[index]),
          itemCount: callList.length
      ),
    );
  }
  Widget dataListView(){
    return dataList.isEmpty ? notFoundView() : FadingEdgeScrollView.fromListView(
      child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
          controller: ScrollController(),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => voucherView(dataList[index]),
          itemCount: dataList.length
      ),
    );
  }
  Widget mixListView(){
    return mixedList.isEmpty ? notFoundView() : FadingEdgeScrollView.fromListView(
      child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
          controller: ScrollController(),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => voucherView(mixedList[index]),
          itemCount: mixedList.length
      ),
    );
  }

  Widget forfaitListView(){
    return FadeInUp(
      from: 10,
      child: DefaultTabController(
        length: 3,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.grey[200],
                  child: TabBar(
                    labelColor: Colors.white,
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    unselectedLabelColor: Colors.grey[700],
                    unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    indicator: BoxDecoration(
                      color: const Color(0xff5197dd),
                      borderRadius: BorderRadius.circular(10),
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
                      SizedBox(height:67 ,child: Tab(child: Column( children: [ const SizedBox(height: 12), Text(AppLocalizations.of(context)!.translate('call'), textScaleFactor: 1.05), const SizedBox(height: 8)]))),
                      SizedBox(height:67 ,child: Tab(child: Column( children: [ const SizedBox(height: 12), Text(AppLocalizations.of(context)!.translate('data'), textScaleFactor: 1.05), const SizedBox(height: 8)]))),
                      SizedBox(height:67 ,child: Tab(child: Column( children: [ const SizedBox(height: 12), Text(AppLocalizations.of(context)!.translate('mix'), textScaleFactor: 1.05), const SizedBox(height: 8)]))),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    callListView(),
                    dataListView(),
                    mixListView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget notFoundView(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Text(AppLocalizations.of(context)!.translate('no_voucher_for_operator_or_type'), style: TextStyle(fontSize: 13, color: Colors.grey[400]), textAlign: TextAlign.center),
      ),
    );
  }

  double getExchangedAmount(String currency, double amount) {
    return widget.initModel.customerSelectedCurrencyCode == currency ? amount : (amount/(widget.initModel.currencyExchangeRate!.where((element) => element.customerCurrency == widget.initModel.customerSelectedCurrencyCode && element.destinationCurrency == currency).first.rate!));
  }
  
  Widget voucherView(VoucherModel model){
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(width: 100,child: Text(AppLocalizations.of(context)!.translate('forfait'), style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold))),
                  Expanded(child: Text(AppConfig.selectedLanguage == 'en' ? model.voucherNameEn : model.voucherNameFr, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if(model.data != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(width: 100,child: Text(AppLocalizations.of(context)!.translate('data'), style: TextStyle(color: Colors.grey[500]))),
                            Expanded(child: Text(model.data!)),
                          ],
                        ),
                      ),
                      if(model.validity != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(width: 100,child: Text(AppLocalizations.of(context)!.translate('validity'), style: TextStyle(color: Colors.grey[500]))),
                            Expanded(child: Text(model.validity!)),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(width: 100,child: Text(AppLocalizations.of(context)!.translate('price'), style: TextStyle(color: Colors.grey[500]))),
                            Expanded(child: Text('${NumberFormat("#,##0.00", "en_US").format(widget.initModel.customerSelectedCurrencyCode == 'CFA' ? model.price : getExchangedAmount('CFA', model.price.toDouble()))} ${widget.initModel.customerSelectedCurrencySymbol}')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2)
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(widget.dictionaryModel.operators!.where((element) => element.operatorCode == model.operatorCode).toList().first.sendMoneyFlag!, height: 40,),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 5),
            SizedBox(
              width: double.maxFinite,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[700],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // <-- Radius
                  ),
                ),
                onPressed: () async{
                  setState(() {
                    selectedVoucherText = AppConfig.selectedLanguage == 'en' ? model.voucherNameEn : model.voucherNameFr;
                  });
                  await Future.delayed(const Duration(milliseconds: 250));
                  widget.onVoucherPicked(model);
                },
                child: Text(AppLocalizations.of(context)!.translate('select')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}