import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_firebase/redux/middleware/user_thunk.dart';
import 'package:flutter_redux_firebase/redux/models/root_state.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:redux/redux.dart';

const platform =
    const MethodChannel('com.example.flutter_redux_firebase/foreground');

class Dashboard extends StatelessWidget {
  static final _formKey = GlobalKey<FormState>();
  var sp;

  Dashboard(this.sp);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<RootState, _ViewModel>(
        converter: (Store<RootState> store) => _ViewModel.fromStore(store),
        onWillChange: (_ViewModel vm) {
          if (!vm.user.loading) {
            // dismiss the loading indicator
            Navigator.of(context).pop();
//          if (vm.user.error != null) {
//            _showDialog(context, "Error", "Error occurred: " + vm.user.error);
//            return;
//          }
//
//          if (!vm.user.exists) {
//            _showDialog(context, "Error",
//                "This handle is not authorized to use this app");
//            return;
//          }
//
//          if (vm.user.active) {
//            Navigator.pushNamedAndRemoveUntil(
//                context, '/dashboard', (Route<dynamic> route) => false);
//          }
          }
        },
        builder: (BuildContext context, _ViewModel vm) {
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/image2.png'),
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
                                onChanged: (value) async {
                                  if (value.endsWith(" ")) {
                                    value = value.trim();
                                  }
                                  await platform.invokeMethod("sharedPrefs.set",
                                      {"key": "minSec", "value": value});
                                  sp["minSec"] = value;
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
                            if (_formKey.currentState.validate()) {
                              var file = await FilePicker.getFile(
                                  type: FileType.CUSTOM, fileExtension: 'xls');
                              await platform.invokeMethod("sharedPrefs.set",
                                  {"key": "excelFile", "value": file.path});
                            }
                          },
                          child: Text(
                            'START TWEETING',
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
                    ],
                  ),
                ),
              ),
            ),
          );
        });

    // TODO: implement build
//    return Scaffold(
//      appBar: AppBar(title: Text('Dashboard')),
//      body: Center(
//        child: Padding(
//          padding: EdgeInsets.only(top: 20),
//          child: MaterialButton(
//            onPressed: () {
//              Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
//            },
//            //since this is only a UI app
//            child: Text(
//              'SIGN OUT',
//              style: TextStyle(
//                fontSize: 15,
//                fontFamily: 'SFUIDisplay',
//                fontWeight: FontWeight.bold,
//              ),
//            ),
//            color: Color(0xffff2d55),
//            elevation: 0,
//            minWidth: 400,
//            height: 50,
//            textColor: Colors.white,
//            shape:
//            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//          ),
//        ),
//      ),
//    );
  }
}

bool isInteger(int value) => value is int || value == value.roundToDouble();

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
