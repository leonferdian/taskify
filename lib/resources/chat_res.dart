import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatRes {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> sendMessage(String message, String projectIndex) async {
    String res = 'Some error occurred';
    try {
      DatabaseReference messagesRef = _database
          .ref()
          .child('users')
          .child(_auth.currentUser!.uid)
          .child('projects')
          .child(projectIndex)
          .child('messages');

      await messagesRef.push().set({
        'message': message,
        'type': 'text',
        'time': DateTime.now().toIso8601String(), // Store date as a string in ISO format
        'senderId': _auth.currentUser!.uid,
      });

      res = 'success';
    } catch (error) {
      res = error.toString();
    }
    return res;
  }

  Future deleteMessage(String projectIndex, String messageKey) async {
    try {
      DatabaseReference messageRef = _database
          .ref()
          .child('users')
          .child(_auth.currentUser!.uid)
          .child('projects')
          .child(projectIndex)
          .child('messages')
          .child(messageKey);

      await messageRef.remove();
    } catch (error) {
      print(error);
    }
  }
}
