import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class TwitterService {
  static const platform =
      const MethodChannel('com.example.flutter_redux_firebase/foreground');

  // get user by twitter handle from firebase
  static dynamic loginUser(twitterHandle, password) {
    return platform.invokeMethod(
        "loginUser", {"twitterHandle": twitterHandle, "password": password});
  }
}
