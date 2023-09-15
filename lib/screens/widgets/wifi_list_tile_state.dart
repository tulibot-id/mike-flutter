import 'package:flutter/material.dart';
import 'package:tulibot/services/bluetooth_manager.dart';

class WifiListTile extends StatefulWidget {
  final String ssid;
  final int signalStrength;
  final bool inUse;
  final String security;
  final BluetoothManager bluetoothManager;
  final BuildContext parentContext;

  const WifiListTile({required this.parentContext, required this.ssid, required this.signalStrength, required this.inUse, required this.security, required this.bluetoothManager});

  @override
  _WifiListTileState createState() => _WifiListTileState();
}

class _WifiListTileState extends State<WifiListTile> {
  bool _showPasswordEntry = false;
  String? _password; // Initialize with null

  TextEditingController _passwordController = TextEditingController();

  void _togglePasswordEntry() {
    setState(() {
      _showPasswordEntry = !_showPasswordEntry;
      if (!_showPasswordEntry) {
        // Reset password and controller when hiding password entry
        _password = null;
        _passwordController.clear();
      }
    });
  }

  void _onPasswordChanged(String newPassword) {
    setState(() {
      _password = newPassword; // Store entered password
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.wifi),
      title: Text(widget.ssid),
      trailing: Text('${widget.signalStrength} dBm'),
      // Show signal strength
      subtitle: _showPasswordEntry
          ? Column(
        children: [
          if(widget.security.contains("WPA"))
            TextFormField(
              controller: _passwordController,
              onChanged: _onPasswordChanged,
              decoration: InputDecoration(labelText: 'Enter password'),
            ),
          ElevatedButton(
            onPressed: () {
              // Add your connect logic here
              if (widget.inUse) {
                final Map<String, dynamic> data = <String, dynamic>{
                  'command': ['disconnect']
                };
                print(data);
                widget.bluetoothManager.sendJSON(data);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Disconnecting...'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                if(widget.security.contains("WPA")) {
                  if (_password != null) {
                    final Map<String, dynamic> data = <String, dynamic>{
                      'command': ['connect'],
                      'ssid': widget.ssid,
                      'password': _password,
                    };
                    print(data);
                    widget.bluetoothManager.sendJSON(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Connecting...'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill the password'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }else{
                  final Map<String, dynamic> data = <String, dynamic>{
                    'command': ['connect'],
                    'ssid': widget.ssid,
                    'password': "",
                  };
                  print(data);
                  widget.bluetoothManager.sendJSON(data);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connecting...'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: Text(widget.inUse ? 'Disconnect' : 'Connect'),
          ),
        ],
      )
          : Text(widget.inUse ? 'Already Connected' : widget.security.contains("WPA") ? 'Tap to enter password' : 'Tap here to connect'),
      onTap: _togglePasswordEntry,
    );
  }
}
