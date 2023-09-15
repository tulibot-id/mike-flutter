import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_check.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_connected.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_discover.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_final.dart';
import 'package:tulibot/services/bluetooth_manager.dart';

class BluetoothTulibotApp extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  static final String routeName = "/tulibot_app";

  BluetoothTulibotApp({required this.bluetoothManager});

  @override
  _BluetoothTulibotAppState createState() => _BluetoothTulibotAppState();
}

class _BluetoothTulibotAppState extends State<BluetoothTulibotApp> {
  bool get isConnected => (widget.bluetoothManager.connection!.isConnected ?? false);

  String _address = "...";
  String _name = "...";
  String _wifiSSID = "...";
  String _wifiPassword = "...";
  String _webURL = "";
  String _roomName = "...";
  String _speechCode = "...";
  String _languageCode = "...";
  String _speakerAName = "...";
  String _speakerBName = "...";
  String _speakerCName = "...";
  String _speakerDName = "...";

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
        if (received['dataContent'][connectivity_status_idx] != "full") {
          String _connectionStatus = received['dataContent'][connectivity_status_idx];
          setState(() {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('No Internet'),
                  content: Text(
                      'It seems like Mike is not connected to internet, please provide Wi-Fi with internet connection.\nConnection status is $_connectionStatus'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, BluetoothConnectedPage.routeName);
                      },
                      child: Text('Return'),
                    ),
                  ],
                );
              },
            );
          });
        }
      }
    }
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
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, BluetoothConnectedPage.routeName);
                },
                child: const Text("Move to Connected")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Speech',
                    ),
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _speechCode = value;
                        });
                        // debugPrint('Room value: "$value"');
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Language Code',
                    ),
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _languageCode = value;
                        });
                        // debugPrint('Language value: "$value"');
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Speaker 1 Name',
                    ),
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _speakerAName = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Speaker 2 Name',
                    ),
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _speakerBName = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Speaker 3 Name',
                    ),
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _speakerCName = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Speaker 4 Name',
                    ),
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _speakerDName = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            ListTile(
              title: ElevatedButton(
                  child: const Text('Apply Configurations'),
                  onPressed: () async {
                    // {
                    //   "command":["connect"],
                    //   "ssid":"yourSSIDhere",
                    //   "password":"yourAPpassword"
                    // }
                    //create JSON
                    //if bluetooth connected isConnected
                    if (isConnected) {
                      final Map<String, dynamic> data = <String, dynamic>{
                        'command': ['mike_chatConfig_change'],
                        'userId': '64c10d5fe0215059ddd9',
                        'username': [_speakerAName, _speakerBName, _speakerCName, _speakerDName],
                        'langCode': _languageCode,
                        'speechCode': _speechCode
                      };
                      widget.bluetoothManager.sendJSON(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Applying Configurations'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                      child: const Text('Start App'),
                      onPressed: () async {
                        if (isConnected) {
                          final Map<String, dynamic> data = <String, dynamic>{
                            'command': ['mike_driver_start'],
                            'userId': '64c10d5fe0215059ddd9'
                          };
                          widget.bluetoothManager.sendJSON(data);
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Starting App, please wait'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
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
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                      child: const Text('Stop App'),
                      onPressed: () async {
                        // {
                        //   "command":["connect"],
                        //   "ssid":"yourSSIDhere",
                        //   "password":"yourAPpassword"
                        // }
                        //create JSON
                        //if bluetooth connected isConnected
                        if (isConnected) {
                          final Map<String, dynamic> data = <String, dynamic>{
                            'command': ['mike_driver_stop'],
                          };
                          widget.bluetoothManager.sendJSON(data);
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Stopping the app...'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Mike is not connected '),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                      child: const Text('Start Caption'),
                      onPressed: () async {
                        // {
                        //   "command":["connect"],
                        //   "ssid":"yourSSIDhere",
                        //   "password":"yourAPpassword"
                        // }
                        //create JSON
                        //if bluetooth connected isConnected
                        if (isConnected) {
                          final Map<String, dynamic> data = <String, dynamic>{
                            'command': ['mike_caption_start'],
                          };
                          widget.bluetoothManager.sendJSON(data);
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Starting captioning...'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Mike is not connected'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }),
                ),
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                      child: const Text('Stop Caption'),
                      onPressed: () async {
                        // {
                        //   "command":["connect"],
                        //   "ssid":"yourSSIDhere",
                        //   "password":"yourAPpassword"
                        // }
                        //create JSON
                        //if bluetooth connected isConnected
                        if (isConnected) {
                          final Map<String, dynamic> data = <String, dynamic>{
                            'command': ['mike_caption_stop'],
                          };
                          //convert JSON to string
                          widget.bluetoothManager.sendJSON(data);
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Starting captioning...'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Mike is not connected'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }),
                ),
              ],
            ),
            // Repeat the above row for additional rows
          ],
        ),
      ),
    );
  }
}
