import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_firebase/redux/middleware/user_thunk.dart';
import 'package:flutter_redux_firebase/redux/models/root_state.dart';
import 'package:flutter_redux_firebase/redux/models/user.dart';
import 'package:redux/redux.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Signin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<RootState, _ViewModel>(
        converter: (Store<RootState> store) => _ViewModel.fromStore(store),
        builder: (BuildContext context, _ViewModel vm) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/image1.png'),
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
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Container(
                            color: Color(0xfff5f5f5),
                            child: TextFormField(
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
                            obscureText: true,
                            style: TextStyle(
                                color: Colors.black, fontFamily: 'SFUIDisplay'),
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
                            onPressed: () {
                              _showDialog(context);
                              vm.fetch();
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            //since this is only a UI app
                            child: Text(
                              'SIGN IN ${vm.user.loading}',
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
                )
              ],
            ),
          );
        });
  }

  // user defined function
  void _showDialog(context) {
    // flutter defined function
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert Dialog title"),
          content: new Text("Alert Dialog body"),

          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {

              },
            ),
          ],
        );
      },
    );
  }
}

class _ViewModel {
  final VoidCallback fetch;
  final User user;

  _ViewModel({@required this.fetch, @required this.user});

  static _ViewModel fromStore(Store<RootState> store) {
    return _ViewModel(
        fetch: () {
          store.dispatch(fetchUser());
        },
        user: store.state.user);
  }
}
