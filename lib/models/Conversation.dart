import 'LatestMessage.dart';

class Conversation {
  LatestMessage latestMessage;
  String id;
  String name;
  String otherID;
  String otherImage;

  Conversation(
      {required this.latestMessage,
      required this.id,
      required this.name,
      required this.otherID,
        required this.otherImage});
}
