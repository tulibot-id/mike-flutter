import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tulibot/config/config.dart';

class AlertNoInternet extends StatelessWidget {
  const AlertNoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.titleNoInternet,
          style: TextStyle(fontSize: 24.sp)),
      content: Text(AppLocalizations.of(context)!.contentNoInternet,
          style: TextStyle(fontSize: 16.sp)),
      actions: [
        TextButton(
            child: Text('OK',
                style: TextStyle(fontSize: 16.sp, color: kTealColor)),
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }
}
