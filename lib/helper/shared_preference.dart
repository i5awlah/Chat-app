import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silah_app/models/user.dart';

class HelperFunctions{
  static String userIdKey = "USER ID KEY";
  static String userNameKey = "USER NAME KEY";
  static String userImageKey = "USER IMAGE KEY";

  // saving data to shared preference
  static Future<bool> saveUserIDSharedPreference(String userID) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(userIdKey, userID);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(userNameKey, userName);
  }

  static Future<bool> saveUserImageSharedPreference(String userImage) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(userImageKey, userImage);
  }

  // fetching data from shared preference
  static Future<String> getUserIDSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userIdKey) ?? "";
  }

  static Future<String> getUserNameSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userNameKey) ?? "";
  }

  static Future<String> getUserImageSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userImageKey) ?? "";
  }

  static Future<UserModal> getUserSharedPreference() async{
    String userID ="";
    String userName="";
    String userProfileImage="";
    await HelperFunctions.getUserIDSharedPreference().then((id) {userID = id;});
    await HelperFunctions.getUserNameSharedPreference().then((name) {userName = name;});
    await HelperFunctions.getUserImageSharedPreference().then((profileImage) {userProfileImage = profileImage;});
    return UserModal(userId: userID, name: userName, profileUrl: userProfileImage);
  }


}