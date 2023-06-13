import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tulibot/config/config.dart';
import 'package:tulibot/provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TitleButton extends StatelessWidget {
  const TitleButton({Key? key, required this.controller}) : super(key: key);
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Selector<PageService, bool>(
              selector: (_, service) => service.isLoginPage,
              builder: (context, value, child) => Text(
                  AppLocalizations.of(context)!.login,
                  style: TextStyle(
                      color: value ? kTealColor : Colors.grey,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w500)),
            ),
            onPressed: () => controller.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut)),
        SizedBox(width: 10.w),
        TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Selector<PageService, bool>(
              selector: (_, service) => service.isLoginPage,
              builder: (context, value, child) => Text(
                  AppLocalizations.of(context)!.signup,
                  style: TextStyle(
                      color: value ? Colors.grey : kTealColor,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w500)),
            ),
            onPressed: () {
              controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            }),
      ],
    );
  }
}
