
import 'package:flutter/material.dart';
import 'package:sinam/config/app_colors.dart';
import '../../models/side_menu.dart';

class MenuTile extends StatefulWidget {

  final SideMenu sideMenu;
  final Function(String page) goToPage;

  const MenuTile({Key? key,  required this.goToPage, required this.sideMenu }) : super(key: key);

  @override
  _MenuTileState createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> {
  @override
  Widget build(BuildContext context) {

    return TextButton(
      onPressed: () => widget.goToPage(widget.sideMenu.page),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center ,
          children: <Widget>[
            const SizedBox(width: 17),
            Opacity(opacity: widget.sideMenu.active ? 1 : .3, child: widget.sideMenu.icon),
            const SizedBox(width: 17),
            Padding(
              padding: const EdgeInsets.only(top:3.0),
              child: Text(widget.sideMenu.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: widget.sideMenu.active ? Colors.white : AppColors.menuItemColor)),
            )
          ],
        ),
      ),
    );
  }
}