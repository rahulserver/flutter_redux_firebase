import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_firebase/redux/middleware/user_thunk.dart';
import 'package:flutter_redux_firebase/redux/models/root_state.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:redux/redux.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

const platform =
    const MethodChannel('com.example.flutter_redux_firebase/foreground');

class Signin extends StatelessWidget {
  static final _formKey = GlobalKey<FormState>(debugLabel: '_SigninForm');

  var sp;

  Signin(this.sp);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<RootState, _ViewModel>(
        converter: (Store<RootState> store) => _ViewModel.fromStore(store),
        onWillChange: (_ViewModel vm) async {
          if ((vm.user.loading != null) && !vm.user.loading) {
            // dismiss the loading indicator
            Navigator.of(context).pop();

            if (vm.user.error != null) {
              _showDialog(context, "Error", "Error occurred: " + vm.user.error);
              return;
            }

            if ((vm.user.exists == null) || !vm.user.exists) {
              _showDialog(context, "Error",
                  "This handle is not authorized to use this app");
              return;
            }

            if ((vm.user.active != null) && !vm.user.active) {
              _showDialog(context, "Error", "Your twitter handle is inactive");
              return;
            }

            if (vm.user.token != null) {
              try {
                await platform.invokeMethod("sharedPrefs.set",
                    {"key": "token", "value": vm.user.token});
                sp["token"] = vm.user.token;
              } catch (e) {
                print("e e" + e);
              }
              // navigate to dashbboard
              Navigator.pushReplacementNamed(
                  context, '/dashboard');
            }
          }
        },
        builder: (BuildContext context, _ViewModel vm) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/logo.jpg'),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 270),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(23),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                            child: Container(
                              color: Color(0xfff5f5f5),
                              child: TextFormField(
                                initialValue: sp["twitterHandle"],
                                onChanged: (value) async {
                                  if (value.endsWith(" ")) {
                                    value = value.trim();
                                  }
                                  value = value.toLowerCase();
                                  await platform.invokeMethod("sharedPrefs.set",
                                      {"key": "twitterHandle", "value": value});
                                  sp["twitterHandle"] = value;
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter twitter handle';
                                  }

                                  return null;
                                },
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'SFUIDisplay'),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Twitter Handle',
                                    prefixIcon: Icon(Icons.person_outline),
                                    labelStyle: TextStyle(fontSize: 15)),
                              ),
                            ),
                          ),
                          Container(
                            color: Color(0xfff5f5f5),
                            child: TextFormField(
                              initialValue: sp["password"],
                              onChanged: (value) async {
                                if (value.endsWith(" ")) {
                                  value = value.trim();
                                }
                                await platform.invokeMethod("sharedPrefs.set",
                                    {"key": "password", "value": value});
                                sp["password"] = value;
                              },
                              obscureText: true,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter password';
                                }

                                return null;
                              },
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'SFUIDisplay'),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  labelStyle: TextStyle(fontSize: 15)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: MaterialButton(
                              onPressed: () async {
                                if (vm.user.loading != null &&
                                    vm.user.loading) {
                                  return;
                                }
                                if (_formKey.currentState.validate()) {
                                  var twitterHandle = sp["twitterHandle"];
                                  var password = sp["password"];
                                  _showLoadingDialog(context);
                                  vm.fetch(twitterHandle, password);
                                }
                              },
                              //since this is only a UI app
                              child: Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'SFUIDisplay',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Color(0xffff2d55),
                              elevation: 0,
                              minWidth: 400,
                              height: 50,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  // user defined function
  void _showLoadingDialog(context) {
    // flutter defined function
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        // return object of type Dialog
        return SpinKitWave(
            color: Colors.greenAccent, duration: Duration(milliseconds: 4000));
      },
    );
  }

  // user defined function
  void _showDialog(context, title, contentText) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        // return object of type Dialog
        return new AlertDialog(
          title: new Text(title),
          content: new Text(contentText),
        );
      },
    );
  }
}

typedef void MyCallback(String handle, String password);

class _ViewModel {
  final MyCallback fetch;
  final User user;

  _ViewModel({@required this.fetch, @required this.user});

  static _ViewModel fromStore(Store<RootState> store) {
    return _ViewModel(
        fetch: (String twitterHandle, String password) async {
          store.dispatch(fetchUser(twitterHandle, password));
        },
        user: store.state.user);
  }
}
