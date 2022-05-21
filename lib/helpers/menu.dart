import 'package:flutter/material.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/profile/profile.dart';
import 'menu_tile.dart';
import 'package:provider/provider.dart';

class Menu extends StatefulWidget {

  final Function(String page) goToPage;
  const Menu({Key? key, required this.goToPage}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  late InitViewModel initViewModel;

  @override
  void initState() {
    super.initState();
    initViewModel = context.read<InitViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 70),
              GestureDetector(
                onTap: () async{
                  await Future.delayed(const Duration(milliseconds: 250));
                  AppNavigator.push(context: context, page: const Profile());
                },
                child: Column(
                  children: [
                    Image.asset('assets/images/icon.png', width: 80, height: 80),
                    const SizedBox(height: 15),
                    Text(initViewModel.customerName ?? 'Nan', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: FadingEdgeScrollView.fromListView(
                  child: ListView.builder(
                    controller: ScrollController(),
                    padding: const EdgeInsets.only(top: 0),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => MenuTile(goToPage: widget.goToPage, sideMenu: AppConfig.sideMenu![index]),
                    itemCount: AppConfig.sideMenu!.length
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
