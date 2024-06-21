


class chatuser {
  chatuser({
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.fcmToken,
  });
  late final String name;
  late final String email;
  late final String profileImageUrl;
  late final String fcmToken;

  chatuser.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
    email = json['email'] ?? "";
    profileImageUrl = json['profileImageUrl'] ?? "";
    fcmToken = json['fcmToken'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['profileImageUrl'] = profileImageUrl;
    data['fcmToken'] = fcmToken;
    return data;
  }
}
class UserModel {
  UserModel({
     this.uid,
     this.name,
     this.email,
     this.profileImageUrl,
     this.fcmToken,
  });
    String? uid;
    String? name;
    String? email;
    String? profileImageUrl;
    String? fcmToken;

  UserModel.fromMap(Map<String, dynamic> map){
    uid = map['uid']?? "";
    name = map['name'] ?? "";
    email = map['email'] ?? "";
    profileImageUrl = map['profileImageUrl'] ?? "";
    fcmToken = map['fcmToken'] ?? "";
  }

  Map<String, dynamic> toMap() {
  
   return { 
    'uid': uid,
    'name': name,
    'email': email,
    'profileImageUrl': profileImageUrl,
    'fcmToken': fcmToken,
};
  }
}

class ChatRoomModel {
  String ? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;

  ChatRoomModel({this.chatroomid, this.participants,this.lastMessage});

ChatRoomModel.fromMap(Map<String, dynamic> map) {
chatroomid = map["chatroomid"];
participants = map["participants"];
lastMessage = map["lastMessage"];


}

Map<String, dynamic> toMap() {

  return{
    "chatroomid" : chatroomid,
    "participants": participants,
    "lastMessage": lastMessage

  };
}

}





class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  MessageModel({this.messageid, this.sender, this.text, this.seen, this.createdon});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();    
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon
    };
  }
}