import 'dart:ffi' as chat_room;

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'dart:math';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import './chat_bubble_clipper_r.dart';
import 'package:tulibot/services/bluetooth_manager.dart';
import 'package:tulibot/services/appwrite_service.dart';
import 'package:tulibot/screens/bluetooth_configure/bluetooth_mike_configure.dart';

List<Color> materialAppColors = [
  Colors.red, // Red
  Colors.green, // Green
  Colors.blue, // Blue
  Colors.orange, // Orange
  Colors.purple, // Purple
  Colors.teal, // Teal
  Colors.pink, // Pink
  Colors.amber, // Amber
  Colors.cyan, // Cyan
  Colors.indigo, // Indigo
  Colors.deepPurple, // Deep Purple
  Colors.deepOrange, // Deep Orange
  Colors.lime, // Lime
  Colors.lightGreen, // Light Green
  Colors.blueGrey, // Blue Grey
  Colors.brown, // Brown
  Colors.grey, // Grey
  Colors.lightBlue, // Light Blue
  Colors.yellow, // Yellow
  Colors.lightBlueAccent, // Light Blue Accent
  Colors.tealAccent, // Teal Accent
  Colors.pinkAccent, // Pink Accent
  Colors.amberAccent, // Amber Accent
];

int sumAsciiValues(String input) {
  int sum = 0;

  for (int i = 0; i < input.length; i++) {
    int asciiValue = input.codeUnitAt(i);
    sum += asciiValue;
  }

  return sum;
}

class Tulibot_ChatRoom extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  static final String routeName = "/chatroom";

  Tulibot_ChatRoom({required this.bluetoothManager});

  @override
  State<Tulibot_ChatRoom> createState() => _Tulibot_ChatRoomState();
}

class ChatUsers {
  String name;
  String messageText;
  String? imageURL;
  String? time;

  ChatUsers({required this.name, required this.messageText});
}

class Messages {
  CustomBubbleType? type;
  Widget? chatBubble;
  String message = "";
  String sender = "";
}

enum CustomBubbleType {
  /// Represents a sender's bubble displayed on the left side.
  sendBubble,

  /// Represents a receiver's bubble displayed on the right side.
  receiverBubble,
  // Represent a neutral bubble display on the middle side
  middleBubble,
}

class _Tulibot_ChatRoomState extends State<Tulibot_ChatRoom> {
  List<Messages> _messages = [];
  ScrollController _scrollController = ScrollController();
  String userName = "";
  String userEmail = "";
  String userId = "";
  String roomId = "";
  List<List<int>> indexPair = [];
  List<String> roomMember = [];
  bool captionStatus = false;

  double fontSliderValue = 0;
  bool sembunyikanKataKotorFlag = false;
  bool darkModeFlag = false;

  List<String> languageList = <String>[
    "Indonesia",
    "Arabic (Kuwait)",
    "English (United Kingdom)",
    "Spanish (Spain)",
    "French (France)",
    "German (Germany)",
    "Italian (Italy)",
    "Japanese (Japan)",
    "Korean (South Korea)",
    "Russian (Russia)",
    "Finnish",
    "Galician",
    "Greek",
    "Hungarian ",
    "Icelandic ",
    "Latin ",
    "Mandarin Chinese ",
    "Taiwanese",
    "Cantonese",
    "Malaysian ",
    "Norwegian",
    "Polish",
    "Pig Latin",
    "Portuguese",
    "Automatic"
  ];

  IO.Socket socket = IO.io('https://tulibot.com', <String, dynamic>{
    'autoConnect': false,
    'transports': ['websocket'],
  });

  final TextEditingController _messageTextController = TextEditingController();

  void _onDataReceived(Map<String, dynamic> received) {
    bool Function(dynamic, String) stringContains = (element, searchString) {
      if (element is String) {
        return element.contains(searchString);
      }
      return false;
    };

    List<dynamic> dataList = received['dataLists'];

    // int connectivity_status_idx = dataList.indexWhere((element) => stringContains(element, "connectivity_status"));
  }

  void fetchUserDatas() async {
    userId = await UserAuth.instance.getUserID();
    userName = await UserAuth.instance.getUserName();
    userEmail = await UserAuth.instance.getUserEmail();
    roomId = userId;

    print("connecting socket");
    socket.connect();
  }

  @override
  void initState() {
    super.initState();

    socket.onConnect((_) {
      print("socket connected");
      Map<String, dynamic> roomData = {
        "room": roomId, // Replace "ownerId" with the actual ownerId value
        "name": userName, // Replace "user.name" with the actual user name value
      };
      socket.emit("join-room", roomData);
    });
    socket.on("incoming-message", (data) {
      _addMessage(_messages.length, data["senderId"] == userId ? CustomBubbleType.sendBubble : CustomBubbleType.receiverBubble, data["data"]["message"],
          data["senderName"]);
      print(data);
    });
    socket.on("incomingSpeech", (data) {
      for (List<int> pair in indexPair) {
        if (pair[0] == data["idMessage"]) {
          setState(() {
            _messages[pair[1]].message = data["message"];
            _updateMessageWidget(pair[1]);
          });
          return;
        }
      }
      indexPair.add([data["idMessage"], _messages.length]);
      print(data);
      _addMessage(_messages.length, CustomBubbleType.receiverBubble, data["message"], data["senderName"]);
    });
    socket.on("new-user", (data) {
      _addMessage(_messages.length, CustomBubbleType.middleBubble, data, "");
      List<String> user = (data as String).split(" ");
      String _addedUserName = "";
      for (var token in user) {
        if (token != "has") {
          bool firstAdded = false;
          if (_addedUserName == "") {
            firstAdded = true;
          }
          _addedUserName += token;
          if (firstAdded) {
            _addedUserName += " ";
          }
        } else {
          break;
        }
      }
      roomMember.add(_addedUserName);
    });

    fetchUserDatas();
  }

  void _updateMessageWidget(int index) {
    CustomBubbleType? _type = _messages[index].type;
    _messages[index].chatBubble = Row(
      mainAxisAlignment: _type == CustomBubbleType.middleBubble
          ? MainAxisAlignment.center
          : _type == CustomBubbleType.sendBubble
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
      children: [
        if (_messages[index].type == CustomBubbleType.receiverBubble)
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Initicon(
                text: _messages[index].sender,
                backgroundColor: materialAppColors[sumAsciiValues(_messages[index].sender) % materialAppColors.length],
              )),
        if (_messages[index].type == CustomBubbleType.receiverBubble)
          SizedBox(
            width: 5,
          ),
        ChatBubble(
            clipper: ChatBubbleClipperR(),
            margin: EdgeInsets.only(top: 10),
            backGroundColor: _type == CustomBubbleType.sendBubble ? Colors.blue : Colors.black12,
            alignment: _type == CustomBubbleType.sendBubble
                ? Alignment.topRight
                : _type == CustomBubbleType.receiverBubble
                    ? Alignment.topLeft
                    : Alignment.center,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_type == CustomBubbleType.receiverBubble)
                    Text(
                      _messages[index].sender,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                  Text(_messages[index].message)
                ],
              ),
            ))
      ],
    );
  }

  void _addMessage(int index, CustomBubbleType _type, String text, String _sender) {
    setState(() {
      _messages.add(Messages());
      _messages[index].message = text;
      _messages[index].type = _type;
      _messages[index].sender = _sender;
      _updateMessageWidget(index);
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), // Adjust the duration as needed
          curve: Curves.easeInOutCubic, // Adjust the curve as needed
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: 330,
        child: ListView(
          children: [
            Container(
              height: 150,
              child: DrawerHeader(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Initicon(
                    size: 64,
                    text: userName,
                    backgroundColor: materialAppColors[sumAsciiValues(userName) % materialAppColors.length],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      child: Text(userName, style: TextStyle(fontSize: 16.0), softWrap: true),
                    ),
                    Container(
                      child: Text(userEmail, style: TextStyle(fontSize: 14.0), softWrap: true),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tulibot', style: TextStyle(fontSize: 16.0)),
                  ])),
                ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8), // Reduced horizontal padding
              child: Row(
                children: [
                  Icon(
                    Icons.format_size, // Use the icon you want from the Material Icons library
                    size: 48, // Set the size of the icon
                    color: Colors.cyan.shade700, // Set the color of the icon
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: Slider(
                    value: fontSliderValue,
                    max: 100,
                    divisions: 50,
                    activeColor: Colors.blueGrey,
                    thumbColor: Colors.cyan.shade700,
                    label: fontSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        fontSliderValue = value;
                      });
                    },
                  ))
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8), // Reduced horizontal padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sembunyikan kata kotor', style: TextStyle(fontSize: 16.0)),
                  Switch(
                    value: sembunyikanKataKotorFlag,
                    activeColor: Colors.blueGrey,
                    thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.cyan.shade700; // Color when the switch is in the "on" state
                      }
                      return Colors.grey; // Color when the switch is in the "off" state
                    }),
                    onChanged: (bool value) {
                      setState(() {
                        sembunyikanKataKotorFlag = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8), // Reduced horizontal padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mode Gelap', style: TextStyle(fontSize: 16.0)),
                  Switch(
                    value: darkModeFlag,
                    activeColor: Colors.blueGrey,
                    thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.cyan.shade700; // Color when the switch is in the "on" state
                      }
                      return Colors.grey; // Color when the switch is in the "off" state
                    }),
                    onChanged: (bool value) {
                      setState(() {
                        darkModeFlag = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8), // Reduced horizontal padding
              child: Row(
                children: [
                  Text('Translate', style: TextStyle(fontSize: 16.0)),
                  SizedBox(width: 8), // Reduced spacing
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: languageList[0],
                      onChanged: (data) {
                        setState(() {
                          // selectedValue = newValue!;
                        });
                      },
                      items: languageList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8), // Reduced horizontal padding
              child: Row(
                children: [
                  Text('Speech', style: TextStyle(fontSize: 16.0)),
                  SizedBox(width: 8), // Reduced spacing
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: languageList[0],
                      onChanged: (data) {
                        setState(() {
                          // selectedValue = newValue!;
                        });
                      },
                      items: languageList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            const Divider(
              thickness: 0.3, // Adjust the thickness of the line
              color: Colors.grey, // Set the color of the line
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Room Members : ",
                style: TextStyle(fontSize: 18),
              ),
            ),
            for (var item in roomMember)
              ListTile(
                title: Text("• " + item),
                onTap: () {
                  // Handle item tap
                },
              ),
            const Divider(
              thickness: 0.3, // Adjust the thickness of the line
              color: Colors.grey, // Set the color of the line
            ),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, BluetoothConfigureMike.routeName);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.cyan[700]), // Button color
                  ),
                  child: Text(
                    'Configure Mike',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Tulibot'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              // Attach the ScrollController
              itemCount: _messages.length,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 20),
              itemBuilder: (context, index) {
                return Container(padding: EdgeInsets.symmetric(horizontal: 15), child: _messages[index].chatBubble);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageTextController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54)),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                    height: 50,
                    width: 50,
                    child: FittedBox(
                      child: FloatingActionButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        heroTag: null,
                        onPressed: () {
                          if (_messageTextController.text.isEmpty) {
                            return;
                          }
                          String message = _messageTextController.text; // Get the text
                          // Clear the text
                          Map<String, dynamic> messageData = {
                            "senderName": userName,
                            "senderId": userId,
                            "data": {
                              "idMessage": _messages.length,
                              "message": message,
                            },
                            "finalTranscript": message,
                            "room": roomId,
                          };
                          socket.emit("created-message", messageData);
                          _messageTextController.clear();
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 24,
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    )),
                SizedBox(
                  width: 15,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 80, left: 10),
          child: FloatingActionButton(
              child: captionStatus ? Icon(Icons.mic_off) : Icon(Icons.mic),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100.0))),
              backgroundColor: Colors.cyan,
              onPressed: () {
                final Map<String, dynamic> data = <String, dynamic>{
                  'command': [captionStatus ? 'mike_caption_stop' : 'mike_caption_start'],
                };
                widget.bluetoothManager.sendJSON(data);
                widget.bluetoothManager.onDataReceivedExternalCallback = _onDataReceived;
                setState(() {
                  captionStatus = !captionStatus;
                });
              })),
    );
  }
}
