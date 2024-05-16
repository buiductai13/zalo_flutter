// ignore_for_file: file_names

class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepicture;
  String? friendList;
  UserModel(
      {this.uid,
      this.fullname,
      this.email,
      this.profilepicture,
      this.friendList});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepicture = map["profilepicture"];

    dynamic friendListData = map["friendList"];
    if (friendListData is List) {
      // Handle the case where 'friendListData' is a List
      // For example, you can join the elements into a single string
      friendList = friendListData.join(',');
    } else if (friendListData is String) {
      friendList = friendListData; // Directly assign the string
    } else {
      // Handle the case where 'friendListData' is neither a List nor a String
      friendList =
          null; // Or provide a default value based on your requirements
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepicture": profilepicture,
      "friendList": friendList,
    };
  }
}
