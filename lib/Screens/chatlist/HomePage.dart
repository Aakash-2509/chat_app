// import 'dart:convert';
// import 'dart:developer';
// import 'package:chat_app/Screens/chatlist/chatScreen.dart';
// import 'package:chat_app/model/chatlist.dart';
// import 'package:chat_app/repo/apis.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class HomeTab extends StatefulWidget {

//   const HomeTab({super.key});

//   @override
//   State<HomeTab> createState() => _HomeTabState();
// }

// class _HomeTabState extends State<HomeTab> {
//   List<chatuser> list = [];
//   List<chatuser> filteredList = [];
//   String searchQuery = "";

//   @override
//   Widget build(BuildContext context) {
//     final User? user = APIs.auth.currentUser; // Get the logged-in user

//     return Scaffold(
//       appBar: AppBar(
//         title: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: TextField(
//             decoration: const InputDecoration(
//               hintText: 'Search...',
//               border: InputBorder.none,
//               hintStyle: TextStyle(color: Colors.black),
//             ),
//             style: const TextStyle(color: Colors.black, fontSize: 18.0),
//             onChanged: (query) {
//               setState(() {
//                 searchQuery = query.toLowerCase();
//                 filteredList = list.where((user) {
//                   return user.name.toLowerCase().contains(searchQuery) ||
//                       user.email.toLowerCase().contains(searchQuery);
//                 }).toList();
//               });
//             },
//           ),
//         ),
//         backgroundColor: Colors.grey[300],
//       ),
//       body: StreamBuilder(
//         stream: APIs.firestore.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//             case ConnectionState.none:
//               return const Center(child: CircularProgressIndicator());
//             case ConnectionState.active:
//             case ConnectionState.done:
//               final data = snapshot.data?.docs;
//               list =
//                   data?.map((e) => chatuser.fromJson(e.data())).toList() ?? [];
//               // Exclude the logged-in user from the list
//               list.removeWhere((element) => element.email == user?.email);
//               filteredList = searchQuery.isEmpty ? list : filteredList;
//               return ListView.builder(
//                 itemCount: filteredList.length,
//                 itemBuilder: (context, index) {
//                   return Column(
//                     children: <Widget>[
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage:
//                               NetworkImage(filteredList[index].profileImageUrl),
//                           radius: 25.0,
//                         ),
//                         title: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             Text(
//                               filteredList[index].name,
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                         subtitle: Container(
//                           padding: const EdgeInsets.only(top: 5.0),
//                           child: Text(
//                             filteredList[index].email,
//                             style: const TextStyle(
//                                 color: Colors.grey, fontSize: 15.0),
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ChatScreen(
//                                 name: filteredList[index].name,
//                                 email: filteredList[index].email,
//                                 fcmToken: filteredList[index].fcmToken,
//                                 profileImageUrl:
//                                     filteredList[index].profileImageUrl,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const Divider(height: 10.0),
//                     ],
//                   );
//                 },
//               );
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:chat_app/Screens/chatlist/chatRoomPage.dart';
// import 'package:chat_app/Screens/chatlist/searchPage.dart';
// import 'package:chat_app/model/FireBaseHelper.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// import '../../model/chatlist.dart';

// class HomePage extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;

//   const HomePage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(context, MaterialPageRoute(builder: (context) {
//             return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
//           }));
//         },
//         child: Icon(Icons.search),
//       ),
//       body: SafeArea(
//         child: Container(
//           child: StreamBuilder(
//             stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).snapshots(),
//             builder: (context, snapshot) {
//               if(snapshot.connectionState == ConnectionState.active) {
//                 if(snapshot.hasData) {
//                   QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

//                   return ListView.builder(
//                     itemCount: chatRoomSnapshot.docs.length,
//                     itemBuilder: (context, index) {
//                       ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatRoomSnapshot.docs[index].data() as Map<String, dynamic>);

//                       Map<String, dynamic> participants = chatRoomModel.participants!;

//                       List<String> participantKeys = participants.keys.toList();
//                       participantKeys.remove(widget.userModel.uid);

//                       return FutureBuilder(
//                         future: FirebaseHelper.getUserModelById(participantKeys[0]),
//                         builder: (context, userData) {
//                           if(userData.connectionState == ConnectionState.done) {
//                             if(userData.data != null) {
//                               UserModel targetUser = userData.data as UserModel;

//                               return ListTile(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(builder: (context) {
//                                       return ChatRoomPage(
//                                         chatroom: chatRoomModel,
//                                         firebaseUser: widget.firebaseUser,
//                                         userModel: widget.userModel,
//                                         targetUser: targetUser,
//                                       );
//                                     }),
//                                   );
//                                 },
//                                 leading: CircleAvatar(
//                                   backgroundImage: NetworkImage(targetUser.profileImageUrl.toString()),
//                                 ),
//                                 title: Text(targetUser.name.toString()),
//                                 subtitle: (chatRoomModel.lastMessage.toString() != "") ? Text(chatRoomModel.lastMessage.toString()) : Text("Say hi to your new friend!", style: TextStyle(
//                                   color: Theme.of(context).colorScheme.secondary,
//                                 ),),
//                               );
//                             }
//                             else {
//                               return Container();
//                             }
//                           }
//                           else {
//                             return Container();
//                           }
//                         },
//                       );
//                     },
//                   );
//                 }
//                 else if(snapshot.hasError) {
//                   return Center(
//                     child: Text(snapshot.error.toString()),
//                   );
//                 }
//                 else {
//                   return Center(
//                     child: Text("No Chats"),
//                   );
//                 }
//               }
//               else {
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }
//             },
//           ),
//         ),
//       ),

//     );
//   }
// }

import 'dart:developer';

import 'package:chat_app/Screens/chatlist/chatRoomPage.dart';
import 'package:chat_app/Screens/chatlist/searchPage.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../model/chatlist.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
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
                      UserModel user = UserModel.fromMap(
                          usersSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      // Don't show the current user
                      if (user.uid == widget.userModel.uid) {
                        return Container();
                      }

                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatRoomModel =
                              await getChatroomModel(user);

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
                          backgroundImage:
                              NetworkImage(user.profileImageUrl.toString()),
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
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

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

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;
    }

    return chatRoom;
  }
}
