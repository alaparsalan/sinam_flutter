import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/helpers/message.dart';
import 'app_localizations.dart';

class CupertinoDatePickerField extends StatefulWidget {

  final Function(DateTime? dateTime) onDatePicked;
  final String? hint;
  final String? helpText;
  final String? disableMessage;
  final DateTime? value;
  final bool? enabled;
  final bool? bordered;
  final bool? hasIcon;
  final bool? hasError;
  final CupertinoDatePickerMode? mode;

  const CupertinoDatePickerField({Key? key,  required this.onDatePicked, this.disableMessage, this.hint, this.helpText, this.value, this.enabled, this.bordered = false, this.hasIcon = true, this.hasError = false, this.mode }) : super(key: key);

  @override
  _CupertinoDatePickerFieldState createState() => _CupertinoDatePickerFieldState();
}

class _CupertinoDatePickerFieldState extends State<CupertinoDatePickerField> {

  late String selectedDate;
  DateTime? pickedDateTime;

  @override
  void initState() {
    super.initState();
    getDate();
  }

  getDate(){
    if(widget.value != null){
      if(widget.mode != null && widget.mode == CupertinoDatePickerMode.dateAndTime){
        selectedDate = DateFormat.yMd().add_Hm().format(widget.value!);
      }else{
        selectedDate = DateFormat.yMd().format(widget.value!);
      }
    }else{
      selectedDate = widget.helpText != null ? widget.helpText! : 'Select date';
    }
  }

  @override
  Widget build(BuildContext context) {
    getDate();
    return GestureDetector(
      onTap: () async{
        if(widget.disableMessage != null){
          Message.show(context, widget.disableMessage!);
        }else{
          if(widget.enabled != null && widget.enabled!){
            getSelectedDate(helpText: widget.helpText, title: widget.helpText != null ? widget.helpText! : 'Select date');
          }
        }
      },
      onLongPress: (){
        setState(() { selectedDate = widget.helpText != null ? widget.helpText! : 'Select date'; });
        widget.onDatePicked(null);
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xffaae7ff),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            widget.hasIcon != null && widget.hasIcon! ? Row(
              children: [
                Icon(Icons.access_time_sharp, color: Colors.grey[400]),
                const SizedBox(width: 12),
              ],
            ) : Container(),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(selectedDate, style: TextStyle(fontSize: 14 ,color: selectedDate == widget.helpText ? Colors.grey[500] : Colors.grey[700]), textAlign: TextAlign.center),
            )),
          ],
        ),
      ),
    );
  }

  void getSelectedDate({ String? helpText, required String title }){
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
            height: AppConfig.screenHeight / 3 + 50,
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
                      Row(
                        children: [
                          TextButton(
                            onPressed: () async{
                              if(pickedDateTime != null){
                                setState(() {
                                  if(widget.mode != null && widget.mode == CupertinoDatePickerMode.dateAndTime) {
                                    selectedDate = DateFormat.yMMMMd().add_Hm().format(pickedDateTime!);
                                  }else{
                                    selectedDate = DateFormat.yMMMMd().format(pickedDateTime!);
                                  }
                                });
                                widget.onDatePicked(pickedDateTime!);
                              }else{
                                setState(() {
                                  if(widget.mode != null && widget.mode == CupertinoDatePickerMode.dateAndTime) {
                                    selectedDate = DateFormat.yMMMMd().add_Hm().format(DateTime.now());
                                  }else{
                                    selectedDate = DateFormat.yMMMMd().format(DateTime.now());
                                  }
                                });
                                widget.onDatePicked(DateFormat('yyyy-MM-dd').parse(DateTime.now().toString()));
                              }
                              await Future.delayed(const Duration(milliseconds: 250));
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context)!.translate('done'), style: TextStyle(color: Colors.blue[600]))
                          ),
                          SizedBox(width: 40, child: TextButton(onPressed: () async{
                            await Future.delayed(const Duration(milliseconds: 250));
                            Navigator.of(context).pop();
                          }, child: Icon(Icons.clear, size: 26, color: Colors.grey[500]))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: widget.mode != null ? widget.mode! : CupertinoDatePickerMode.date,
                    onDateTimeChanged: (picked) {
                      setState(() { pickedDateTime = picked;});
                    },
                    initialDateTime: widget.value != null ? widget.value! : DateFormat('yyyy-MM-dd').parse(DateTime.now().toString()),
                    minimumYear: 2000,
                    maximumYear: 2200,
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}