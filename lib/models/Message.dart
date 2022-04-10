
class Message {
  String id;
  String content;
  String date;
  String senderId;
  bool isRead;

  Message(
      {required this.id,
      required this.content,
      required this.date,
      required this.senderId,
      required this.isRead});
}
