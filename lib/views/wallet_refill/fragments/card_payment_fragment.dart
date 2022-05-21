import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/dialogs/refill_detail_dialog.dart';
import 'package:sinam/dialogs/success_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class CardPaymentFragment extends StatefulWidget {
  const CardPaymentFragment({Key? key}) : super(key: key);

  @override
  _CardPaymentFragmentState createState() => _CardPaymentFragmentState();
}

class _CardPaymentFragmentState extends State<CardPaymentFragment> with AutomaticKeepAliveClientMixin<CardPaymentFragment>, TickerProviderStateMixin  {

  final _formKey = GlobalKey<FormState>();
  String? amount;
  bool submitSt = true;
  bool? termsSt = false;
  late InitViewModel initViewModel;

  @override
  void initState() {
    super.initState();
    initViewModel = context.read<InitViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
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
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Text('€', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[500]),),
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
                    const SizedBox(height: 30),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.paypal, color: Colors.grey[300]!.withOpacity(.5), size: 25),
                          const SizedBox(width: 20),
                          FaIcon(FontAwesomeIcons.ccVisa, color: Colors.grey[300]!.withOpacity(.5), size: 25),
                          const SizedBox(width: 20),
                          FaIcon(FontAwesomeIcons.ccMastercard, color: Colors.grey[300]!.withOpacity(.5), size: 25),
                          const SizedBox(width: 20),
                          FaIcon(FontAwesomeIcons.ccAmex, color: Colors.grey[300]!.withOpacity(.5), size: 25),
                        ],
                      ),
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
                child: Text(AppLocalizations.of(context)!.translate('terms_and_policies'), style: TextStyle(color: Colors.blue[200]!, fontSize: 13, decoration: TextDecoration.underline), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)
            ),
          ],
        ),
      ),
    );
  }

  void submitForm(){
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if(termsSt != null && termsSt!){
        try{
          showDialog(context: context, builder: (context) => RefillDetailDialog(
            amount: '5555',
            onCardsOrPaypalClicked: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 250));
              paypalClicked();
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

  void paypalClicked() async{
    showDialog(context: context, builder: (context) => const LoadingDialog());
    await Future.delayed(const Duration(milliseconds: 3000));
    Navigator.pop(context);
    showDialog(context: context, builder: (context) => SuccessDialog(title: AppLocalizations.of(context)!.translate('transaction_succeeded'), receiptNumber: '#U672Y8974'));
  }

  @override
  bool get wantKeepAlive => true;
}
