class chatuser {
  chatuser({
    required this.image,
    required this.name,
    required this.about,
    required this.isOnline,
    required this.id,
    required this.pushToken,
    required this.email,
  });
  late final String image;
  late final String name;
  late final String about;
  late final bool isOnline;
  late final String id;
  late final String pushToken;
  late final String email;
  
  chatuser.fromJson(Map<String, dynamic> json){
    image = json['image'] ?? "";
    name = json['name']?? "";
    about = json['about']?? "";
    isOnline = json['is_online']?? "";
    id = json['id']?? "";
    pushToken = json['push_token']?? "";
    email = json['email']?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['push_token'] = pushToken;
    data['email'] = email;
    return data;
  }
}