import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class FirebaseService {
  static const platform =
      const MethodChannel('com.example.flutter_redux_firebase/foreground');

  // get user by twitter handle from firebase
  static dynamic getUserData(twitterHandle) {
    return platform.invokeMethod("checkUser", {"twitterHandle": twitterHandle});
  }
}
