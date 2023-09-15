import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_check.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_connected.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_discover.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_final.dart';
import 'package:tulibot/services/bluetooth_manager.dart';
import 'package:request_permission/request_permission.dart';
import 'package:tulibot/services/appwrite_service.dart';

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
    RequestPermission requestPermission = RequestPermission.instace;
    requestPermission.requestMultipleAndroidPermissions({
      "android.permission.BLUETOOTH",
      "android.permission.BLUETOOTH_ADMIN",
      "android.permission.BLUETOOTH_SCAN",
      "android.permission.BLUETOOTH_ADVERTISE",
      "android.permission.BLUETOOTH_CONNECT",
      "android.permission.ACCESS_FINE_LOCATION"
    }, 101);
    _checkBluetoothState();
  }

  void _checkBluetoothState() async {
    BluetoothState state = await widget.bluetoothManager.checkBluetoothState();
    setState(() {
      _bluetoothState = state;
    });
  }

  Future<void> _enableBluetooth() async {
    await FlutterBluetoothSerial.instance.requestEnable();
    _checkBluetoothState();
  }

  void _navigateToDiscovery() {
    Navigator.pushNamed(context, BluetoothDeviceDiscoveryPage.routeName);
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
                    onPressed: _navigateToDiscovery,
                    child: Text('Try to discover Mike!'),
                  )
                ],
              ),
            SizedBox(height: 20),
            if (_bluetoothState == BluetoothState.STATE_OFF)
              ElevatedButton(
                onPressed: _enableBluetooth,
                child: Text('Enable Bluetooth'),
              ),
          ],
        ),
      ),
    );
  }
}