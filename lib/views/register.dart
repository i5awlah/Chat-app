import 'package:flutter/material.dart';
import 'package:silah_app/models/user.dart';
import 'package:silah_app/services/database_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../services/auth_manager.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  AuthManager authMethods = AuthManager();
  DatabaseManager databaseMethods = DatabaseManager();

  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  signUp() {
    print("signUp Method");
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    if (formKey.currentState != null) {
      if (formKey.currentState!.validate()) {
        authMethods.signUpWithEmailAndPassword(email, password).then((id) async {
          if (id != null) {
            print("Success Register with id: $id");
            String profileUrl = "";
            if (profileImage != null) {
              await databaseMethods.uploadProfileImage(id, profileImage!).then((downloadUrl) {
                if (downloadUrl != null) {
                  profileUrl = downloadUrl;
                }
              });
            }
            UserModal newUser =
                UserModal(userId: id, name: username, profileUrl: profileUrl);
            databaseMethods.uploadUserInfo(newUser);
            Navigator.of(context).pushReplacementNamed("profile");
          } else {
            print("Filed to register");
          }
        });
      }
    }
  }
  signUpWithGoogle() {
    print("signUpWithGoogle Method");
  }

  openLogin() {
    Navigator.of(context).pushNamed("login");
  }

  openGallery() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        profileImage = File(pickedImage.path);
        print("New image");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xff602eb0), Color(0xffa24ebb)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    openGallery();
                  },
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: const Color(0xff582cb4).withOpacity(0.3),
                    backgroundImage: profileImage == null
                        ? Image.asset(
                            "assets/images/profile_image.png",
                            color: Colors.white.withOpacity(0.5),
                          ).image
                        : Image.file(profileImage!).image,
                  ),
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (val) {
                          return val!.isEmpty || val.length < 4
                              ? "Please provide a valid username"
                              : null;
                        },
                        controller: usernameController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: "username",
                          hintStyle: TextStyle(color: Colors.white54),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      TextFormField(
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val!)
                              ? null
                              : "Please provide a valid Email";
                        },
                        controller: emailController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: "email",
                          hintStyle: TextStyle(color: Colors.white54),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      TextFormField(
                        validator: (val) {
                          return val!.length > 6
                              ? null
                              : "Please provide password 6+ characters";
                        },
                        controller: passwordController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "password",
                          hintStyle: TextStyle(color: Colors.white54),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                GestureDetector(
                  onTap: () {
                    signUp();
                  },
                  child: Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xff582cb4),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign Up",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w200),
                        ),
                      )),
                ),
                const SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () {
                    signUpWithGoogle();
                  },
                  child: Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign Up with Google",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w200),
                        ),
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have account?",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    TextButton(
                        onPressed: () {
                          openLogin();
                        },
                        child: const Text("SignIn Now",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)))
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
