import 'package:flutter_redux_firebase/redux/models/user.dart';

class SetUserAction {
  final User user;
  SetUserAction(this.user);
}

class SetUserLoadingAction {
  SetUserLoadingAction();
}