import 'package:flutter/material.dart';
import 'package:sinam/helpers/avatar_view.dart';
import 'package:sinam/models/saved_number_model.dart';

import 'helper.dart';

class RecentItem extends StatelessWidget {
  final SavedNumberModel number;
  final String? avatar;
  const RecentItem({Key? key, required this.number, required this.avatar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          AvatarView(url: avatar, width: 60, height: 60, fit: BoxFit.contain,),
          const SizedBox(height: 10),
          Text(Helper.truncate(number.recipientNumber, length: 6), style: TextStyle(fontSize: 12, color: Colors.grey[600]))
        ],
      ),
    );
  }
}
