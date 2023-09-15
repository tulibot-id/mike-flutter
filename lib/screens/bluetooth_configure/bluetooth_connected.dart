import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:tulibot/screens/bluetooth_configure/bluetooth_check.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_connected.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_discover.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_final.dart';
import 'package:tulibot/services/bluetooth_manager.dart';
import 'package:tulibot/screens/widgets/wifi_list_tile_state.dart';

class BluetoothConnectedPage extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  static final String routeName = "/connected";

  BluetoothConnectedPage({required this.bluetoothManager});

  @override
  _BluetoothConnectedPageState createState() => _BluetoothConnectedPageState();
}

class _BluetoothConnectedPageState extends State<BluetoothConnectedPage> {
  bool isAlreadyConnected = false;
  String _wifiSSID = "";
  String _wifiPassword = "";
  String _previousRouteName = "";
  List<dynamic> _wifiLists = [];

  bool get isConnected => (widget.bluetoothManager.connection?.isConnected ?? false);


  @override
  void initState() {
    super.initState();

    // final previousRouteName = PreviousRoute.instance.routeName;
    // _previousRouteName = previousRouteName!;
    print("Previous route $_previousRouteName");
    // We try to scan WiFi
    requestScanWifi();
  }

  void requestScanWifi() {
    final Map<String, dynamic> data = <String, dynamic>{
      'command': ['wifi_ap'],
    };
    isAlreadyConnected = false;
    widget.bluetoothManager.sendJSON(data);
    widget.bluetoothManager.onDataReceivedExternalCallback = _onDataReceived;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Configuring WiFi'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                requestScanWifi();
              },
              child: Text('Scan WiFi'),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // Disable inner list scrolling
              itemCount: _wifiLists.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> wifi = _wifiLists[index];
                String ssid = wifi['ssid'];
                int signalStrength = wifi['signal'];
                bool in_use = wifi['in_use'];
                String security = wifi['security'];

                return WifiListTile(
                  parentContext: context,
                  ssid: ssid,
                  signalStrength: signalStrength,
                  inUse: in_use,
                  security: security,
                  bluetoothManager: widget.bluetoothManager,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Map<String, dynamic> received) {
    bool Function(dynamic, String) stringContains = (element, searchString) {
      if (element is String) {
        return element.contains(searchString);
      }
      return false;
    };

    List<dynamic> dataList = received['dataLists'];
    List<dynamic> status = received['status'];

    int wifi_ap_index = dataList.indexWhere((element) => stringContains(element, "wifi_ap"));
    int scsno4 = status.indexWhere((element) => stringContains(element, "Scsno 5"));
    int errno4 = status.indexWhere((element) => stringContains(element, "Errno 4"));
    int errno5 = status.indexWhere((element) => stringContains(element, "Errno 5"));
    int errno6 = status.indexWhere((element) => stringContains(element, "Errno 6"));
    int scsno6 = status.indexWhere((element) => stringContains(element, "Scsno 6"));
    int errno7 = status.indexWhere((element) => stringContains(element, "Errno 7"));

    if (scsno4 != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Succesfully connected'),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pushNamed(context, BluetoothTulibotApp.routeName);
    }

    if (errno4 != -1 || errno5 != -1 || errno6 != -1) {
      String errorMessage = "";
      String extractedErrorMessage = "";
      if (errno4 != -1) {
        errorMessage = status[errno4];
        List<String> parts = errorMessage.split(":");
        extractedErrorMessage = parts.length > 1 ? parts[1].trim() : errorMessage;
      }
      if (errno5 != -1) {
        errorMessage = status[errno5];
        List<String> parts = errorMessage.split(":");
        extractedErrorMessage = parts.length > 1 ? parts[1].trim() : errorMessage;
      }
      if (errno6 != -1) {
        errorMessage = status[errno6];
        List<String> parts = errorMessage.split(":");
        extractedErrorMessage = parts.length > 1 ? parts[1].trim() : errorMessage;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error' + extractedErrorMessage),
          duration: const Duration(seconds: 3),
        ),
      );
      requestScanWifi();
    }

    if (scsno6 != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Succesfully disconnected'),
          duration: const Duration(seconds: 3),
        ),
      );
      requestScanWifi();
    }

    if (errno7 != -1) {
      String errorMessage = status[errno6];
      List<String> parts = errorMessage.split(":");
      String extractedErrorMessage = parts.length > 1 ? parts[1].trim() : errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error' + extractedErrorMessage),
          duration: const Duration(seconds: 3),
        ),
      );
      requestScanWifi();
    }

    if (wifi_ap_index != -1) {
      if (received['status'][wifi_ap_index].contains('Scsno')) {
        setState(() {
          BuildContext parentContext = context;
          isAlreadyConnected = false; // reset state of connected flag
          _wifiLists = received['dataContent'][wifi_ap_index];
          for (int i = 0; i < _wifiLists.length; i++) {
            if (_wifiLists[i]['in_use'] == true) {
              isAlreadyConnected = true; // seems like we already connected to a wifi already....
              String _connectedSSID = _wifiLists[i]["ssid"];
              print("PREEEEE $_previousRouteName");
              // if (_previousRouteName != BluetoothTulibotApp.routeName) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Mike Already Connected'),
                      content: Text(
                          'Mike is already connected to $_connectedSSID Wi-Fi network. \nPress "Cancel" to close this dialog and connect to another Wi-Fi access point, or "Continue" to next page.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.pushNamed(parentContext, BluetoothTulibotApp.routeName);
                          },
                          child: Text('Continue'),
                        ),
                      ],
                    );
                  },
                );
              // }
              // Always display connected wifi on the top
              if (i != 0) {
                var temp = _wifiLists[i];
                _wifiLists[i] = _wifiLists[0];
                _wifiLists[0] = temp;
              }
            }
          }
        });
      }
    }
  }
}
