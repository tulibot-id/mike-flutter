import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

typedef DeviceAddedCallback = void Function(BluetoothDiscoveryResult result);
typedef DiscoveryCompleteCallback = void Function();
typedef onDataReceived = void Function(Map<String, dynamic> decodedData);

class BluetoothManager {
  String _deviceName = "kohi-t480";
  BluetoothConnection? connection;
  List<BluetoothDiscoveryResult> devicesList = [];
  bool discoveryComplete = false;
  String _messageBuffer = "";
  onDataReceived? onDataReceivedExternalCallback = null;
  Uint8List _buffer = Uint8List(0);

  String getMikeDeviceName(){
    return _deviceName;
  }

  void _onDataReceived(Uint8List data) async {
    // Append the received data to the buffer
    _buffer = Uint8List.fromList([..._buffer, ...data]);
    // Check if the received data forms a complete string
    int nullIndex = _buffer.indexOf(0); // Assuming null-terminated data
    if (nullIndex != -1) {
      String receivedText = utf8.decode(_buffer.sublist(0, nullIndex));
      Map<String, dynamic>? decodedData = null;
      try {
        decodedData = json.decode(receivedText);
      } catch (error) {
        print("Error decoding JSON! $error");
      }
      if (onDataReceivedExternalCallback != null && decodedData != null) {
        try {
          onDataReceivedExternalCallback!(decodedData!);
        } catch (error) {
          print("Error on callback $error");
        }
      }

      // Clear the buffer after processing the complete data
      _buffer = _buffer.sublist(nullIndex + 1);
    }
  }

  void sendJSON(Map<String, dynamic> input) async {
    final String data = json.encode(input);
    connection!.output.add(Uint8List.fromList(utf8.encode(data + "\r\n")));
    await connection!.output.allSent;
  }

  void startDiscovery({
    DeviceAddedCallback? onDeviceAdded,
    DiscoveryCompleteCallback? onDiscoveryComplete,
  }) async {
    // Empty the list before discovering
    devicesList = [];
    try {
      FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        devicesList.add(result);
        if (onDeviceAdded != null) onDeviceAdded(result);
      }, onDone: () {
        discoveryComplete = true;
        if (onDiscoveryComplete != null) onDiscoveryComplete();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  BluetoothDevice? findDeviceByName(String deviceName) {
    BluetoothDiscoveryResult result = devicesList.firstWhere((result) => result.device.name == deviceName,
        orElse: () => BluetoothDiscoveryResult(
              device: BluetoothDevice(address: '', name: ''),
              rssi: 0,
            ));

    if (result.device.address != '') {
      return result?.device;
    }
    return null;
  }

  Future<BluetoothState> checkBluetoothState() async {
    return FlutterBluetoothSerial.instance.state;
  }

  Future<bool?> connectToDevice(BluetoothDevice device) async {
    print("BluetoothManager:Calling connectToDevice");
    if (connection != null && connection!.isConnected) {
      // Already connected
      return true;
    }

    try {
      connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');

      connection!.input!.listen(_onDataReceived);

      return true;
    } catch (e) {
      print('Error connecting to the device: $e');
      return false;
    }
  }

  Future<bool?> pairAndConnect(BluetoothDevice device) async {
    if (device == null) return false;
    // We connect to device instead of pairing when device is already paired/bonded
    if (device.isBonded == true) {
      print("Device is already bonded");
      return connectToDevice(device);
    }
    try {
      String deviceAddress = device.address;
      bool? bonded = await FlutterBluetoothSerial.instance.bondDeviceAtAddress(deviceAddress, passkeyConfirm: false);
      if (bonded == true) {
        print('Device paired successfully.');
        return connectToDevice(device);
      } else {
        print('Pairing with the device failed.');
        return false;
      }
    } catch (e) {
      print('Error pairing with the device: $e');
      return false;
    }
    return false;
  }
}

final BluetoothManager blue_m = BluetoothManager();