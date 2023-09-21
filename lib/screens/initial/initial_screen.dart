import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:tulibot/config/config.dart';
import 'package:tulibot/provider/provider.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_check.dart';
import 'package:tulibot/screens/sign/sign_screen.dart';
import 'package:tulibot/services/appwrite_service.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:tulibot/services/bluetooth_manager.dart';
import 'package:request_permission/request_permission.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);
  static String routeName = "/";

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  late Future<bool?> hasSession;
  late AppLinks _appLinks;

  // void updateApp() async {
  //   InAppUpdate.checkForUpdate().then((updateInfo) {
  //     if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
  //       try {
  //         InAppUpdate.performImmediateUpdate().then((value) {
  //           if (value == AppUpdateResult.success) {
  //           } else {
  //             print('Reload app');
  //             updateApp();
  //           }
  //         });
  //       } on Exception catch (e) {
  //         print(e);
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // updateApp();

    RequestPermission requestPermission = RequestPermission.instace;
    requestPermission.requestMultipleAndroidPermissions({
      "android.permission.BLUETOOTH",
      "android.permission.BLUETOOTH_ADMIN",
      "android.permission.BLUETOOTH_SCAN",
      "android.permission.BLUETOOTH_ADVERTISE",
      "android.permission.BLUETOOTH_CONNECT",
      "android.permission.ACCESS_FINE_LOCATION",
      "android.permission.INTERNET",
      "android.permission.RECORD_AUDIO",
      "android.permission.MODIFY_AUDIO_SETTINGS",
      "android.permission.AUDIO_CAPTURE"
    }, 101);

    hasSession = context.read<UserService>().getSession();
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) {
      if (uri.path == pathVerify && uri.queryParameters.isNotEmpty) {
        final userId = uri.queryParameters['userId'].toString();
        final secret = uri.queryParameters['secret'].toString();
        UserAuth.instance.confirmVerification(userId, secret);
        Navigator.of(context).pushNamedAndRemoveUntil(
            BluetoothCheckPage.routeName, ModalRoute.withName('/'));
      }
    }
  }

  @override
  // Widget build(BuildContext context) {
  //   FlutterNativeSplash.remove();
  //   return const HomeScreen();
  // }
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: hasSession,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(color: Colors.white);
          case ConnectionState.done:
          default:
            FlutterNativeSplash.remove();
            if (snapshot.hasError) {
              return Text('🥺 ${snapshot.error}');
            } else if (snapshot.hasData) {
              if (snapshot.data == true) {
                return BluetoothCheckPage(bluetoothManager: blue_m);
              } else {
                UserAuth.instance.logout();
                return const SignScreen();
              }
            } else {
              return const SignScreen();
            }
        }
      },
    );
  }
}
