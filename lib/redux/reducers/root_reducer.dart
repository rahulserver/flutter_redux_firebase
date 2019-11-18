import 'package:flutter_redux_firebase/redux/models/root_state.dart';
import 'package:flutter_redux_firebase/redux/reducers/user_reducer.dart';

RootState rootReducer(RootState state, dynamic action) {
   return new RootState(
        user: userReducer(state.user,action)
    );
}