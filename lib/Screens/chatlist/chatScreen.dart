import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String email;
  final String profileImageUrl;
  final String fcmToken;

  const ChatScreen({
    super.key,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.fcmToken,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _messagesCollection;

  @override
  void initState() {
    super.initState();
    _messagesCollection = _firestore.collection('messages');
  }

  // void _sendMessage() {
  //   if (_controller.text.trim().isEmpty) return;

  //   _messagesCollection.add({
  //     'text': _controller.text,
  //     'sender': widget.email,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });

  //   _controller.clear();
  // }

  void _sendMessage() {
  if (_controller.text.trim().isEmpty) return;

  // Get the recipient's email
  String recipientEmail = widget.email;

  // Add message to recipient's messages collection
  _firestore.collection('users').doc(recipientEmail).collection('messages').add({
    'text': _controller.text,
    'sender': FirebaseAuth.instance.currentUser!.email,
    'timestamp': FieldValue.serverTimestamp(),
  });

  _controller.clear();
}


  Widget _buildMessage(DocumentSnapshot message) {
    bool isOutgoing = message['sender'] == widget.email;
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isOutgoing ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color: isOutgoing ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[100],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.profileImageUrl),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name),
                  const Text(
                    'Last seen recently',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Add more options here
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _messagesCollection
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(messages[index]);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
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



// import 'package:chat_app/model/chatlist.dart';
// import 'package:dash_chat_2/dash_chat_2.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatScreen extends StatefulWidget {
//   final String name;
//   final String email;
//   final String profileImageUrl;
//   final UserModel targeUser;
//   final ChatRoomModel chatroom;
//   final UserModel userModel;
//   final User fireBaseUser;


//   const ChatScreen({
//     super.key,
//     required this.name,
//     required this.email,
//     required this.profileImageUrl,
//       required this.targeUser,
//         required this.chatroom,
//           required this.userModel,
//             required this.fireBaseUser,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late CollectionReference _messagesCollection;

//   @override
//   void initState() {
//     super.initState();
//     _messagesCollection = _firestore.collection('messages');
//   }

//   // void _sendMessage() {
//   //   if (_controller.text.trim().isEmpty) return;

//   //   _messagesCollection.add({
//   //     'text': _controller.text,
//   //     'sender': widget.email,
//   //     'timestamp': FieldValue.serverTimestamp(),
//   //   });

//   //   _controller.clear();
//   // }

//   void _sendMessage() {
//   if (_controller.text.trim().isEmpty) return;

//   // Get the recipient's email
//   String recipientEmail = widget.email;

//   // Add message to recipient's messages collection
//   _firestore.collection('users').doc(recipientEmail).collection('messages').add({
//     'text': _controller.text,
//     'sender': FirebaseAuth.instance.currentUser!.email,
//     'timestamp': FieldValue.serverTimestamp(),
//   });

//   _controller.clear();
// }


//   Widget _buildMessage(DocumentSnapshot message) {
//     bool isOutgoing = message['sender'] == widget.email;
//     return Align(
//       alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: isOutgoing ? Colors.blue : Colors.grey[300],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           message['text'],
//           style: TextStyle(
//             color: isOutgoing ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.purple[100],
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 backgroundImage: NetworkImage(widget.profileImageUrl),
//               ),
//               const SizedBox(width: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(widget.name),
//                   const Text(
//                     'Last seen recently',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.more_vert),
//               onPressed: () {
//                 // Add more options here
//               },
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: StreamBuilder(
//                 stream: _messagesCollection.orderBy('timestamp', descending: true).snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   var messages = snapshot.data!.docs;
//                   return ListView.builder(
//                     reverse: true,
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       return _buildMessage(messages[index]);
//                     },
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText: 'Type a message',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 20),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: _sendMessage,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




