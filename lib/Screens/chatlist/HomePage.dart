


import 'package:chat_app/Screens/chatlist/chatRoomPage.dart';
import 'package:chat_app/Screens/chatlist/searchPage.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../model/chatlist.dart';


class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot usersSnapshot = snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: usersSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      UserModel user = UserModel.fromMap(usersSnapshot.docs[index].data() as Map<String, dynamic>);

                      // Don't show the current user
                      if (user.uid == widget.userModel.uid) {
                        return Container();
                      }

                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatRoomModel = await getChatroomModel(user);

                          if (chatRoomModel != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return ChatRoomPage(
                                  chatroom: chatRoomModel,
                                  firebaseUser: widget.firebaseUser,
                                  userModel: widget.userModel,
                                  targetUser: user,
                                );
                              }),
                            );
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.profileImageUrl.toString()),
                        ),
                        title: Text(user.name.toString()),
                        subtitle: Text(user.email.toString()),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No Users"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<ChatRoomModel?>  getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance.collection("chatrooms").doc(newChatroom.chatroomid).set(newChatroom.toMap());

      chatRoom = newChatroom;
    }

    return chatRoom;
  }
}
