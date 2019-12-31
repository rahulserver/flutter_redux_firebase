import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_firebase/redux/actions/user_actions.dart';
import 'package:flutter_redux_firebase/redux/middleware/user_thunk.dart';
import 'package:flutter_redux_firebase/redux/models/root_state.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:redux/redux.dart';

const platform =
    const MethodChannel('com.example.flutter_redux_firebase/foreground');

class Dashboard extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(debugLabel: '_Dash' );
  var sp;

  Dashboard(this.sp);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<RootState, _ViewModel>(
        converter: (Store<RootState> store) => _ViewModel.fromStore(store),
        onWillChange: (_ViewModel vm) {},
        builder: (BuildContext context, _ViewModel vm) {
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/screen.jpg'),
              fit: BoxFit.cover,
            )),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                ),
                child: Padding(
                  padding: EdgeInsets.all(23),
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 200,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: TextFormField(
                                initialValue: sp["minSec"],
                                onChanged: (value) async {
                                  if (value.endsWith(" ")) {
                                    value = value.trim();
                                  }
                                  await platform.invokeMethod("sharedPrefs.set",
                                      {"key": "minSec", "value": value});
                                  sp["minSec"] = value;
                                  vm.setMin(value);
                                },
                                validator: (value) {
                                  int intValue;
                                  try {
                                    intValue = int.parse(value);
                                  } catch (e) {
                                    return "Invalid number";
                                  }
                                  if (!isInteger(intValue)) {
                                    return "Enter a valid whole number";
                                  }

                                  return null;
                                },
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 0.0),
                                    ),
                                    labelText: 'Minimum Interval (Sec.)',
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: Colors.white)),
                              ),
                            ),
                            TextFormField(
                              initialValue: sp["maxSec"],
                              validator: (value) {
                                int intValue;
                                try {
                                  intValue = int.parse(value);
                                } catch (e) {
                                  return "Invalid number";
                                }
                                if (!isInteger(intValue)) {
                                  return "Enter a valid whole number";
                                }

                                return null;
                              },
                              onChanged: (value) async {
                                if (value.endsWith(" ")) {
                                  value = value.trim();
                                }
                                await platform.invokeMethod("sharedPrefs.set",
                                    {"key": "maxSec", "value": value});
                                sp["maxSec"] = value;
                                vm.setMax(value);
                              },
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 0.0),
                                  ),
                                  labelText: 'Maximum Interval (Sec.)',
                                  labelStyle: TextStyle(
                                      fontSize: 15, color: Colors.white)),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: MaterialButton(
                          onPressed: () async {
                            var filePath = await platform.invokeMethod("pick");
                            vm.setExcelFile(filePath);
                            sp["excelFile"] = filePath;
                            await platform.invokeMethod("sharedPrefs.set",
                                {"key": "excelFile", "value": filePath});
                          },
                          child: Text(
                            sp["excelFile"] ?? "CHOOSE FILE",
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'SFUIDisplay',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          color: Color(0xffff2d55),
                          elevation: 0,
                          minWidth: 350,
                          height: 60,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: MaterialButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (vm.user.excelFile == null || sp["excelFile"] == null) {
                                _showDialog(context, "Invalid",
                                    "You must select the tweet file(.xls)!");
                              } else {
                                // check if service is already not running
                                var running = await platform.invokeMethod(
                                    "sharedPrefs.get", {"key": "running"});
                                if (running == null ||
                                    running == "false" ||
                                    running == "") {
                                  vm.setMin(sp["minSec"]);
                                  vm.setMax(sp["maxSec"]);
                                  // start the tweeting foreground service
                                  await platform.invokeMethod("launch", {
                                    "minSec": sp["minSec"],
                                    "maxSec": sp["maxSec"],
                                    "excelFile": sp["excelFile"],
                                    "twitterHandle": sp["twitterHandle"],
                                    "password": sp["password"],
                                  });
                                  sp["running"] = 'true';
                                  vm.setUserTweeting();
                                  // log the time
                                  await platform.invokeMethod("logTime",
                                      {"twitterHandle": vm.user.twitterhandle});
                                } else {
                                  await platform.invokeMethod(
                                      "sharedPrefs.remove", {"key": "token"});
                                  await platform.invokeMethod(
                                      "sharedPrefs.remove",
                                      {"key": "excelFile"});
                                  await platform.invokeMethod("abort");

                                  sp["excelFile"] = null;
                                  sp["token"] = null;
                                  sp["running"] = 'false';
                                  vm.unSetUserTweeting();
                                  Navigator.pushReplacementNamed(
                                      context, "/signin");
                                }
                              }
                            }
                          },
                          child: Text(
                            (vm.user.tweeting != null && vm.user.tweeting)
                                ? "STOP"
                                : "START",
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'SFUIDisplay',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          color: Color(0xffff2d55),
                          elevation: 0,
                          minWidth: 35,
                          height: 60,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: MaterialButton(
                          onPressed: () async {
                            await platform.invokeMethod(
                                "sharedPrefs.remove", {"key": "token"});
                            await platform.invokeMethod(
                                "sharedPrefs.remove", {"key": "excelFile"});
                            await platform.invokeMethod("abort");

                            sp["excelFile"] = null;
                            sp["token"] = null;
                            sp["running"] = 'false';
                            vm.unSetUserTweeting();
                            // navigate to dashbboard
                            Navigator.pushReplacementNamed(context, '/signin');
                          },
                          child: Text(
                            "LOGOUT",
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'SFUIDisplay',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          color: Color(0xffff2d55),
                          elevation: 0,
                          minWidth: 35,
                          height: 60,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

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

bool isInteger(int value) => value is int || value == value.roundToDouble();

typedef void MyCallback(String excelFile);
typedef void StringCallback(String val);

class _ViewModel {
  final MyCallback setExcelFile;
  final User user;
  final StringCallback setMin;
  final StringCallback setMax;
  final VoidCallback setUserTweeting;
  final VoidCallback unSetUserTweeting;

  _ViewModel(
      {@required this.setExcelFile,
      @required this.setUserTweeting,
      @required this.unSetUserTweeting,
      @required this.user,
      @required this.setMin,
      @required this.setMax});

  static _ViewModel fromStore(Store<RootState> store) {
    return _ViewModel(
        setExcelFile: (String excelFile) async {
          store.dispatch(SetUserExcelFile(excelFile));
        },
        setUserTweeting: () async {
          store.dispatch(SetUserTweetingAction());
        },
        unSetUserTweeting: () async {
          store.dispatch(UnSetUserTweetingAction());
        },
        setMin: (String min) async {
          store.dispatch(SetUserMinSec(min));
        },
        setMax: (String max) async {
          store.dispatch(SetUserMaxSec(max));
        },
        user: store.state.user);
  }
}
