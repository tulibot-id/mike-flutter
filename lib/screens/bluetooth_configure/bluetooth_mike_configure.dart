import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_check.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_discover.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_prechat.dart';
import 'package:tulibot/services/bluetooth_manager.dart';
import 'package:tulibot/services/appwrite_service.dart';
import 'package:tulibot/screens/widgets/wifi_list_tile_state.dart';

class BluetoothConfigureMike extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  static final String routeName = "/mike_configure";

  BluetoothConfigureMike({required this.bluetoothManager});

  @override
  _BluetoothConfigureMikeState createState() => _BluetoothConfigureMikeState();
}

class _BluetoothConfigureMikeState extends State<BluetoothConfigureMike> {
  bool get isConnected => (widget.bluetoothManager.connection!.isConnected ?? false);

  TextEditingController _langCodeController = TextEditingController();
  TextEditingController _speechCodeController = TextEditingController();
  List<TextEditingController> _speakerNameController = [TextEditingController(),TextEditingController(),TextEditingController(),TextEditingController()];
  String _speechCode = "...";
  String _languageCode = "...";
  String _speakerAName = "...";
  String _speakerBName = "...";
  String _speakerCName = "...";
  String _speakerDName = "...";

  bool isAlreadyConnected = false;
  String _previousRouteName = "";
  String _connectedSSID = "";
  List<dynamic> _wifiLists = [];

  void requestScanWifi() {
    final Map<String, dynamic> data = <String, dynamic>{
      'command': ['wifi_ap'],
    };
    isAlreadyConnected = false;
    widget.bluetoothManager.sendJSON(data);
    widget.bluetoothManager.onDataReceivedExternalCallback = _onDataReceived;
  }


  void requestConfiguration(){
    final Map<String, dynamic> data = <String, dynamic>{
      'command': ['mike_chatConfig_get'],
    };
    widget.bluetoothManager.sendJSON(data);
    widget.bluetoothManager.onDataReceivedExternalCallback = _onDataReceived;
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
    int connectivity_status_index = dataList.indexWhere((element) => stringContains(element, "connectivity_status"));
    int chatconfigget_index = dataList.indexWhere((element) => stringContains(element, "mike_chatConfig_get"));
    int scsno4 = status.indexWhere((element) => stringContains(element, "Scsno 5"));
    int errno4 = status.indexWhere((element) => stringContains(element, "Errno 4"));
    int errno5 = status.indexWhere((element) => stringContains(element, "Errno 5"));
    int errno6 = status.indexWhere((element) => stringContains(element, "Errno 6"));
    int scsno6 = status.indexWhere((element) => stringContains(element, "Scsno 6"));
    int errno7 = status.indexWhere((element) => stringContains(element, "Errno 7"));

    if(chatconfigget_index != -1){
      setState(() {
        _speakerAName = received["dataContent"][0]["username"][0];
        _speakerBName = received["dataContent"][0]["username"][1];
        _speakerCName = received["dataContent"][0]["username"][2];
        _languageCode = received["dataContent"][0]["langCode"];
        _speechCode = received["dataContent"][0]["speech"];
        _langCodeController.text = _languageCode;
        _speechCodeController.text = _speechCode;
        _speakerNameController[0].text = _speakerAName;
        _speakerNameController[1].text = _speakerBName;
        _speakerNameController[2].text = _speakerCName;
      });
    }

    if (scsno4 != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Succesfully connected'),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pushNamed(context, BluetoothPrechat.routeName);
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

    if (connectivity_status_index != -1) {
      if (received["dataContent"][0] == "full") {}
    }

    if (wifi_ap_index != -1) {
      if (received['status'][wifi_ap_index].contains('Scsno')) {
        setState(() {
          BuildContext parentContext = context;
          isAlreadyConnected = false; // reset state of connected flag
          _wifiLists = received['dataContent'][wifi_ap_index];
          for (int i = 0; i < _wifiLists.length; i++) {
            if (_wifiLists[i]['in_use'] == true) {
              isAlreadyConnected = true;
              _connectedSSID = _wifiLists[i]["ssid"];
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

  @override
  void initState(){
    super.initState();
    requestConfiguration();
    requestScanWifi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure Mike'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Text("Room Configuration"),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller: _speechCodeController,
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
                          controller: _langCodeController,
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
                          controller: _speakerNameController[0],
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
                          controller: _speakerNameController[1],
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
                          controller: _speakerNameController[2],
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
                          controller: _speakerNameController[3],
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
                              'userId': await UserAuth.instance.getUserID(),
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
                ],
              ),
            ),
            SizedBox(height: 20),
            const Divider(
              thickness: 0.3, // Adjust the thickness of the line
              color: Colors.grey, // Set the color of the line
            ),
            Align(
              alignment: Alignment.center,
              child: Text("Internet Configuration"),
            ),
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
}
