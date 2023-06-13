import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tulibot/config/config.dart';

class VerifyAlert extends StatelessWidget {
  const VerifyAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.titleVerify,
            style: TextStyle(fontSize: 24.sp)),
        content: Text(AppLocalizations.of(context)!.contentVerify,
            style: TextStyle(fontSize: 16.sp)),
        actions: [
          TextButton(
              child: Text('OK',
                  style: TextStyle(color: kTealColor, fontSize: 16.sp)),
              onPressed: () => Navigator.of(context).pop())
        ]);
  }
}
