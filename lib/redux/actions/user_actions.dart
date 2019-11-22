import 'package:flutter_redux_firebase/redux/models/user.dart';

class SetUserAction {
  final User user;

  SetUserAction(this.user);
}

class SetUserLoadingAction {
  SetUserLoadingAction();
}

class UnSetUserLoadingAction {
  UnSetUserLoadingAction();
}

class SetUserMinSec {
  final String minSec;

  SetUserMinSec(this.minSec);
}

class SetUserMaxSec {
  final String maxSec;

  SetUserMaxSec(this.maxSec);
}

class SetUserExcelFile {
  final String excelFile;

  SetUserExcelFile(this.excelFile);
}
