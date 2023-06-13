import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:tulibot/provider/provider.dart';
import 'package:tulibot/screens/sign/widgets/template.dart';
import 'package:tulibot/screens/sign/widgets/verify_alert.dart';
import 'package:tulibot/screens/widgets/alert_no_internet.dart';
import 'package:tulibot/services/appwrite_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key, required this.controller}) : super(key: key);
  final PageController controller;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late SignupService _signupService;
  late PageService _pageService;
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<bool> obscureText = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _signupService = context.read<SignupService>();
    _pageService = context.read<PageService>();
  }

  @override
  void dispose() {
    super.dispose();
    _signupService.discard();
    _pageService.discard();
  }

  void showInternetAlert(BuildContext context) => showDialog(
      context: context, builder: (context) => const AlertNoInternet());

  void showVerifyAlert(BuildContext context) =>
      showDialog(context: context, builder: (context) => const VerifyAlert());

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupService>(
      builder: (context, value, child) => CustomTemplate(
        formKey: value.formKeySignup,
        title: AppLocalizations.of(context)!.signup,
        textSubtitle: AppLocalizations.of(context)!.subsignup,
        onChangedName: (name) => value.setName(name),
        onChangedEmail: (email) => value.setEmail(email),
        onChangedPassword: (password) => value.setPassword(password),
        showPassword: value.showPassword,
        onTogglePassword: () => value.toggleShowPassword(),
        isCheck: value.check,
        onChangedCheckBox: (check) => value.setCheck(check!),
        onPressedButton: () async {
          final isValid = value.formKeySignup.currentState!.validate();
          if (!isValid) return;

          final hasConnection = await InternetConnectionChecker().hasConnection;
          if (!hasConnection) {
            showInternetAlert(context);
            return;
          }

          await UserAuth.instance
              .signup(value.name, value.email, value.password);
          await UserAuth.instance.login(value.email, value.password);
          await UserAuth.instance.verification();
          showVerifyAlert(context);
          widget.controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        },
        textButton1: AppLocalizations.of(context)!.footerSignup,
        textButton2: AppLocalizations.of(context)!.login,
        onTapTextButton: () => widget.controller.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut),
      ),
    );
  }
}
