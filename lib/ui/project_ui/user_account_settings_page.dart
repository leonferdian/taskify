import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskify/theme/theme_colors.dart';

class UserAccountSettingsPage extends StatefulWidget {
  const UserAccountSettingsPage({super.key});

  @override
  State<UserAccountSettingsPage> createState() =>
      _UserAccountSettingsPageState();
}

class _UserAccountSettingsPageState extends State<UserAccountSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // TextEditingControllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  bool isLoading = true;
  bool isUpdating = false; // To track if the app is updating the user data
  File? _imageFile; // Selected image file for upload

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      DatabaseReference userRef = _database.ref().child('users').child(userId);
      userRef.once().then((snapshot) {
        if (snapshot.snapshot.exists) {
          final userData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _surnameController.text = userData['surname'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _photoUrlController.text = userData['photoUrl'] ?? '';
            isLoading = false;
          });
        }
      });
    }
  }

  Future<void> updateUserData() async {
    setState(() {
      isUpdating = true; // Start updating
    });

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      DatabaseReference userRef = _database.ref().child('users').child(userId);

      try {
        String photoUrl = _photoUrlController.text.trim();

        // Upload image if a new file is selected
        if (_imageFile != null) {
          final ref = _storage.ref().child('user_photos/$userId');
          await ref.putFile(_imageFile!);
          photoUrl = await ref.getDownloadURL();
        }

        await userRef.update({
          'name': _nameController.text.trim(),
          'surname': _surnameController.text.trim(),
          'email': _emailController.text.trim(),
          'photoUrl': photoUrl,
        });

        await _auth.currentUser?.updateEmail(_emailController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print('Error updating user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        setState(() {
          isUpdating = false; // End updating
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        actions: [
          isUpdating ? 
          Container(
            margin: EdgeInsets.only(top: 16, right: 16), // Adjust the margin as needed
            alignment: Alignment.topLeft, // Position at the top right corner
            child: SizedBox(
              width: 20, // Set desired width
              height: 20, // Set desired height
              child: CircularProgressIndicator(),
            ),
          )
          :
          // Add update button in the AppBar actions
          TextButton.icon(
            onPressed: updateUserData,
            icon: Icon(Icons.check, color: ThemeColors().purpleAccent), // Checklist icon
            label: Text(
              '',
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // Show selected image or default placeholder
                  Center(
                    child: _imageFile != null
                        ? ClipOval(
                            child: Image.file(
                              _imageFile!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_photoUrlController.text.isNotEmpty
                            ? CircleAvatar(
                                radius: 100,
                                backgroundImage:
                                    NetworkImage(_photoUrlController.text),
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, size: 50, color: Colors.white),
                              )),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Square shape (no rounded corners)
                        ),
                      ),
                      child: Text('Change Photo'),
                    ),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _surnameController,
                    decoration: InputDecoration(labelText: 'Surname'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _photoUrlController,
                    decoration: InputDecoration(labelText: 'Photo URL'),
                  ),
                  // SizedBox(height: 20),

                  // // Show loader during the update process
                  // isUpdating
                  //     ? Center(child: CircularProgressIndicator())
                  //     : ElevatedButton(
                  //         onPressed: updateUserData,
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: ThemeColors().purpleAccent, // Set the button's background color
                  //           foregroundColor: Colors.white,
                  //         ),
                  //         child: Text('Update Info'),
                  //       ),
                ],
              ),
            ),
    );
  }

}
