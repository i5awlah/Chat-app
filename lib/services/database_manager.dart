import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:silah_app/models/user.dart';
import 'dart:io';

import '../models/Message.dart';

class DatabaseManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future uploadUserInfo(UserModal user) async {
    var userMap = {
      "id": user.userId,
      "username": user.name,
      "profileUrl": user.profileUrl
    };
    await _firestore
        .collection("users")
        .doc(user.userId)
        .set(userMap)
        .then((value) {
      print("User Added");
    }).catchError((error) => print("Failed to add user: $error"));
  }

  Future updateUserImage(String userId, String profileUrl) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .update({"profileUrl": profileUrl}).then((value) {
      print("profile image Updated");
    }).catchError((error) => print("Failed to update image: $error"));
  }

  Future<UserModal?> getUserInfo(String id) async {
    UserModal? user;
    await _firestore.collection("users").doc(id).get().then((snapshot) {
      if (snapshot.data() != null) {
        var username = snapshot.data()!["username"];
        var profileUrl = snapshot.data()!["profileUrl"];
        user = UserModal(userId: id, name: username, profileUrl: profileUrl);
      }
    });
    return user;
  }

  Future<List<UserModal>?> getUsers() async {
    List<UserModal>? users = [];
    await _firestore.collection("users").get().then((snapshot) {
      final allData = snapshot.docs.map((doc) => doc.data()).toList();
      for (var i = 0; i < allData.length; i++) {
        var id = allData[i]["id"];
        var username = allData[i]["username"];
        var profileUrl = allData[i]["profileUrl"];
        users
            .add(UserModal(userId: id, name: username, profileUrl: profileUrl));
      }
    });
    return users;
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(String imageName, File imageFile) async {
    String? downloadUrl;
    await _storage
        .ref()
        .child("images/$imageName")
        .putFile(imageFile)
        .then((snapshot) async {
      if (snapshot.state == TaskState.success) {
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        print('Error from image repo ${snapshot.state.toString()}');
      }
    });
    return downloadUrl;
  }

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  sendMessage(String conversionId, String messageContent, UserModal currentUser,
      UserModal receiverUser) {
    DateTime now = DateTime.now();
    var conversationRef = _database.ref("conversations/$conversionId").push();
    var newMessageMap = {
      "id": conversationRef.key!,
      "content": messageContent,
      "date": now.toString(),
      "senderId": currentUser.userId,
      "isRead": false
    };
    conversationRef
        .set(newMessageMap)
        .then((value) => print("message sent"))
        .catchError((error) => print("Failed to send message: $error"));

    // each user
    var conversationMapCurrentUser = {
      "id": conversionId,
      // LatestMessage
      "isRead": true,
      "content": messageContent,
      "date": now.toString(),
      //
      "receiverName": receiverUser.name,
      "receiverId": receiverUser.userId,
      "receiverImage": receiverUser.profileUrl
    };

    var conversationMapReceiverUser = {
      "id": conversionId,
      // LatestMessage
      "isRead": false,
      "content": messageContent,
      "date": now.toString(),
      //
      "senderName": currentUser.name,
      "senderId": currentUser.userId,
      "senderImage": currentUser.profileUrl
    };

    FirebaseDatabase.instance
        .ref("users/${currentUser.userId}/conversations/$conversionId")
        .set(conversationMapCurrentUser)
        .then((value) => print("Successfully Added message to Current User"))
        .catchError(
            (error) => print("Failed to add message to Current User: $error"));

    FirebaseDatabase.instance
        .ref("users/${receiverUser.userId}/conversations/$conversionId")
        .set(conversationMapReceiverUser)
        .then((value) => print("Successfully Added message to Receiver User"))
        .catchError(
            (error) => print("Failed to add message to Receiver User: $error"));
  }

  updateIsReadMessage(
      String userID, String conversionId, List<Message> messages) {
    _database
        .ref("users/$userID/conversations/$conversionId")
        .update({"isRead": true});
    for (Message message in messages) {
      _database
          .ref("conversations/$conversionId/${message.id}")
          .update({"isRead": true});
    }
  }

  StreamSubscription<DatabaseEvent> getMessages(String conversionId) {
    return _database
        .ref("conversations/$conversionId")
        .orderByChild("date")
        .onValue
        .listen((event) {
      print("onValue");
    });
  }

  StreamSubscription<DatabaseEvent> getConversions(String userID) {
    return _database.ref("users/$userID/conversations").onValue.listen((event) {
      print("onValue");
    });
  }

  String generateConversionId(String senderId, String receiverId) {
    if (senderId.substring(0, 1).codeUnitAt(0) >
        receiverId.substring(0, 1).codeUnitAt(0)) {
      return "$receiverId\_$senderId";
    } else {
      return "$senderId\_$receiverId";
    }
  }
}
