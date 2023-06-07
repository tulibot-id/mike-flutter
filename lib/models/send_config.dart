part of models;

class ConfigSBC {
  ConfigSBC(
      {required this.wifiSSID,
      required this.wifiPassword,
      required this.roomName,
      required this.langCode});
  final String wifiSSID; // non-nullable
  final String wifiPassword; // non-nullable
  final String roomName;
  final String langCode;

  //convert to json
  Map<String, dynamic> toJson() => {
        'wifiSSID': wifiSSID,
        'wifiPassword': wifiPassword,
        'roomName': roomName,
        'langCode': langCode
      };
}
