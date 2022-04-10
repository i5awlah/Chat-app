import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:silah_app/models/Message.dart';
import 'package:silah_app/models/user.dart';

import '../services/database_manager.dart';

class Chat extends StatefulWidget {
  UserModal currentUser;
  UserModal receiverUser;
  Chat({Key? key, required this.currentUser, required this.receiverUser})
      : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  DatabaseManager databaseMethods = DatabaseManager();
  TextEditingController messageController = TextEditingController();
  late String conversionID;
  List<Message> messages = [];

  @override
  void initState() {
    conversionID = databaseMethods.generateConversionId(
        widget.currentUser.userId, widget.receiverUser.userId);
    print("conversionID: $conversionID");

    databaseMethods.getMessages(conversionID).onData((data) {
      messages.clear();
      if (data.snapshot.value != null) {
        final map = data.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          messages.add(Message(
              id: value["id"],
              content: value["content"],
              date: value["date"],
              senderId: value["senderId"],
              isRead: value["isRead"]));
        });
        messages.sort((Message m1, Message m2) => m1.date.compareTo(m2.date));
        _controller.jumpTo(_controller.position.maxScrollExtent); //TODO
        // update isRead
        if (messages[messages.length - 1].senderId !=
            widget.currentUser.userId) {
          databaseMethods.updateIsReadMessage(
              widget.currentUser.userId, conversionID, messages);
        }
        setState(() {});
      }
    });
    super.initState();
  }

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff582cb4),
          toolbarHeight: 70,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                widget.receiverUser.name,
              ),
              Text(
                "online",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white.withOpacity(0.9)),
              )
            ],
          ),
          actions: [
            CircleAvatar(
                radius: 30,
                backgroundImage: widget.receiverUser.profileUrl != ""
                    ? Image.network(widget.receiverUser.profileUrl).image
                    : Image.asset("assets/images/profile_image.png").image),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[200],
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _controller,
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        child: Align(
                          alignment:
                              messages[i].senderId == widget.currentUser.userId
                                  ? Alignment.topLeft
                                  : Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (messages[i].senderId ==
                                      widget.currentUser.userId
                                  ? Colors.white
                                  : Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(
                              messages[i].content,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Container(
                padding: EdgeInsets.only(left: 30, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: messageController,
                        decoration: InputDecoration(
                            hintText: "Type a message",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        String messageContent = messageController.text;
                        messageController.text = "";
                        databaseMethods.sendMessage(
                            conversionID,
                            messageContent,
                            widget.currentUser,
                            widget.receiverUser);
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
