
import '../config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchBar extends StatefulWidget {

  final bool? isEnable;
  final String? labelText;
  String? value;
  final Function(String term)? onFieldSubmitted;
  final Function()? onEditingComplete;
  final Function(String value)? onValidate;
  final Function(String value) onChanged;

  SearchBar({Key? key,  this.onEditingComplete, this.onFieldSubmitted, this.onValidate, @required this.labelText, this.value, required this.onChanged, this.isEnable }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  TextEditingController? controller;
  bool? isEmpty;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
    isEmpty = controller!.text.isEmpty;
    controller!.addListener(() {
      if (isEmpty != controller!.text.isEmpty) {
        setState(() {
          isEmpty = controller!.text.isEmpty;
        });
      }
    });

    if(widget.value != null){
      controller!.text = widget.value!;
    }
  }

  @override
  Widget build(BuildContext context) {

    if(widget.value != null){
      controller!.text = widget.value!;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.maxFinite,
        height: 50,
        color: const Color(0xffaae7ff),
        padding: const EdgeInsets.only(right: 5),
        child: TextFormField(
          controller: controller,
          enabled: widget.isEnable ?? true,
          cursorColor: Colors.blue,
          style: TextStyle(fontSize: 17, color: Colors.grey[700]),
          maxLines: 1,
          textInputAction: TextInputAction.search,
          autofocus: false,
          keyboardType: TextInputType.text,
          onFieldSubmitted: (term){
            widget.onFieldSubmitted != null ? widget.onFieldSubmitted!(term) : FocusScope.of(context).unfocus();
          },
          onEditingComplete: (){
            widget.onEditingComplete != null ? widget.onEditingComplete!() : FocusScope.of(context).unfocus();
          },
          onChanged: (value){
            widget.onChanged(value);
          },
          autocorrect: false,
          enableSuggestions: false,
          validator: (value) {
            return widget.onValidate != null ? widget.onValidate!(value!) : null;
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.fromLTRB(18, 13, 0, 0),
            hintText: widget.labelText,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
            border: InputBorder.none,
            filled: true,
            fillColor: const Color(0xffaae7ff),
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(Icons.search_sharp, color: Colors.grey[500], size: 25,),
            ),
            suffixIcon: controller!.text.isNotEmpty ? removeButton() : null,
          ),
        ),
      ),
    );
  }

  Widget removeButton(){
    return GestureDetector( onTap: (){ controller!.clear(); widget.onChanged(''); }, child: Icon(Icons.cancel, size: 21, color: Colors.grey[400]));
  }
}
