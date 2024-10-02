// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRes {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<String> createAccount(
    String name,
    String surname,
    String email,
    String photoUrl,
    String password,
  ) async {
    String res = 'Some error occurred';

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        // Create the user with email and password in Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save the user data to Firebase Realtime Database
        DatabaseReference userRef = _database
            .ref()
            .child('users')
            .child(userCredential.user!.uid);  // Correct reference to the database

        await userRef.set({
          'name': name,
          'surname': surname,
          'email': email,
          'photoUrl': photoUrl,
          'uid': userCredential.user!.uid,
        });

        res = 'success';
      } catch (error) {
        print('Error during account creation: $error');
        res = 'Failed to create account!';
      }
    } else {
      res = 'Fill in all the fields';
    }

    return res;
  }

  Future<String> login(
    String email,
    String password,
  ) async {
    String res = 'Some error occured';
    if (email.isEmpty) {
      res = 'Enter your email';
    } else if (password.isEmpty) {
      res = 'Enter password';
    } else if (!email.contains('@')) {
      res = 'Email is invalid';
    } else {
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } catch (error) {
        print('Error log: $error');
        res = 'Error while trying to login';
      }
    }
    return res;
  }

  Future<String> resetPassword(String email) async {
    String res = 'Some error occured';
    if (email.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        res = 'success';
      } catch (error) {
        res = 'User not found';
      }
    } else {
      res = 'enter email';
    }
    return res;
  }
}
