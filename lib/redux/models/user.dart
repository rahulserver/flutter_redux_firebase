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
  String twitterhandle; // the twitter handle which is the key in firestore
  String email;
  bool active;

  User({
    this.twitterhandle,
    this.email,
    this.active
  });

  factory User.initial() {
    return User(
      twitterhandle: null,
      email: null,
      active: false
    );
  }
}