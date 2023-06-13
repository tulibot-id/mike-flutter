import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tulibot/screens/initial/initial_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'config/config.dart';
import 'provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: LocaleService()),
        ChangeNotifierProvider.value(value: UserService.instance),
        ChangeNotifierProvider.value(value: SliderService()),
        ChangeNotifierProvider.value(value: PageService()),
        ChangeNotifierProvider.value(value: LoginService()),
        ChangeNotifierProvider.value(value: SignupService()),
        ChangeNotifierProvider.value(value: ResetPasswordService()),
      ],
      child: Selector<LocaleService, Locale?>(
        selector: (_, get) => get.locale,
        builder: (_, locale, __) => ScreenUtilInit(
          minTextAdapt: true,
          designSize: const Size(392.72727272727275, 856.7272727272727),
          builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tulibot',
            theme: ThemeData(
              // scaffoldBackgroundColor: kPrimaryLightColor,
              appBarTheme: const AppBarTheme(
                  backgroundColor: kColor1,
                  elevation: 0,
                  titleTextStyle: TextStyle(color: Colors.black),
                  iconTheme: IconThemeData(color: Colors.black)),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            initialRoute: InitialScreen.routeName,
            routes: routes,
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            locale: locale,
          ),
        ),
      ),
    );
  }
}
