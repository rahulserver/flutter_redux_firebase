import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_redux_firebase/redux/actions/user_actions.dart';
import 'package:flutter_redux_firebase/redux/models/root_state.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:flutter_redux_firebase/services/firebase_service.dart';
import 'package:flutter_redux_firebase/services/twitter_service.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<RootState> fetchUser(twitterHandle, password) {
  print("fetchUserFired()${twitterHandle} ${password}");
  return (Store<RootState> store) async {
    User user;
    try {
      store.dispatch(SetUserLoadingAction());
      var data = await FirebaseService.getUserData(twitterHandle);
      if(data!=null) {
        // user exists
        user = User(twitterhandle: twitterHandle, email: data["email"], active: data["active"], loading: false, exists: true, error: null);
        var tokenData = await TwitterService.loginUser(twitterHandle, password);

        store.dispatch(SetUserAction(user));
      } else {
        // user does not exist
        user = User(twitterhandle: twitterHandle, loading: false, exists: false, error: null);
        store.dispatch(SetUserAction(user));
      }
    } catch (e) {
      // TODO: handle error
      print("Error happened future "+e.toString());
      user = User(twitterhandle: twitterHandle, loading: false, error: e.details);
      store.dispatch(SetUserAction(user));
    }
  };
}

