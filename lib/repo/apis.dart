import 'package:chat_app/model/chatlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs{

  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User  get user => auth.currentUser!;

  static Future<bool> userExists() async{
    return (await firestore.collection('user').doc(auth.currentUser!.uid).get()).exists;
  }


static Future<void> createUser() async{
  final chatUser = chatuser(image: user.photoURL.toString(), name: user.displayName.toString() , about: "happy ", isOnline: false, id: user.uid, pushToken: "" , email: user.email.toString());


return await firestore.collection('user').doc(user.uid).set(chatUser.toJson());
}


}