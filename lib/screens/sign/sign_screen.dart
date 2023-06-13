import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tulibot/config/config.dart';
import 'package:tulibot/provider/provider.dart';
import 'package:tulibot/screens/sign/widgets/login.dart';
import 'package:tulibot/screens/sign/widgets/signup.dart';
import 'package:tulibot/screens/sign/widgets/title_button.dart';
import 'package:tulibot/screens/home/home_screen.dart';
import 'package:tulibot/services/appwrite_service.dart';

import 'widgets/forgot_password.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({Key? key}) : super(key: key);
  static String routeName = "/sign";

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  final controller = PageController();
  late PageService _pageService;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) {
      if (uri.queryParameters.isNotEmpty) {
        final userId = uri.queryParameters['userId'].toString();
        final secret = uri.queryParameters['secret'].toString();

        if (uri.path == pathVerify) {
          UserAuth.instance.confirmVerification(userId, secret);
          Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.routeName, ModalRoute.withName('/'));
        } else if (uri.path == pathReset) {
          context.read<ResetPasswordService>().setToken(userId, secret);
          showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              isScrollControlled: true,
              builder: (_) => const ResetPasswordSheet());
        }
      }
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (_linkSubscription != null) {
        final userId = uri.queryParameters['userId'].toString();
        final secret = uri.queryParameters['secret'].toString();

        if (uri.path == pathVerify) {
          UserAuth.instance.confirmVerification(userId, secret);
          Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.routeName, ModalRoute.withName('/'));
        } else if (uri.path == pathReset) {
          context.read<ResetPasswordService>().setToken(userId, secret);
          showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              isScrollControlled: true,
              builder: (_) => const ResetPasswordSheet());
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pageService = context.read<PageService>();
    initDeepLinks();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _pageService.discard();
    _linkSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            reverse: true,
            child: Container(
              padding: EdgeInsets.all(20.r),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleButton(controller: controller),
                  SizedBox(height: 5.h),
                  Expanded(
                    child: PageView(
                      controller: controller,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => context
                          .read<PageService>()
                          .convertIndexToTogglePage(index),
                      children: [
                        LoginPage(controller: controller),
                        SignupPage(controller: controller)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
