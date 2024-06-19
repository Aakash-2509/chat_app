// home_tab.dart
import 'package:flutter/material.dart';
import '../../model/chatlist.dart';


class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
// chat_data.dart


List<Chat> dummyData = [
  Chat(
    name: "John Doe",
    message: "Hey, how's it going?",
    time: "15:30",
    avatarUrl: "https://via.placeholder.com/150",
  ),
  Chat(
    name: "Jane Smith",
    message: "Are we still meeting tomorrow?",
    time: "14:30",
    avatarUrl: "https://via.placeholder.com/150",
  ),
  // Add more dummy chats here
];



  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            const Divider(
              height: 10.0,
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(dummyData[index].avatarUrl),
                radius: 25.0,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    dummyData[index].name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    dummyData[index].time,
                    style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                ],
              ),
              subtitle: Container(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  dummyData[index].message,
                  style: const TextStyle(color: Colors.grey, fontSize: 15.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
