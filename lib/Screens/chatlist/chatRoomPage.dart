import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/model/chatlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      // Send Notification
      await sendNotification(widget.targetUser.fcmToken, msg);

      log("Message Sent!");
    }
  }

  Future<void> sendNotification(String? fcmToken, String message) async {
    const String serverKey =
        'ya29.a0AXooCgsfdjcWcT2TwIFQR5DGRZXQ0N6yUrK4vRsiL6Z2c-0MleZIxuOXmDy3LwFW5x9KvSvJ6FjrL_hzrbgMtnWm20y9VYdmj7DDKXRbZJINWjSJyQkiPkaBH4BDB5wxFHXWdAK6j4_ugWGhFHzXjq9c41CiWahme3ZaaCgYKAcESARASFQHGX2MirKZDz0cpt6veD9CrvwucFQ0171'; // Replace with your actual server key
    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/chatapp-a5146/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer $serverKey",
      },
      body: jsonEncode(<String, dynamic>{
        "message": {
          "token": widget.targetUser.fcmToken,
          "notification": {
            "title": widget.userModel.name,
            "body": message,
          }
        }
      }),
    );

    try {
      if (response.statusCode == 200) {
        log('Notification Sent!');
      }
    } catch (e, stackTrace) {
      log("message not sent , $e,$stackTrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profileImageUrl.toString()),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.name.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // This is where the chats will go
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            return Row(
                              mainAxisAlignment: (currentMessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (currentMessage.sender ==
                                            widget.userModel.uid)
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    currentMessage.text.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              "An error occured! Please check your internet connection."),
                        );
                      } else {
                        return const Center(
                          child: Text("Say hi to your new friend"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: messageController,
                      maxLines: null,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Enter message"),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
