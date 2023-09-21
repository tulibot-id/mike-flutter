import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_check.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_connected.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_discover.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_final.dart';
import 'package:tulibot/services/bluetooth_manager.dart';
import 'package:request_permission/request_permission.dart';
import 'package:tulibot/services/appwrite_service.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:tulibot/screens/widgets/webview.dart';

class BluetoothCheckPage extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  static final String routeName = "/check";

  BluetoothCheckPage({required this.bluetoothManager});

  @override
  _BluetoothCheckPageState createState() => _BluetoothCheckPageState();
}

class _BluetoothCheckPageState extends State<BluetoothCheckPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  void _checkBluetoothState() async {
    BluetoothState state = await widget.bluetoothManager.checkBluetoothState();
    setState(() {
      _bluetoothState = state;
    });
  }

  Future<void> _enableBluetooth() async {
    _checkBluetoothState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Check'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_bluetoothState == BluetoothState.STATE_OFF)
              Text(
                'Bluetooth is currently off.',
                style: TextStyle(fontSize: 20),
              ),
            if (_bluetoothState == BluetoothState.STATE_ON)
              Column(
                children: [
                  Text(
                    'Bluetooth is enabled!',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, BluetoothDeviceDiscoveryPage.routeName);
                    },
                    child: Text('Try to discover Mike!'),
                  )
                ],
              ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Open Webview'),
                  onPressed: () async {
                    //check if webURL is not empty
                    //open webview
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          Future<dynamic> userId =  UserAuth.instance.getUserID();
                          print(userId);

                          return WebViewContainer("https://tulibot.com/chat/$userId?lang=default&speech=id-ID");
                        },
                      ),
                    );
                  }),
            ),
            SizedBox(height: 20),
            if (_bluetoothState == BluetoothState.STATE_OFF)
              ElevatedButton(
                onPressed: () async {
                  String dialogTitle = "Hey! Please give me permission to use Bluetooth!";
                  bool displayDialogContent = true;
                  String dialogContent = "This app requires Bluetooth to connect to device.";
                  //or
                  // bool displayDialogContent = false;
                  // String dialogContent = "";
                  String cancelBtnText = "Nope";
                  String acceptBtnText = "Sure";
                  double dialogRadius = 10.0;
                  bool barrierDismissible = true; //

                  BluetoothEnable.customBluetoothRequest(
                          context, dialogTitle, displayDialogContent, dialogContent, cancelBtnText, acceptBtnText, dialogRadius, barrierDismissible)
                      .then((result) {
                    if (result == "true") {
                      setState(() {
                        _bluetoothState = BluetoothState.STATE_ON;
                      });
                    }
                  });
                },
                child: Text('Enable Bluetooth'),
              ),
          ],
        ),
      ),
    );
  }
}
