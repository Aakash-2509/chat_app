// home_tab.dart
import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/model/chatlist.dart';
import 'package:chat_app/repo/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// class HomeTab extends StatefulWidget {
//   const HomeTab({super.key});

//   @override
//   State<HomeTab> createState() => _HomeTabState();
// }

// class _HomeTabState extends State<HomeTab> {

//       List<chatuser> list = [];
// // chat_data.dart

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//           stream: APIs.firestore.collection('users').snapshots(),
//           builder: (context, snapshot) {
//             switch (snapshot.connectionState) {
//               case ConnectionState.waiting:
//               case ConnectionState.none:
//                 return const Center(child: CircularProgressIndicator());
//               case ConnectionState.active:
//               case ConnectionState.done:
//                 final data = snapshot.data?.docs;
//                 //  final list = [];

//                  list = data?.map((e) => chatuser.fromJson(e.data())).toList() ?? [];
//                 // for (var i in data!) {
//                 //   log('data: ${jsonEncode(i.data())}');
//                 //   list.add(i.data()['name']);
//                 // }

//                 return ListView.builder(
//                   itemCount: list.length,
//                   itemBuilder: (context, index) {
//                     return Column(
//                       children: <Widget>[
//                         const Divider(
//                           height: 10.0,
//                         ),
//                         ListTile(
//                           // leading: CircleAvatar(
//                           //   backgroundImage:
//                           //       NetworkImage(list[index].image),
//                           //   radius: 25.0,
//                           // ),
//                           title: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: <Widget>[
//                               Text(
//                                 list[index].name,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold),
//                               ),
//                               // Text(
//                               //   list[index].,
//                               //   style: const TextStyle(
//                               //       color: Colors.grey, fontSize: 14.0),
//                               // ),
//                             ], 
//                           ),
//                           subtitle: Container(
//                             padding: const EdgeInsets.only(top: 5.0),
//                             // child: Text(
//                             //   list[index].,
//                             //   style: const TextStyle(
//                             //       color: Colors.grey, fontSize: 15.0),
//                             // ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//             }
//           }),
//     );
//   }
// }


class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<chatuser> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                list = data?.map((e) => chatuser.fromJson(e.data())).toList() ?? [];
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        const Divider(
                          height: 10.0,
                        ),
                        ListTile(
                           leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage("https://images.pexels.com/photos/736230/pexels-photo-736230.jpeg?cs=srgb&dl=pexels-jonaskakaroto-736230.jpg&fm=jpg"),
                            radius: 25.0,
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                list[index].name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              list[index].email,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 15.0),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
            }
          }),
    );
  }
}
