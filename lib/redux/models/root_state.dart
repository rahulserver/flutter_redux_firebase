import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:meta/meta.dart';

@immutable
class RootState{

  final User user;

  RootState({
    @required this.user
  });

  factory RootState.initial(){
    return RootState(user: User.initial());
  }

  RootState copyWith({
    User user
  }){
    return RootState(
      user: user ?? this.user
    );
  }
}
