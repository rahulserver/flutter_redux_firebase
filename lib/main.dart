import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_firebase/redux/models/root_state.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:flutter_redux_firebase/redux/reducers/root_reducer.dart';
import 'package:flutter_redux_firebase/screens/dashboard.dart';
import 'package:flutter_redux_firebase/screens/signin.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

const platform =
    const MethodChannel('com.example.flutter_redux_firebase/foreground');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var sp = await platform.invokeMethod("sharedPrefs.all");
  var initialState = RootState.initial();
  if (sp["token"] != null) {
    var user = User(
        active: true,
        exists: true,
        minSec: sp["minSec"],
        maxSec: sp["maxSec"],
        token: sp["token"],
        twitterhandle: sp["twitterHandle"],
        tweeting: (sp["running"] != null) ? (sp["running"] == 'true') : false,
        password: sp["password"],
        excelFile: sp["excelFile"]);
    initialState = initialState.copyWith(user: user);
  }
  final store = Store<RootState>(
    rootReducer,
    initialState: initialState,
    middleware: [
      thunkMiddleware // Add to middlewares
    ],
  );
  runApp(StoreProvider(store: store, child: MyApp(sp)));
}

class MyApp extends StatelessWidget {
  var sp;

  MyApp(this.sp);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => (sp["token"] == null) ? Signin(sp) : Dashboard(sp),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/dashboard': (context) => Dashboard(sp),
        '/signin': (context) => Signin(sp)
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
    );
  }
}
