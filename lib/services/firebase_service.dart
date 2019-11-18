import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // get user by twitter handle from firebase
  static Future<DocumentSnapshot> getUserData(twitterHandle) {
    return Firestore.instance
        .collection('users')
        .document(twitterHandle)
        .get();
  }
}
