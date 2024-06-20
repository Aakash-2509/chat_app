// import 'dart:convert';
// import 'dart:developer';
// import 'package:chat_app/Screens/chatlist/chatScreen.dart';
// import 'package:chat_app/model/chatlist.dart';
// import 'package:chat_app/repo/apis.dart';
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


import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/Screens/chatlist/chatScreen.dart';
import 'package:chat_app/model/chatlist.dart';
import 'package:chat_app/repo/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<chatuser> list = [];
  List<chatuser> filteredList = [];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final User? user = APIs.auth.currentUser; // Get the logged-in user

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 18.0),
            onChanged: (query) {
              setState(() {
                searchQuery = query.toLowerCase();
                filteredList = list.where((user) {
                  return user.name.toLowerCase().contains(searchQuery) ||
                      user.email.toLowerCase().contains(searchQuery);
                }).toList();
              });
            },
          ),
        ),
        backgroundColor: Colors.grey[300],
      ),
      body: StreamBuilder(
        stream: APIs.firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              list =
                  data?.map((e) => chatuser.fromJson(e.data())).toList() ?? [];
              // Exclude the logged-in user from the list
              list.removeWhere((element) => element.email == user?.email);
              filteredList = searchQuery.isEmpty ? list : filteredList;
              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(filteredList[index].profileImageUrl),
                          radius: 25.0,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              filteredList[index].name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: Container(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            filteredList[index].email,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15.0),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                name: filteredList[index].name,
                                email: filteredList[index].email,
                                profileImageUrl:
                                    filteredList[index].profileImageUrl,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 10.0),
                    ],
                  );
                },
              );
          }
        },
      ),
    );
  }
}
