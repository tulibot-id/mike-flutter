import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_check.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_discover.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_prechat.dart';
import 'package:tulibot/services/bluetooth_manager.dart';

class BluetoothDeviceDiscoveryPage extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  static final String routeName = "/discover";

  BluetoothDeviceDiscoveryPage({required this.bluetoothManager});

  @override
  _BluetoothDeviceDiscoveryPageState createState() => _BluetoothDeviceDiscoveryPageState();
}

class _BluetoothDeviceDiscoveryPageState extends State<BluetoothDeviceDiscoveryPage> {
  bool _discoveryComplete = false;
  bool _connectingComplete = false;

  @override
  void initState() {
    super.initState();
    widget.bluetoothManager.startDiscovery(onDiscoveryComplete: () {
      setState(() {
        _discoveryComplete = true;
      });
    });
  }

  void _connectDevice(BuildContext context, BluetoothDevice server) async {
    BuildContext? dialogContext = null;
    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (BuildContext contexto) {
          dialogContext = contexto;
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

    try {
      bool? pairAndConnected = await widget.bluetoothManager.pairAndConnect(server);
      // BluetoothConnection connection = await BluetoothConnection.toAddress(server.address);
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
      if (pairAndConnected == true) {
        // Navigate to another page after successful connection
        Navigator.pushNamed(context, BluetoothPrechat.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot connect, exception occured'),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Rest of your existing connection handling code...
    } catch (error) {
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
      print('Cannot connect, exception occurred');
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot connect, exception occured: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
      // ... (your existing code for showing a SnackBar)
      return;
    }
  }

  Future<void> pairDevice(BuildContext context, BluetoothDevice? device) async {
    if (device == null) return;
    if (device.isBonded == true) {
      _connectDevice(context, device);
      return;
    }
    try {
      String deviceAddress = device.address;
      bool? bonded = await FlutterBluetoothSerial.instance.bondDeviceAtAddress(deviceAddress, passkeyConfirm: false);
      if (bonded == true) {
        print('Device paired successfully.');
      } else {
        print('Pairing with the device failed.');
      }
    } catch (e) {
      print('Error pairing with the device: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discovering Mike'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_discoveryComplete)
              Text(
                'Discovering Mike...',
                style: TextStyle(fontSize: 18),
              ),
            if (_discoveryComplete)
              Column(
                children: [
                  Text(
                    widget.bluetoothManager.findDeviceByName(widget.bluetoothManager.getMikeDeviceName()) != null &&
                            widget.bluetoothManager.findDeviceByName(widget.bluetoothManager.getMikeDeviceName()) != ''
                        ? 'Mike is found!'
                        : 'Mike is not found!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  if (widget.bluetoothManager.findDeviceByName(widget.bluetoothManager.getMikeDeviceName()) != null)
                    ElevatedButton(
                      onPressed: () {
                        BluetoothDevice? mike = widget.bluetoothManager.findDeviceByName(widget.bluetoothManager.getMikeDeviceName());
                        _connectDevice(context, mike!);
                      },
                      child: Text('Connect to Mike'),
                    ),
                  if (widget.bluetoothManager.findDeviceByName(widget.bluetoothManager.getMikeDeviceName()) == null)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _discoveryComplete = false;
                          widget.bluetoothManager.startDiscovery(onDiscoveryComplete: () {
                            setState(() {
                              _discoveryComplete = true;
                            });
                          });
                        });
                      },
                      child: Text('Try Discovering Again'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
