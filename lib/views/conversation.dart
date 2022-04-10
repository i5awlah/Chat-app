import 'package:flutter/material.dart';
import 'package:silah_app/helper/shared_preference.dart';
import 'package:silah_app/models/LatestMessage.dart';
import 'package:silah_app/models/user.dart';
import 'package:silah_app/views/chat.dart';
import '../models/Conversation.dart';
import '../services/DateFormatter.dart';
import '../services/database_manager.dart';

class Conversations extends StatefulWidget {
  const Conversations({Key? key}) : super(key: key);

  @override
  State<Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  DatabaseManager databaseMethods = DatabaseManager();
  List<Conversation> conversations = [];
  @override
  void initState() {
    getConversations();
    super.initState();
  }

  getConversations() async {
    await HelperFunctions.getUserSharedPreference().then((user) {
      databaseMethods.getConversions(user.userId).onData((data) {
        conversations.clear();
        if (data.snapshot.value != null) {
          final map = data.snapshot.value as Map<dynamic, dynamic>;
          map.forEach((key, value) {
            String name;
            String id;
            String imageUrl;
            if (value["senderName"] != null) {
              name = value["senderName"];
            } else {
              name = value["receiverName"];
            }
            if (value["senderId"] != null) {
              id = value["senderId"];
            } else {
              id = value["receiverId"];
            }
            if (value["senderImage"] != null) {
              imageUrl = value["senderImage"];
            } else {
              imageUrl = value["receiverImage"];
            }
            conversations.add(Conversation(
              latestMessage: LatestMessage(
                  content: value["content"],
                  date: value["date"],
                  isRead: value["isRead"]),
              id: value["id"],
              otherID: id,
              name: name,
              otherImage: imageUrl,
            ));
            setState(() {});
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        centerTitle: false,
        backgroundColor: const Color(0xff582cb4),
        actions: [
          IconButton(
              onPressed: () async {
                List<UserModal> users = [];
                await DatabaseManager().getUsers().then((usersResult) {
                  if (usersResult != null) {
                    users = usersResult;
                  }
                });
                UserModal? currentUser;
                await HelperFunctions.getUserSharedPreference().then((user) {
                  currentUser = user;
                });
                if (currentUser != null) {
                  showSearch(
                      context: context,
                      delegate:
                          UsersSearch(users: users, currentUser: currentUser!));
                }
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: conversations.isEmpty
          ? const Center(child: Text("No conversations"))
          : ListView.separated(
              itemCount: conversations.length,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () async {
                    print(conversations[i].id);
                    UserModal? selectedUser;
                    await databaseMethods
                        .getUserInfo(conversations[i].otherID)
                        .then((user) {
                      selectedUser = user;
                    });
                    UserModal? currentUser;
                    await HelperFunctions.getUserSharedPreference()
                        .then((user) {
                      currentUser = user;
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Chat(
                                currentUser: currentUser!,
                                receiverUser: selectedUser!)));
                  },
                  child: ConversationList(
                    conversation: conversations[i],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 1,
                  color: Colors.grey,
                );
              },
            ),
    );
  }
}

class ConversationList extends StatefulWidget {
  Conversation conversation;
  ConversationList({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.conversation.otherImage),
                  maxRadius: 30,
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.conversation.name,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          widget.conversation.latestMessage.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter().getVerboseDateTimeRepresentation(
                    widget.conversation.latestMessage.date),
                style: TextStyle(
                    fontSize: 12,
                    color: widget.conversation.latestMessage.isRead
                        ? Colors.black
                        : Color(0xff0047AB)),
              ),
              SizedBox(
                height: 10,
              ),
              widget.conversation.latestMessage.isRead
                  ? Container()
                  : const CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xff0047AB),
                    )
            ],
          ),
        ],
      ),
    );
  }
}

class UsersSearch extends SearchDelegate {
  List<UserModal> users;
  UserModal currentUser;
  UserModal? selectedUser;
  UsersSearch({required this.users, required this.currentUser});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<UserModal> filteredUsers =
        users.where((element) => element.name.startsWith(query)).toList();

    return ListView.builder(
        itemCount: query == "" ? users.length : filteredUsers.length,
        itemBuilder: (context, i) {
          return ListTile(
            title:
                query == "" ? Text(users[i].name) : Text(filteredUsers[i].name),
            leading: CircleAvatar(
                backgroundImage: query == ""
                    ? users[i].profileUrl != ""
                        ? Image.network(users[i].profileUrl).image
                        : null
                    : filteredUsers[i].profileUrl != ""
                        ? Image.network(filteredUsers[i].profileUrl).image
                        : null),
            trailing: MaterialButton(
              color: const Color(0xff582cb4),
              onPressed: () {
                query = query == "" ? users[i].name : filteredUsers[i].name;
                selectedUser = query == "" ? users[i] : filteredUsers[i];

                print(
                    "Me: ${currentUser.userId} another: ${selectedUser?.userId}");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                            currentUser: currentUser,
                            receiverUser: selectedUser!)));
              },
              child: Text(
                "message",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }
}
