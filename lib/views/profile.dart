import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/shared_preference.dart';
import '../services/auth_manager.dart';
import '../services/database_manager.dart';
import 'conversation.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AuthManager authMethods = AuthManager();
  DatabaseManager databaseMethods = DatabaseManager();
  int currentIndex = 1;
  String? userId;
  String username = "";
  String profileImage = "";
  File? newProfileImage;

  signOut() {
    authMethods.signOut().then((isSignOut) {
      if (isSignOut) {
        print("success to sign out");
        Navigator.of(context).pushReplacementNamed("login");
      } else {
        print("failed to sign out");
      }
    });
  }

  getUserInfo() {
    userId = AuthManager().getIdForCurrentUser();
    if (userId != null) {
      print("userId: $userId");
      databaseMethods.getUserInfo(userId!).then((user) {
        if (user != null) {
          setState(() {
            username = user.name;
            profileImage = user.profileUrl;
            HelperFunctions.saveUserIDSharedPreference(userId!);
            HelperFunctions.saveUserNameSharedPreference(username);
            HelperFunctions.saveUserImageSharedPreference(profileImage);
          });
        }
      });
    }
  }

  openGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      newProfileImage = File(pickedImage.path);
      print("New image");

      await databaseMethods
          .uploadProfileImage(userId!, newProfileImage!)
          .then((downloadUrl) {
        if (downloadUrl != null) {
          setState(() {
            profileImage = downloadUrl;
          });
          databaseMethods.updateUserImage(userId!, downloadUrl);
          HelperFunctions.saveUserImageSharedPreference(profileImage);
        }
      });
    }
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          print(index);
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xff582cb4),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ("Chat")),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ("Profile")),
        ],
      ),
      body: currentIndex == 1
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                        width: double.infinity,
                        height: 200,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xff602eb0), Color(0xffa24ebb)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                        )),
                    SafeArea(
                        child: Container(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            signOut();
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          )),
                    )),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 100),
                        child: GestureDetector(
                          onTap: () {
                            openGallery();
                          },
                          child: CircleAvatar(
                            radius: 100,
                            backgroundColor: const Color(0xff582cb4),
                            backgroundImage: profileImage != ""
                                ? Image.network(profileImage).image
                                : null,
                            child: profileImage != ""
                                ? null
                                : Text(
                                    username,
                                    style: TextStyle(fontSize: 50),
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(username),
              ],
            )
          : Center(
              child:
                  GestureDetector(onTap: () {}, child: const Conversations())),
    );
  }
}
