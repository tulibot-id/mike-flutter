part of config;

final Map<String, WidgetBuilder> routes = {
  InitialScreen.routeName: (context) => const InitialScreen(),
  // HomeScreen.routeName: (context) => const HomeScreen(),
  BluetoothCheckPage.routeName: (context) => BluetoothCheckPage(bluetoothManager: blue_m),
  BluetoothDeviceDiscoveryPage.routeName: (context) => BluetoothDeviceDiscoveryPage(bluetoothManager: blue_m),
  BluetoothConnectedPage.routeName: (context) => BluetoothConnectedPage(bluetoothManager: blue_m),
  BluetoothTulibotApp.routeName: (context) => BluetoothTulibotApp(bluetoothManager: blue_m)
  // OnboardingScreen.routeName: (context) => const OnboardingScreen(),
  // SignScreen.routeName: (context) => const SignScreen(),
  // AccountSecurityScreen.routeName: (context) => const AccountSecurityScreen(),
  // FontSizeScreen.routeName: (context) => const FontSizeScreen(),
  // HelpCenterScreen.routeName: (context) => const HelpCenterScreen(),
  // MiniBindingScreen.routeName: (context) => const MiniBindingScreen(),
  // PrivacyPolicyScreen.routeName: (context) => const PrivacyPolicyScreen(),
  // ReferAndEarnScreen.routeName: (context) => const ReferAndEarnScreen(),
  // SendFeedbackScreen.routeName: (context) => const SendFeedbackScreen(),
  // TermsOfServiceScreen.routeName: (context) => const TermsOfServiceScreen(),
  // TutorialsScreen.routeName: (context) => const TutorialsScreen(),
  // AccountInfoScreen.routeName: (context) => const AccountInfoScreen(),
  // FloatingBottomNavBar.routeName: (context) => const FloatingBottomNavBar(),
  // RecordScreen.routeName: (context) => const RecordScreen()
};
