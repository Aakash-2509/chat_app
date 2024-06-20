


class chatuser {
  chatuser({
    required this.name,
    required this.email,
    required this.profileImageUrl,
  });
  late final String name;
  late final String email;
  late final String profileImageUrl;

  chatuser.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? "";
    email = json['email'] ?? "";
    profileImageUrl = json['profileImageUrl'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['profileImageUrl'] = profileImageUrl;
    return data;
  }
}
class UserModel {
  UserModel({
     this.uid,
     this.name,
     this.email,
     this.profileImageUrl,
  });
    String? uid;
    String? name;
    String? email;
    String? profileImageUrl;

  UserModel.fromMap(Map<String, dynamic> map){
    uid = map['uid']?? "";
    name = map['name'] ?? "";
    email = map['email'] ?? "";
    profileImageUrl = map['profileImageUrl'] ?? "";
  }

  Map<String, dynamic> toMap() {
  
   return { 
    'uid': uid,
    'name': name,
    'email': email,
    'profileImageUrl': profileImageUrl,
};
  }
}

class ChatRoomModel {
  String ? chatroomid;
  List<String>? participants;
  ChatRoomModel({this.chatroomid, this.participants});

ChatRoomModel.fromMap(Map<String, dynamic> map) {
chatroomid = map["chatroomid"];
participants = map["participants"];


}

Map<String, dynamic> toMap() {

  return{
    "chatroomid" : chatroomid,
    "participants": participants

  };
}

}






class MessageModel {
  String ? sender;
  String ? text;
  bool ? seen;
  DateTime ? createdon;
 
  MessageModel({this.sender, this.text, this.seen, this.createdon});

MessageModel.fromMap(Map<String, dynamic> map) {
sender = map["sender"];
text = map["text"];
seen = map["seen"];
createdon = map["createdon"];


}

Map<String, dynamic> toMap() {

  return{
    "sender" : sender,
    "text": text,
        "seen": seen,
            "createdon": createdon

  };
}

}




