// import 'dart:developer';


// import 'package:chat_app/Screens/chatlist/chatRoomPage.dart';
// import 'package:chat_app/main.dart';
// import 'package:chat_app/model/chatlist.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class SearchPage extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;

//   const SearchPage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

//   @override
//   _SearchPageState createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {

//   TextEditingController searchController = TextEditingController();

//   Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
//     ChatRoomModel? chatRoom;

//     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).where("participants.${targetUser.uid}", isEqualTo: true).get();

//     if(snapshot.docs.length > 0) {
//       // Fetch the existing one
//       var docData = snapshot.docs[0].data();
//       ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);

//       chatRoom = existingChatroom;
//     }
//     else {
//       // Create a new one
//       ChatRoomModel newChatroom = ChatRoomModel(
//         chatroomid: uuid.v1(),
//         lastMessage: "",
//         participants: {
//           widget.userModel.uid.toString(): true,
//           targetUser.uid.toString(): true,
//         },
//       );

//       await FirebaseFirestore.instance.collection("chatrooms").doc(newChatroom.chatroomid).set(newChatroom.toMap());

//       chatRoom = newChatroom;

//       log("New Chatroom Created!");
//     }

//     return chatRoom;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Search"),
//       ),
//       body: SafeArea(
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 10,
//           ),
//           child: Column(
//             children: [

//               TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   labelText: "Email Address"
//                 ),
//               ),

//               SizedBox(height: 20,),

//               CupertinoButton(
//                 onPressed: () {
//                   setState(() {});
//                 },
//                 color: Theme.of(context).colorScheme.secondary,
//                 child: Text("Search"),
//               ),

//               SizedBox(height: 20,),

//               StreamBuilder(
//                 stream: FirebaseFirestore.instance.collection("users").where("email", isEqualTo: searchController.text).where("email", isNotEqualTo: widget.userModel.email).snapshots(),
//                 builder: (context, snapshot) {
//                   if(snapshot.connectionState == ConnectionState.active) {
//                     if(snapshot.hasData) {
//                       QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

//                       if(dataSnapshot.docs.length > 0) {
//                         Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;

//                         UserModel searchedUser = UserModel.fromMap(userMap);

//                         return ListTile(
//                           onTap: () async {
//                             ChatRoomModel? chatroomModel = await getChatroomModel(searchedUser);

//                             if(chatroomModel != null) {
//                               Navigator.pop(context);
//                               Navigator.push(context, MaterialPageRoute(
//                                 builder: (context) {
//                                   return ChatRoomPage(
//                                     targetUser: searchedUser,
//                                     userModel: widget.userModel,
//                                     firebaseUser: widget.firebaseUser,
//                                     chatroom: chatroomModel,
//                                   );
//                                 }
//                               ));
//                             }
//                           },
//                           leading: CircleAvatar(
//                             backgroundImage: NetworkImage(searchedUser.profileImageUrl!),
//                             backgroundColor: Colors.grey[500],
//                           ),
//                           title: Text(searchedUser.name!),
//                           subtitle: Text(searchedUser.email!),
//                           trailing: Icon(Icons.keyboard_arrow_right),
//                         );
//                       }
//                       else {
//                         return Text("No results found!");
//                       }
                      
//                     }
//                     else if(snapshot.hasError) {
//                       return Text("An error occured!");
//                     }
//                     else {
//                       return Text("No results found!");
//                     }
//                   }
//                   else {
//                     return CircularProgressIndicator();
//                   }
//                 }
//               ),

//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:developer';

import 'package:chat_app/Screens/chatlist/chatRoomPage.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/chatlist.dart';


class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  void fetchAllUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("users").get();
    List<UserModel> users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();

    // Remove current user from the list
    users.removeWhere((user) => user.uid == widget.userModel.uid);

    setState(() {
      allUsers = users;
      filteredUsers = users;
    });
  }

  void filterUsers(String query) {
    List<UserModel> results = [];
    if (query.isEmpty) {
      results = allUsers;
    } else {
      results = allUsers.where((user) => user.name!.toLowerCase().contains(query.toLowerCase())).toList();
    }

    setState(() {
      filteredUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: "Search by Name"),
                onChanged: (value) {
                  filterUsers(value);
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    UserModel user = filteredUsers[index];

                    return ListTile(
                      onTap: () async {
                        ChatRoomModel? chatroomModel = await getChatroomModel(user);

                        if (chatroomModel != null) {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ChatRoomPage(
                                targetUser: user,
                                userModel: widget.userModel,
                                firebaseUser: widget.firebaseUser,
                                chatroom: chatroomModel,
                              );
                            },
                          ));
                        }
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.profileImageUrl!),
                        backgroundColor: Colors.grey[500],
                      ),
                      title: Text(user.name!),
                      subtitle: Text(user.email!),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).where("participants.${targetUser.uid}", isEqualTo: true).get();

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

      log("New Chatroom Created!");
    }

    return chatRoom;
  }
}
