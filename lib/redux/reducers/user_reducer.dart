import 'package:flutter_redux_firebase/redux/actions/user_actions.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:redux/redux.dart';

final userReducer = combineReducers<User>([
  TypedReducer<User, SetUserAction>(_setUser),
  TypedReducer<User, SetUserLoadingAction>(_setUserLoading),
  TypedReducer<User, UnSetUserLoadingAction>(_unSetUserLoading),
  TypedReducer<User, SetUserMinSec>(_setUserMinSec),
  TypedReducer<User, SetUserMaxSec>(_setUserMaxSec),
  TypedReducer<User, SetUserExcelFile>(_setUserExcelFile),
]);

User _setUser(User userState, SetUserAction action) {
  return userState.copyWith(action.user);
}

User _setUserLoading(User userState, SetUserLoadingAction action) {
  return userState.copyWith(User(loading: true));
}

User _unSetUserLoading(User userState, UnSetUserLoadingAction action) {
  return userState.copyWith(User(loading: false));
}

User _setUserMinSec(User state, SetUserMinSec action) {
  return state.copyWith(User(minSec: action.minSec));
}

User _setUserMaxSec(User state, SetUserMaxSec action) {
  return state.copyWith(User(maxSec: action.maxSec));
}

User _setUserExcelFile(User state, SetUserExcelFile action) {
  return state.copyWith(User(excelFile: action.excelFile));
}
