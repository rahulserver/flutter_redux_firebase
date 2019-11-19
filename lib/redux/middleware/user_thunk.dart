import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_redux_firebase/redux/actions/user_actions.dart';
import 'package:flutter_redux_firebase/redux/models/root_state.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:flutter_redux_firebase/services/firebase_service.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<RootState> fetchUser() {
  print("fetchUserFired()");
  return (Store<RootState> store) async {
    try {
      store.dispatch(SetUserLoadingAction());
      DocumentSnapshot ds = await FirebaseService.getUserData('blunderfoe');
      User user = User(twitterhandle: ds.documentID, email: ds.data['email'], active: ds.data['active'], loading: false);
      print('user ${user}');
      store.dispatch(SetUserAction(user));
    } catch (e) {
      // TODO: handle error
      print("Error happened future "+e.toString());
      print("Error happened future ${e.stackTrace}");
    }
  };
}
