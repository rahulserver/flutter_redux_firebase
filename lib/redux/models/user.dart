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
  bool active;
  bool loading;

  User(
      {this.password,
      this.twitterhandle,
      this.email,
      this.active,
      this.loading = false});

  factory User.initial() {
    return User(
        password: null,
        twitterhandle: null,
        email: null,
        active: false,
        loading: false);
  }

  User copyWith(User user) {
    if (user == null) {
      return User.initial();
    }

    return new User(
        twitterhandle: user.twitterhandle ?? this.twitterhandle,
        email: user.email ?? this.email,
        active: user.active ?? this.active,
        loading: user.loading ?? this.loading);
  }
}
