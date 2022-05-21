import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/image_view.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/init_model.dart';
import 'package:sinam/models/operator_model.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:provider/provider.dart';
import 'package:sinam/view_models/wallet_view_model.dart';

class AddPaymentNumberView extends StatefulWidget {
  final Function() onReload;
  const AddPaymentNumberView({Key? key, required this.onReload}) : super(key: key);

  @override
  _AddPaymentNumberViewState createState() => _AddPaymentNumberViewState();
}

class _AddPaymentNumberViewState extends State<AddPaymentNumberView> {

  TextEditingController phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Storage storage = Storage();
  List<OperatorModel> operatorList = [];
  OperatorModel? selectedOperatorList;
  DictionaryModel? dictionaryModel;
  InitModel? initModel;
  String? selectedCountryCode;
  String? phoneNumber;
  bool submitSt = true;

  @override
  void initState() {
    super.initState();
    selectedCountryCode = context.read<InitViewModel>().initModel!.customerCountryCode;
    dictionaryModel = context.read<InitViewModel>().dictionaryModel;
    initModel = context.read<InitViewModel>().initModel;
    loadOperators();
  }

  void loadOperators(){
    operatorList.clear();
    selectedOperatorList = null;
    if(dictionaryModel!.operators != null && dictionaryModel!.operators!.isNotEmpty){
      for (var element in dictionaryModel!.operators!){
        if(element.countryCode == selectedCountryCode){
          operatorList.add(element);
        }
      }
      if(operatorList.isNotEmpty){
        selectedOperatorList = operatorList.first;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1, color: Colors.grey[500]!))
                        ),
                        child: CountryCodePicker(
                            initialSelection: selectedCountryCode,
                            countryFilter: [selectedCountryCode!],
                            enabled: false,
                        ),
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
                  Expanded(child: TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    onChanged: (value){ setState(() { phoneNumber = value; }); },
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
                      if (value.length < 7) {
                        return AppLocalizations.of(context)!.translate('phone_validate');
                      }
                      return null;
                    },
                  )),
                ],
              ),
              const SizedBox(height: 30),
              Focus(
                descendantsAreFocusable: false,
                child: DropdownButtonFormField(
                  style: const TextStyle(fontSize: 17, color: Colors.grey),
                  iconEnabledColor: Colors.grey[600],
                  decoration: Helper.dropDownInputDecoration(),
                  items: operatorList.map<DropdownMenuItem<OperatorModel>>((OperatorModel value) {
                    return DropdownMenuItem<OperatorModel>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Row(
                          children: [
                            ImageView(
                              url: value.sendMoneyFlag,
                              width: 25.0,
                              height: 25.0,
                            ),
                            const SizedBox(width: 10),
                            Text(value.operatorName, style: const TextStyle(color: Colors.black, fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  //value: selectedOperatorList.toString(),
                  dropdownColor: Colors.grey[200],
                  isExpanded: true,
                  hint: Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(AppLocalizations.of(context)!.translate('select_your_operator'), style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  ),
                  onChanged: submitSt ? (value) => setState(() { selectedOperatorList = value as OperatorModel?; FocusManager.instance.primaryFocus!.unfocus(); } ) : null,
                  validator: (value){
                    if(value == null){
                      return AppLocalizations.of(context)!.translate('select_your_operator');
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              GradiantButton(
                title: AppLocalizations.of(context)!.translate('save'),
                radius: 10,
                width: double.maxFinite,
                endColor: const Color(0xff3b7acc),
                onPressed: () async{
                  await Future.delayed(const Duration(milliseconds: 250));
                  submitForm();
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitForm() async{
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try{
        showDialog(context: context, builder: (context) => const LoadingDialog());
        String? customerID = await storage.getString('customer_id');
        if(customerID != null){
          dynamic result = await context.read<WalletViewModel>().addRefillNumber(context, customerID: customerID, countryCode: selectedCountryCode!, operatorID: selectedOperatorList!.operatorCode.toString(), number: phoneNumber);
          context.read<InitViewModel>().getInit(context, customerID);
          Navigator.pop(context);

          if(result is bool && result == false){
            Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
          }else{
            if(result is String){
              Message.show(context, result);
            }else{
              if(result['message'] != null && result['message'] != ''){
                Message.show(context, result['message']);
                await Future.delayed(const Duration(milliseconds: 250));
                widget.onReload();
                Navigator.pop(context);
              }
            }
          }
        }else{
          await Future.delayed(const Duration(milliseconds: 250));
          Navigator.pop(context);
          Message.show(context, AppLocalizations.of(context)!.translate('receive_error'));
        }
      }catch(error){
        if(!AppConfig.isPublished){print('Error: $error');}
        Message.show(context, AppLocalizations.of(context)!.translate('receive_error'));
      }
    }
  }
}