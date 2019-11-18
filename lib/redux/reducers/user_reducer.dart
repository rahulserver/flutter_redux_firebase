import 'package:flutter_redux_firebase/redux/actions/user_actions.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:redux/redux.dart';

final userReducer =
    combineReducers<User>([
        TypedReducer<User, SetUserAction>(_setUser),
        TypedReducer<User, SetUserLoadingAction>(_setUserLoading)
      ]);

User _setUser(User userState, SetUserAction action) {
  return userState.copyWith(action.user);
}

User _setUserLoading(User userState, SetUserLoadingAction action) {
  return userState.copyWith(User(loading: true));
}
