import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class StorageRes {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //Uploading the Image to FirebaseStorage.
  Future<String> uploadImageToStorage(Uint8List imageFile) async {
    try {
      // creating location in firebase storage
      final String imageName = const Uuid().v1();

      // Create reference to the image path in Firebase Storage
      Reference ref = _firebaseStorage.ref().child('projects_logos').child(imageName);

      // Start the upload task
      UploadTask uploadTask = ref.putData(imageFile);

      // Await the completion of the task
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL for the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Log the successful upload
      print('Image uploaded successfully. URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      // Log the error for debugging
      print('Error uploading image: ${e.toString()}');

      // Re-throw the error to be handled by the caller
      throw Exception('Error uploading image: ${e.toString()}');
    }
  }
}

