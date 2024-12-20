import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskify/theme/theme_colors.dart';
import 'package:taskify/widgets/text_field.dart';

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
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      DatabaseReference userRef = _database.ref().child('users').child(userId);
      userRef.once().then((snapshot) {
        if (snapshot.snapshot.exists) {
          final userData =
              Map<String, dynamic>.from(snapshot.snapshot.value as Map);
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
    final currentUser = _auth.currentUser;

    if (userId != null && currentUser != null) {
      DatabaseReference userRef = _database.ref().child('users').child(userId);

      try {
        // Step 1: Re-authenticate the user
        final email = _emailController.text.trim();
        final password =
            await _promptForPassword(); // Prompt user to input their password

        if (password == null) {
          setState(() {
            isUpdating = false; // End updating
          });
          return;
        }

        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await currentUser.reauthenticateWithCredential(credential);

        String photoUrl = _photoUrlController.text.trim();

        // Step 2: Upload image if a new file is selected
        if (_imageFile != null) {
          final ref = _storage.ref().child('user_photos/$userId');
          await ref.putFile(_imageFile!);
          photoUrl = await ref.getDownloadURL();
        }

        // Step 3: Update the user data in Firebase Realtime Database
        await userRef.update({
          'name': _nameController.text.trim(),
          'surname': _surnameController.text.trim(),
          'email': email,
          'photoUrl': photoUrl,
        });

        // Step 4: Update the user's email in Firebase Auth
        await currentUser.updateEmail(email);

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

  // Helper method to prompt user for password input
  Future<String?> _promptForPassword() async {
    String? password;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Re-authentication required'),
          content: TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Enter your password'),
            onChanged: (value) {
              password = value;
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
    return password;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
          isUpdating
              ? Container(
                  margin: EdgeInsets.only(
                      top: 16, right: 16), // Adjust the margin as needed
                  alignment:
                      Alignment.topLeft, // Position at the top right corner
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
                  icon: Icon(Icons.check,
                      color: ThemeColors().purpleAccent), // Checklist icon
                  label: Text(
                    '',
                    style: TextStyle(
                        color: Colors.white), // Set text color to white
                  ),
                ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
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
                              backgroundImage: NetworkImage(_photoUrlController.text),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, size: 50, color: Colors.white),
                            )),
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
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
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
