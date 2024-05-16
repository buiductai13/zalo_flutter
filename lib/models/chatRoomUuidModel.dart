import 'package:uuid/uuid.dart';

class ChatRoomUtil {
  static String generateChatRoomId(String userId1, String userId2) {
    String namespace =
        "1b671a64-40d5-491e-99b0-da01ff1f3341"; // Replace with your own UUID
    List<String> sortedUserIds = [userId1, userId2]..sort();
    String name = sortedUserIds.join('-');
    return Uuid().v5(namespace, name);
  }
}
