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
  bool tweeting;

  User(
      {this.password,
      this.twitterhandle,
      this.email,
      this.error,
      this.active,
      this.loading = null,
      this.exists = null,
      this.tweeting = null,
      this.minSec = null,
      this.maxSec = null,
      this.token = null,
      this.excelFile = null});

  factory User.initial() {
    return User(
        password: null,
        twitterhandle: null,
        email: null,
        error: null,
        active: null,
        loading: null,
        exists: null,
        tweeting: null,
        token: null,
        minSec: null,
        maxSec: null,
        excelFile: null);
  }

  User copyWith(User user) {
    if (user == null) {
      return User.initial();
    }

    return new User(
        twitterhandle: user.twitterhandle ?? this.twitterhandle,
        password: user.password ?? this.password,
        email: user.email ?? this.email,
        error: user.error,
        active: user.active ?? this.active,
        loading: user.loading ?? this.loading,
        tweeting: user.tweeting ?? this.tweeting,
        exists: user.exists ?? this.exists,
        minSec: user.minSec ?? this.minSec,
        maxSec: user.maxSec ?? this.maxSec,
        token: user.token ?? this.token,
        excelFile: user.excelFile ?? this.excelFile);
  }
}
