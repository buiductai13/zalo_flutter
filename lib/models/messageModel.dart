// ignore_for_file: file_names

class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  String? createdon;

  MessageModel(
      {this.messageid, this.createdon, this.seen, this.sender, this.text});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"];
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
    };
  }
}
