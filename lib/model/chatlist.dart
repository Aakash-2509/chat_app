// class chatuser {
//   chatuser({
//     required this.name,
//      required this.email,
//   });
//   late final String name;
//   late final String email;

//   chatuser.fromJson(Map<String, dynamic> json){
//     name = json['name']?? "";
//     email = json['email']?? "";
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['name'] = name;
//     data['email'] = email;
//     return data;
//   }
// }

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
