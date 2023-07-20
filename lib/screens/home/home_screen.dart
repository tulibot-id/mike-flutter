import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tulibot/models/models.dart';
import 'package:tulibot/screens/widgets/webview.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './ChatPage.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './send_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = '/home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreen();
// Widget build(BuildContext context) {
//   return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         actions: const [TitleFolder(), Spacer(), SearchBarButton()],
//       ),
//       body: const ListRecord());
// }
}

class _HomeScreen extends State<HomeScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  //Send config stuff
  BluetoothConnection? connection;
  bool isConnecting = true;

  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  //End

  String _messageBuffer = '';

  String _address = "...";
  String _name = "...";
  String _wifiSSID = "...";
  String _wifiPassword = "...";
  String _webURL = "";
  String _roomName = "...";
  String _languageCode = "...";
  String _speakerAName = "...";
  String _speakerBName = "...";
  String _speakerCName = "...";
  String _speakerDName = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        //Title color of the appbar is black
        title: const Text('Home'),
        // titleTextStyle: ,
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            // ListTile(title: const Text('General')),
            SwitchListTile(
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Bluetooth status'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: const Text('Settings'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Local adapter address'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Local adapter name'),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            // ListTile(
            //   title: _discoverableTimeoutSecondsLeft == 0
            //       ? const Text("Discoverable")
            //       : Text(
            //           "Discoverable for ${_discoverableTimeoutSecondsLeft}s"),
            //   // subtitle: const Text("PsychoX-Luna"),
            //   trailing: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Checkbox(
            //         value: _discoverableTimeoutSecondsLeft != 0,
            //         onChanged: null,
            //       ),
            //       // IconButton(
            //       //   icon: const Icon(Icons.edit),
            //       //   onPressed: null,
            //       // ),
            //       IconButton(
            //         icon: const Icon(Icons.refresh),
            //         onPressed: () async {
            //           print('Discoverable requested');
            //           final int timeout = (await FlutterBluetoothSerial.instance
            //               .requestDiscoverable(60))!;
            //           if (timeout < 0) {
            //             print('Discoverable mode denied');
            //           } else {
            //             print(
            //                 'Discoverable mode acquired for $timeout seconds');
            //           }
            //           setState(() {
            //             _discoverableTimeoutTimer?.cancel();
            //             _discoverableTimeoutSecondsLeft = timeout;
            //             _discoverableTimeoutTimer =
            //                 Timer.periodic(Duration(seconds: 1), (Timer timer) {
            //               setState(() {
            //                 if (_discoverableTimeoutSecondsLeft < 0) {
            //                   FlutterBluetoothSerial.instance.isDiscoverable
            //                       .then((isDiscoverable) {
            //                     if (isDiscoverable ?? false) {
            //                       print(
            //                           "Discoverable after timeout... might be infinity timeout :F");
            //                       _discoverableTimeoutSecondsLeft += 1;
            //                     }
            //                   });
            //                   timer.cancel();
            //                   _discoverableTimeoutSecondsLeft = 0;
            //                 } else {
            //                   _discoverableTimeoutSecondsLeft -= 1;
            //                 }
            //               });
            //             });
            //           });
            //         },
            //       )
            //     ],
            //   ),
            // ),
            Divider(),
            // ListTile(title: const Text('Devices discovery and connection')),
            // SwitchListTile(
            //   title: const Text('Auto-try specific pin when pairing'),
            //   subtitle: const Text('Pin 1234'),
            //   value: _autoAcceptPairingRequests,
            //   onChanged: (bool value) {
            //     setState(() {
            //       _autoAcceptPairingRequests = value;
            //     });
            //     if (value) {
            //       FlutterBluetoothSerial.instance.setPairingRequestHandler(
            //           (BluetoothPairingRequest request) {
            //         print("Trying to auto-pair with Pin 1234");
            //         if (request.pairingVariant == PairingVariant.Pin) {
            //           return Future.value("1234");
            //         }
            //         return Future.value(null);
            //       });
            //     } else {
            //       FlutterBluetoothSerial.instance
            //           .setPairingRequestHandler(null);
            //     }
            //   },
            // ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Explore discovered devices'),
                  onPressed: () async {
                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return DiscoveryPage();
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      print('Discovery -> selected ' + selectedDevice.address);
                    } else {
                      print('Discovery -> no device selected');
                    }
                  }),
            ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Connect to Mike'),
                  onPressed: () async {
                    print("Wifi SSID: $_wifiSSID");
                    print("Wifi Password: $_wifiPassword");
                    print("Room Name: $_roomName");
                    print("Language Code: $_languageCode");
                    final config = ConfigSBC(
                        wifiSSID: _wifiSSID,
                        wifiPassword: _wifiPassword,
                        roomName: _roomName,
                        langCode: _languageCode);

                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      print('Connect -> selected ' + selectedDevice.address);
                      // _startChat(context, selectedDevice);
                      _sendConfig1(context, selectedDevice, config);
                    } else {
                      print('Connect -> no device selected');
                    }
                    // final BluetoothDevice? selectedDevice =
                    //     await Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //       return DiscoveryPage();
                    //     },
                    //   ),
                    // );

                    // if (selectedDevice != null) {
                    //   print('Discovery -> selected ' + selectedDevice.address);
                    // } else {
                    //   print('Discovery -> no device selected');
                    // }
                  }),
            ),
            // ListTile(
            //   title: ElevatedButton(
            //     child: const Text('Connect to paired device to chat'),
            //     onPressed: () async {
            //       final BluetoothDevice? selectedDevice =
            //           await Navigator.of(context).push(
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return SelectBondedDevicePage(checkAvailability: false);
            //           },
            //         ),
            //       );

            //       if (selectedDevice != null) {
            //         print('Connect -> selected ' + selectedDevice.address);
            //         _startChat(context, selectedDevice);
            //       } else {
            //         print('Connect -> no device selected');
            //       }proceed
            //     },
            //   ),
            // ),
            Divider(),
            ListTile(
              title: const Text('Mike Control & Configs'),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter WiFi SSID',
                ),
                onChanged: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      _wifiSSID = value;
                    });
                    // debugPrint('SSID value: "$value"');
                  }
                },
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter WiFi Password',
                ),
                onChanged: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      _wifiPassword = value;
                    });
                    // debugPrint('Password value: "$value"');
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                      child: const Text('Connect'),
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
                            'command': ['connect'],
                            'ssid': _wifiSSID,
                            'password': _wifiPassword,
                          };
                          //convert JSON to string
                          final String text = json.encode(data);
                          connection!.output.add(
                              Uint8List.fromList(utf8.encode(text + "\r\n")));
                          await connection!.output.allSent;
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Command sent: $text'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          //show toast
                          Fluttertoast.showToast(
                            msg: "Bluetooth not connected",
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      }),
                ),
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                      child: const Text('Disconnect'),
                      onPressed: () async {
                        // {
                        //   "command":["disconnect"]
                        // }
                        //create JSON
                        if (isConnected) {
                          final Map<String, dynamic> data = <String, dynamic>{
                            'command': ['disconnect'],
                          };
                          //convert JSON to string
                          final String text = json.encode(data);
                          connection!.output.add(
                              Uint8List.fromList(utf8.encode(text + "\r\n")));
                          await connection!.output.allSent;
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Command sent: $text'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          //show toast
                          Fluttertoast.showToast(
                            msg: "Bluetooth not connected",
                            toastLength: Toast.LENGTH_SHORT,
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
                      child: const Text('Auto-connect'),
                      onPressed: () async {
                        // {
                        //   "command":["auto_connect"]
                        // }
                        //create JSON
                        if (isConnected) {
                          final Map<String, dynamic> data = <String, dynamic>{
                            'command': ['auto_connect'],
                          };
                          //convert JSON to string
                          final String text = json.encode(data);
                          connection!.output.add(
                              Uint8List.fromList(utf8.encode(text + "\r\n")));
                          await connection!.output.allSent;
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Command sent: $text'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          //show toast
                          Fluttertoast.showToast(
                            msg: "Bluetooth not connected",
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      }),
                ),
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                      child: const Text('Delete Config'),
                      onPressed: () async {
                        // {
                        //   "command":["delete_connection"],
                        //   "ssid":"yourSSIDhere"
                        // }
                        //create JSON
                        if (isConnected) {
                          final Map<String, dynamic> data = <String, dynamic>{
                            'command': ['delete_connection'],
                            'ssid': _wifiSSID,
                          };
                          //convert JSON to string
                          final String text = json.encode(data);
                          connection!.output.add(
                              Uint8List.fromList(utf8.encode(text + "\r\n")));
                          await connection!.output.allSent;
                          //show toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Command sent: $text'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          //show toast
                          Fluttertoast.showToast(
                            msg: "Bluetooth not connected",
                            toastLength: Toast.LENGTH_SHORT,
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
                  width: 150,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Room Name',
                    ),
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _roomName = value;
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
                        'room': _roomName,
                        'username': [
                          _speakerAName,
                          _speakerBName,
                          _speakerCName,
                          _speakerDName
                        ],
                        'langCode': _languageCode,
                      };
                      //convert JSON to string
                      final String text = json.encode(data);
                      connection!.output
                          .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
                      await connection!.output.allSent;
                      //show toast
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Command sent: $text'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      //show toast
                      Fluttertoast.showToast(
                        msg: "Bluetooth not connected",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  }),
            ),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(width:130,child:ElevatedButton(
                    child: const Text('Start App'),
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
                          'command': ['mike_driver_start'],
                        };
                        //convert JSON to string
                        final String text = json.encode(data);
                        connection!.output
                            .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
                        await connection!.output.allSent;
                        //show toast
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Command sent: $text'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        //show toast
                        Fluttertoast.showToast(
                          msg: "Bluetooth not connected",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    }),),
                SizedBox(width:130,child:ElevatedButton(
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
                        //convert JSON to string
                        final String text = json.encode(data);
                        connection!.output
                            .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
                        await connection!.output.allSent;
                        //show toast
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Command sent: $text'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        //show toast
                        Fluttertoast.showToast(
                          msg: "Bluetooth not connected",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    }),),
              ],
            ),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(width:130,child:ElevatedButton(
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
                        //convert JSON to string
                        final String text = json.encode(data);
                        connection!.output
                            .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
                        await connection!.output.allSent;
                        //show toast
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Command sent: $text'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        //show toast
                        Fluttertoast.showToast(
                          msg: "Bluetooth not connected",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    }),),
                SizedBox(width:130,child:ElevatedButton(
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
                        final String text = json.encode(data);
                        connection!.output
                            .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
                        await connection!.output.allSent;
                        //show toast
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Command sent: $text'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        //show toast
                        Fluttertoast.showToast(
                          msg: "Bluetooth not connected",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    }),),
              ],
            ),

            ListTile(
              title: ElevatedButton(
                  child: const Text('Rejoin Room'),
                  onPressed: () async {

                    if (isConnected) {
                      final Map<String, dynamic> data = <String, dynamic>{
                        'command': ['mike_rejoin_room'],
                      };
                      //convert JSON to string
                      final String text = json.encode(data);
                      connection!.output
                          .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
                      await connection!.output.allSent;
                      //show toast
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Command sent: $text'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      //show toast
                      Fluttertoast.showToast(
                        msg: "Bluetooth not connected",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  }),
            ),
            Divider(),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter URL',
                ),
                onChanged: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      _webURL = value;
                    });
                  }
                },
              ),
            ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Open Webview'),
                  onPressed: () async {
                    //check if webURL is not empty
                    if (_webURL.isNotEmpty) {
                      //open webview
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return WebViewContainer(_webURL);
                          },
                        ),
                      );
                    } else {
                      //show toast
                      Fluttertoast.showToast(
                        msg: "Please enter a URL",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                    // await Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //       return WebViewContainer(
                    //           "https://8d8b70a3-8fe2-4f19-918c-96f299597843.mock.pstmn.io/login");
                    //     },
                    //   ),
                    // );
                  }),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  void _sendConfig(
      BuildContext context, BluetoothDevice server, ConfigSBC config) {
    print(config.toJson());
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // print("message: " + String.fromCharCodes(buffer));

    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    String msg1 = '';
    if (~index != 0) {
      msg1 = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    // print("message: " + msg1);
    //show toast
    if (msg1.isNotEmpty) {
      Fluttertoast.showToast(
        msg: msg1,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void _sendConfig1(
      BuildContext context, BluetoothDevice server, ConfigSBC config,
      [bool mounted = true]) async {
    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });

    //Connect to bluetooth
    await BluetoothConnection.toAddress(server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
      //show toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot connect, exception occured: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    });

    // String text = config.toJson().toString().trim();
    // if (text.length > 0) {
    //   // show the loading dialog

    //   // Your asynchronous computation here (fetching data from an API, processing files, inserting something to the database, etc)
    //   // await Future.delayed(const Duration(seconds: 3));
    //   try {
    //     connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
    //     await connection!.output.allSent;
    //     await connection!.output.close();
    //     await connection!.finish();
    //   } catch (e) {
    //     print("Error when sending: $e");
    //     // Ignore error, but notify state
    //     setState(() {});
    //     //show toast
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error: $e'),
    //         duration: const Duration(seconds: 3),
    //       ),
    //     );
    //   }
    // }

    // Close the dialog programmatically
    // We use "mounted" variable to get rid of the "Do not use BuildContexts across async gaps" warning
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
