import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:tulibot/provider/provider.dart';
import 'package:tulibot/screens/home/home_screen.dart';
import 'package:tulibot/screens/sign/widgets/template.dart';
import 'package:tulibot/screens/widgets/alert_no_internet.dart';
// import 'package:tulibot/screens/widgets/custom_bottom_navigation_bar.dart';
import 'package:tulibot/services/appwrite_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.controller}) : super(key: key);
  final PageController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginService _loginService;
  final ValueNotifier<bool> obscureText = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _loginService = context.read<LoginService>();
  }

  @override
  void dispose() {
    super.dispose();
    _loginService.discard();
  }

  void showInternetAlert(BuildContext context) => showDialog(
      context: context, builder: (context) => const AlertNoInternet());

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginService>(
      builder: (context, value, __) => CustomTemplate(
        formKey: value.formKeyLogin,
        title: AppLocalizations.of(context)!.login,
        textSubtitle: AppLocalizations.of(context)!.sublogin,
        onPressedGoogle: () async {
          final hasConnection = await InternetConnectionChecker().hasConnection;
          if (!hasConnection) {
            showInternetAlert(context);
            return;
          }

          final isSuccess = await UserAuth.instance.loginWithGoogle();
          if (isSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.routeName, ModalRoute.withName('/'));
          }
        },
        // onPressedMicrosoft: () async {
        //   final hasConnection = await InternetConnectionChecker().hasConnection;
        //   if (!hasConnection) {
        //     showInternetAlert(context);
        //     return;
        //   }

        //   final isSuccess = await UserAuth.instance.loginWithMicrosoft();
        //   if (isSuccess) {
        //     Navigator.of(context).pushNamedAndRemoveUntil(
        //         HomeScreen.routeName, ModalRoute.withName('/'));
        //   }
        // },
        onChangedEmail: (email) => value.setEmail(email),
        onChangedPassword: (password) => value.setPassword(password),
        isCheck: value.check,
        onChangedCheckBox: (check) => value.setCheck(check!),
        showPassword: value.showPassword,
        onTogglePassword: () => value.toggleShowPassword(),
        onPressedButton: () async {
          final isValid = value.formKeyLogin.currentState!.validate();
          if (!isValid) return;

          final hasConnection = await InternetConnectionChecker().hasConnection;
          if (!hasConnection) {
            showInternetAlert(context);
            return;
          }

          final isCorrect =
              await UserAuth.instance.login(value.email, value.password);
          final isVerifid = await context.read<UserService>().getSession();
          if (isCorrect && isVerifid!) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.routeName, ModalRoute.withName('/'));
          } else if (isCorrect && !isVerifid!) {
            await UserAuth.instance.logout();
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.loginFailed2,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.grey.shade300,
                textColor: Colors.black);
          } else {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.loginFailed1,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.grey.shade300,
                textColor: Colors.black);
          }
        },
        textButton1: AppLocalizations.of(context)!.footerLogin1,
        textButton2: AppLocalizations.of(context)!.footerLogin2,
        onTapTextButton: () => widget.controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut),
      ),
    );
  }
}
