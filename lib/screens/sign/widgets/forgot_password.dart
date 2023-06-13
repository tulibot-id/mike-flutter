import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tulibot/config/config.dart';
import 'package:tulibot/provider/provider.dart';
import 'package:tulibot/services/appwrite_service.dart';

import 'verify_alert.dart';

class ForgotPasswordSheet extends StatelessWidget {
  const ForgotPasswordSheet({Key? key}) : super(key: key);

  void showVerifyAlert(BuildContext context) =>
      showDialog(context: context, builder: (context) => const VerifyAlert());

  @override
  Widget build(BuildContext context) {
    final key = context.read<ResetPasswordService>().key;
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w,
              20.h + MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.titleForgot,
                  style:
                      TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 30.h),
                Text(AppLocalizations.of(context)!.contentForgot,
                    style: TextStyle(fontSize: 16.sp)),
                SizedBox(height: 30.h),
                Text.rich(TextSpan(
                    text: AppLocalizations.of(context)!.email,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                          text: '*',
                          style: TextStyle(color: kTealColor, fontSize: 14.sp))
                    ])),
                SizedBox(height: 8.h),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      hintText: 'mail@website.com',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 26.w, vertical: 20.h),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: kTealColor)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28))),
                  cursorColor: kTealColor,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? AppLocalizations.of(context)!.errorEmail
                          : null,
                  onChanged: context.read<ResetPasswordService>().setEmail,
                ),
                SizedBox(height: 30.h),
                Center(
                  child: ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.send,
                        style: TextStyle(fontSize: 16.sp)),
                    style: ElevatedButton.styleFrom(
                        primary: kTealColor,
                        minimumSize: Size(250.w, 50.h),
                        elevation: 0,
                        shape: const StadiumBorder()),
                    onPressed: () {
                      final isValid = key.currentState!.validate();
                      if (isValid) {
                        final email =
                            context.read<ResetPasswordService>().email;
                        UserAuth.instance.resetPassword(email);
                        context.read<ResetPasswordService>().discard();
                        Navigator.of(context).pop();
                        showVerifyAlert(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordSheet extends StatefulWidget {
  const ResetPasswordSheet({Key? key}) : super(key: key);

  @override
  _ResetPasswordSheetState createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
  bool _isObscurePass = true;
  bool _isObscureConfirmPass = true;

  @override
  Widget build(BuildContext context) {
    final key = context.read<ResetPasswordService>().key;
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w,
              20.h + MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.titleReset,
                  style:
                      TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 30.h),
                Text(AppLocalizations.of(context)!.contentReset,
                    style: TextStyle(fontSize: 16.sp)),
                SizedBox(height: 30.h),
                Text.rich(TextSpan(
                    text: AppLocalizations.of(context)!.password,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                          text: '*',
                          style: TextStyle(color: kTealColor, fontSize: 14.sp))
                    ])),
                SizedBox(height: 8.h),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObscurePass,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscurePass = !_isObscurePass;
                          });
                        },
                        icon: Icon(
                          !_isObscurePass
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      hintText: AppLocalizations.of(context)!.hintPassword,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 26.w, vertical: 20.h),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: kTealColor)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28))),
                  cursorColor: kTealColor,
                  validator: (password) =>
                      password != null && password.length < 8
                          ? AppLocalizations.of(context)!.errorPassword
                          : null,
                  onChanged:
                      context.read<ResetPasswordService>().setNewPassword,
                ),
                SizedBox(height: 20.h),
                Text.rich(TextSpan(
                    text: AppLocalizations.of(context)!.confirmPassword,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                          text: '*',
                          style: TextStyle(color: kTealColor, fontSize: 14.sp))
                    ])),
                SizedBox(height: 8.h),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObscureConfirmPass,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscureConfirmPass = !_isObscureConfirmPass;
                          });
                        },
                        icon: Icon(
                          !_isObscureConfirmPass
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      hintText: AppLocalizations.of(context)!.hintPassword,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 26.w, vertical: 20.h),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: kTealColor)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28))),
                  cursorColor: kTealColor,
                  validator: (password) =>
                      password != null && password.length < 8
                          ? AppLocalizations.of(context)!.errorPassword
                          : null,
                  onChanged: context
                      .read<ResetPasswordService>()
                      .setConfirmNewPassword,
                ),
                SizedBox(height: 30.h),
                Center(
                  child: ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.titleReset,
                        style: TextStyle(fontSize: 16.sp)),
                    style: ElevatedButton.styleFrom(
                        primary: kTealColor,
                        minimumSize: Size(250.w, 50.h),
                        elevation: 0,
                        shape: const StadiumBorder()),
                    onPressed: () {
                      final isValid = key.currentState!.validate();
                      if (isValid) {
                        final userId =
                            context.read<ResetPasswordService>().userId;
                        final secret =
                            context.read<ResetPasswordService>().secret;
                        final newPassword =
                            context.read<ResetPasswordService>().newPassword;
                        final confirmNewPassword = context
                            .read<ResetPasswordService>()
                            .confirmNewPassword;
                        if (newPassword != confirmNewPassword) {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!
                                  .errorConfirmPassword,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.grey.shade300,
                              textColor: Colors.black);
                          return;
                        }
                        try {
                          UserAuth.instance.confirmResetPassword(
                              userId, secret, newPassword, confirmNewPassword);
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.resetSuccess,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.grey.shade300,
                              textColor: Colors.black);
                          context.read<ResetPasswordService>().discard();
                          Navigator.of(context).pop();
                        } catch (_) {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.resetFailed,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.grey.shade300,
                              textColor: Colors.black);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
