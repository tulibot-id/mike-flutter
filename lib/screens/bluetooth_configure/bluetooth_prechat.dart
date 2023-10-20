import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_check.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_discover.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_mike_configure.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_prechat.dart';
import 'package:tulibot/screens/chat_room/chat_room.dart';
import 'package:tulibot/services/bluetooth_manager.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tulibot/services/appwrite_service.dart';

class BluetoothPrechat extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  static final String routeName = "/prechat";

  BluetoothPrechat({required this.bluetoothManager});

  @override
  _BluetoothPrechatState createState() => _BluetoothPrechatState();
}

class _BluetoothPrechatState extends State<BluetoothPrechat> {
  bool get isConnected => (widget.bluetoothManager.connection!.isConnected ?? false);
  bool isInternetConnected = false;

  void _onDataReceived(Map<String, dynamic> received) {
    bool Function(dynamic, String) stringContains = (element, searchString) {
      if (element is String) {
        return element.contains(searchString);
      }
      return false;
    };

    List<dynamic> dataList = received['dataLists'];

    int connectivity_status_idx = dataList.indexWhere((element) => stringContains(element, "connectivity_status"));

    if (connectivity_status_idx != -1) {
      if (received['status'][connectivity_status_idx].contains('Scsno')) {
        setState(() {
          isInternetConnected = (received['dataContent'][connectivity_status_idx] == "full");
        });
        if (received['dataContent'][connectivity_status_idx] != "full") {
          String _connectionStatus = received['dataContent'][connectivity_status_idx];
          setState(() {
            showAlert(
                "No Internet",
                'It seems like Mike is not connected to internet, please provide Wi-Fi with internet connection.\nConnection status is $_connectionStatus',
                <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ]);
          });
        }
      }
    }
  }

  void showAlert(String title, String message, List<Widget> actions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: actions,
        );
      },
    );
  }

  void requestConnectivityStatus() {
    final Map<String, dynamic> data = <String, dynamic>{
      'command': ['connectivity_status'],
    };
    widget.bluetoothManager.sendJSON(data);
    widget.bluetoothManager.onDataReceivedExternalCallback = _onDataReceived;
  }

  @override
  void initState() {
    super.initState();
    requestConnectivityStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mike by Tulibot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: isInternetConnected
                  ? Align(
                      alignment: Alignment.center,
                      child: Text("Mike is ready!",textAlign: TextAlign.center),
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: Text("Mike is not connected to internet!\n Please configure it and connect it first!",textAlign: TextAlign.center),
                    ),
            ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Join Tulibot Chat Room'),
                  onPressed: () async{
                    if (isConnected) {
                      if (isInternetConnected) {
                        String userid = await UserAuth.instance.getUserID();
                        final Map<String, dynamic> data = <String, dynamic>{
                          'command': ['mike_driver_start'],
                          'userId': userid
                        };
                        widget.bluetoothManager.sendJSON(data);

                        Navigator.pushNamed(context, Tulibot_ChatRoom.routeName);
                      } else {
                        showAlert("No Internet", 'Please provide internet to Mike before joining room, by pressing "Configure Mike" button\n', <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ]);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mike is not connected'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }),
            ),

            SizedBox(height:20),
            Align(
              alignment: Alignment.center,
              child: Text("Configure WiFi and others here : ",textAlign: TextAlign.center),
            ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Configure Mike'),
                  onPressed: () {
                    Navigator.pushNamed(context, BluetoothConfigureMike.routeName);
                  }),
            ),

            // Repeat the above row for additional rows
          ],
        ),
      ),
    );
  }
}
