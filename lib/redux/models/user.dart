// should contain the model representation of data that comes from firebase
// it can contain a representation of a single document or a group of documents
// depending on what is being fetched
// For my case, the firestore collection "User" that this model represents
// stores data in the format:
// { twitterhandle: {
//        authorized: true,
//        email: "someemail@somedomain.com"
// }}
class User {
  String password;
  String twitterhandle; // the twitter handle which is the key in firestore
  String email;
  String error;
  String minSec;
  String maxSec;
  String excelFile;
  String token;
  bool active;
  bool loading;
  bool exists;

  User(
      {this.password,
      this.twitterhandle,
      this.email,
      this.error,
      this.active,
      this.loading = false,
      this.exists = false,
      this.minSec = "60",
      this.maxSec = "180",
      this.token = null,
      this.excelFile = null});

  factory User.initial() {
    return User(
        password: null,
        twitterhandle: null,
        email: null,
        error: null,
        active: false,
        loading: false,
        exists: false,
        token: null,
        minSec: "60",
        maxSec: "180",
        excelFile: null);
  }

  User copyWith(User user) {
    if (user == null) {
      return User.initial();
    }

    return new User(
        twitterhandle: user.twitterhandle ?? this.twitterhandle,
        email: user.email ?? this.email,
        error: user.error,
        active: user.active ?? this.active,
        loading: user.loading ?? this.loading,
        exists: user.exists ?? this.exists,
        minSec: user.minSec ?? this.minSec,
        maxSec: user.maxSec ?? this.maxSec,
        token: user.token ?? this.token,
        excelFile: user.excelFile ?? this.excelFile);
  }
}
