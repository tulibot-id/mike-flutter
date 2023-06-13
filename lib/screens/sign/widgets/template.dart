import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tulibot/config/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tulibot/screens/sign/widgets/forgot_password.dart';

class CustomTemplate extends StatelessWidget {
  const CustomTemplate(
      {Key? key,
      required this.formKey,
      required this.title,
      required this.textSubtitle,
      this.onPressedGoogle,
      // this.onPressedMicrosoft,
      required this.isCheck,
      required this.onChangedCheckBox,
      required this.textButton1,
      required this.textButton2,
      required this.onTapTextButton,
      required this.onPressedButton,
      required this.onChangedEmail,
      required this.onChangedPassword,
      this.onChangedName,
      this.onTogglePassword,
      required this.showPassword})
      : super(key: key);
  final Key formKey;
  final String title;
  final String textSubtitle;
  final Function()? onPressedGoogle;
  // final Function()? onPressedMicrosoft;
  final Function(String)? onChangedName;
  final Function(String) onChangedEmail;
  final Function(String) onChangedPassword;
  final bool isCheck;
  final ValueChanged<bool?> onChangedCheckBox;
  final Function() onPressedButton;
  final String textButton1;
  final String textButton2;
  final Function() onTapTextButton;
  final Function()? onTogglePassword;
  final bool showPassword;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(textSubtitle,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
          SizedBox(height: 40.h),
          title == AppLocalizations.of(context)!.login
              ? Center(
                  child: ElevatedButton.icon(
                      icon: SvgPicture.asset('assets/logos/google.svg',
                          width: 20.r, height: 20.r),
                      label: Text(
                        AppLocalizations.of(context)!.withGoogle(title),
                        style: TextStyle(color: Colors.black, fontSize: 16.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          minimumSize: Size(250.w, 50.h),
                          elevation: 0,
                          shape: const StadiumBorder()),
                      onPressed: onPressedGoogle),
                )
              : const SizedBox(),
          SizedBox(height: 10.h),
          // title == AppLocalizations.of(context)!.login
          //     ? Center(
          //         child: ElevatedButton.icon(
          //             icon: SvgPicture.asset('assets/logos/microsoft.svg',
          //                 width: 20.r, height: 20.r),
          //             label: Text(
          //               AppLocalizations.of(context)!.withMicrosoft(title),
          //               style: TextStyle(color: Colors.black, fontSize: 16.sp),
          //             ),
          //             style: ElevatedButton.styleFrom(
          //                 primary: Colors.white,
          //                 minimumSize: Size(250.w, 50.h),
          //                 elevation: 0,
          //                 shape: const StadiumBorder()),
          //             onPressed: onPressedMicrosoft),
          //       )
          //     : const SizedBox(),
          SizedBox(height: 12.h),
          title == AppLocalizations.of(context)!.login
              ? Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.black26)),
                    Container(
                      margin: EdgeInsets.all(10.r),
                      child: Text(AppLocalizations.of(context)!.line(title),
                          style: TextStyle(
                              color: Colors.black26, fontSize: 16.sp)),
                    ),
                    const Expanded(child: Divider(color: Colors.black26)),
                  ],
                )
              : Container(),
          SizedBox(height: 12.h),
          title == AppLocalizations.of(context)!.login
              ? Container()
              : Text.rich(TextSpan(
                  text: AppLocalizations.of(context)!.name,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  children: [
                      TextSpan(
                          text: '*',
                          style: TextStyle(color: kTealColor, fontSize: 14.sp))
                    ])),
          title == AppLocalizations.of(context)!.login
              ? Container()
              : SizedBox(height: 8.h),
          title == AppLocalizations.of(context)!.login
              ? Container()
              : TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.name,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 26.w, vertical: 20.h),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: kTealColor)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28))),
                  style: TextStyle(fontSize: 16.sp),
                  cursorColor: kTealColor,
                  validator: (name) => name != null && name.length < 4
                      ? AppLocalizations.of(context)!.errorName
                      : null,
                  onChanged: onChangedName,
                ),
          title == AppLocalizations.of(context)!.login
              ? Container()
              : SizedBox(height: 20.h),
          Text.rich(TextSpan(
              text: AppLocalizations.of(context)!.email,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                    text: '*',
                    style: TextStyle(color: kTealColor, fontSize: 14.sp))
              ])),
          SizedBox(height: 8.h),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                hintText: 'mail@website.com',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 26.w, vertical: 20.h),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: kTealColor)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28))),
            style: TextStyle(fontSize: 16.sp),
            cursorColor: kTealColor,
            validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? AppLocalizations.of(context)!.errorEmail
                    : null,
            onChanged: onChangedEmail,
          ),
          SizedBox(height: 20.h),
          Text.rich(TextSpan(
              text: AppLocalizations.of(context)!.password,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                    text: '*',
                    style: TextStyle(color: kTealColor, fontSize: 14.sp))
              ])),
          SizedBox(height: 8.h),
          TextFormField(
            keyboardType: TextInputType.visiblePassword,
            obscureText: !showPassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: onTogglePassword,
                  child: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                hintText: AppLocalizations.of(context)!.hintPassword,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 26.w, vertical: 20.h),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: kTealColor)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28))),
            style: TextStyle(fontSize: 16.sp),
            cursorColor: kTealColor,
            validator: (password) => password != null && password.length < 8
                ? AppLocalizations.of(context)!.errorPassword
                : null,
            onChanged: onChangedPassword,
          ),
          title == AppLocalizations.of(context)!.login
              ? Container()
              : SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: Checkbox(
                        value: isCheck,
                        activeColor: kTealColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        splashRadius: 10.r,
                        onChanged: onChangedCheckBox),
                  ),
                  SizedBox(width: 8.w),
                  title == AppLocalizations.of(context)!.login
                      ? Text(AppLocalizations.of(context)!.remember,
                          style: TextStyle(
                              color: kTealColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500))
                      : Text.rich(TextSpan(
                          text: AppLocalizations.of(context)!.agreement,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w500),
                          children: [
                              TextSpan(
                                  text: AppLocalizations.of(context)!
                                      .termConditions,
                                  style: TextStyle(
                                      color: kTealColor, fontSize: 16.sp))
                            ])),
                ],
              ),
              title == AppLocalizations.of(context)!.login
                  ? TextButton(
                      child: Text(AppLocalizations.of(context)!.forgot,
                          style: TextStyle(color: kTealColor, fontSize: 16.sp)),
                      onPressed: () => showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20))),
                          isScrollControlled: true,
                          builder: (_) => const ForgotPasswordSheet()))
                  : Container(),
            ],
          ),
          title == AppLocalizations.of(context)!.login
              ? SizedBox(height: 30.h)
              : SizedBox(height: 40.h),
          Center(
            child: ElevatedButton(
              child: Text(title, style: TextStyle(fontSize: 16.sp)),
              style: ElevatedButton.styleFrom(
                  primary: kTealColor,
                  minimumSize: Size(250.w, 50.h),
                  elevation: 0,
                  shape: const StadiumBorder()),
              onPressed: isCheck ? onPressedButton : null,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(textButton1, style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 5.w),
              InkWell(
                  child: Text(textButton2,
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: kTealColor)),
                  onTap: onTapTextButton)
            ],
          )
        ],
      ),
    );
  }
}
