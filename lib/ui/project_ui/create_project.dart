// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:math';
import 'dart:typed_data';

import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskify/resources/storage_res.dart';
import 'package:taskify/theme/theme_colors.dart';
import 'package:taskify/widgets/custom_button.dart';
import 'package:taskify/widgets/custom_loader.dart';
import 'package:taskify/widgets/text_field.dart';
import 'package:uuid/uuid.dart';

import '../../utils/pick_image.dart';

class PersonalProject extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const PersonalProject({
    super.key,
    required this.membersList,
  });

  @override
  State<PersonalProject> createState() => _PersonalProjectState();
}

class _PersonalProjectState extends State<PersonalProject> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase
      .instance; // Change here from Firestore to Realtime Database

  Uint8List? _image;
  final CustomLoader _loader = CustomLoader();

  @override
  void dispose() {
    _description.dispose();
    _name.dispose();
    super.dispose();
  }

  //Pick Image.
  pickImage() async {
    Uint8List? im = await getPickedImage(ImageSource.gallery);
    // set state because we need to display the image.
    setState(() {
      _image = im;
    });
  }

  final List _illustrations = [
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes01.png?alt=media&token=f41be213-b7f8-4d2a-afc1-f0ed57fc10f4',
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes02.png?alt=media&token=6f4e16c6-ea4f-44f2-819f-cb87071785a5',
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes03.png?alt=media&token=c24d97e4-8f6a-4783-9092-2af48da1331d',
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes04.png?alt=media&token=b9867775-6d4c-4bd5-af7c-4b425b99cea0',
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes05.png?alt=media&token=d2871f51-230b-4b65-a825-d8e0501d391f',
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes06.png?alt=media&token=ec81d45f-fa93-425f-ad9b-355e16290e09',
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes07.png?alt=media&token=90c7b6bb-5ace-451e-9bcc-b893466bd93d',
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes08.png?alt=media&token=004fa4b1-177d-428c-96bf-ccbd4309f560',
    'https://firebasestorage.googleapis.com/v0/b/webtaskify.appspot.com/o/illustrations%2FScenes09.png?alt=media&token=0cbe7df9-cb76-46ce-a7cd-226d4525c3b5',
  ];

  // Function for creating a new project using Realtime Database
  createNewProject() async {
    String projectId = Uuid().v1();
    String name = _name.text.trim();
    String description = _description.text.trim();
    var illustrationList =
        _illustrations[Random().nextInt(_illustrations.length)];

    try {
      // Check if the image is not null
      if (_image == null) {
        throw Exception('No image selected for upload.');
      }

      // Upload the image and get the URL
      String logoUrl = await StorageRes().uploadImageToStorage(_image!);
      print('Logo URL: $logoUrl');

      // Create project in the Realtime Database
      await _database.ref('projects/$projectId').set({
        'projectId': projectId,
        'members': widget.membersList,
        'name': name,
        'description': description,
        'createDate': DateTime.now().toIso8601String(),
        'finished': false,
        'logoUrl': logoUrl,
        'illustration': illustrationList,
        'admin': _auth.currentUser!.uid,
        'isNew': true, // New field for notifications
      });

      // Add project to all selected users in Realtime Database
      for (int i = 0; i < widget.membersList.length; i++) {
        String uid = widget.membersList[i]['uid'];
        await _database.ref('users/$uid/projects/$projectId').set({
          'name': name,
          'description': description,
          'createDate': DateTime.now().toIso8601String(),
          'finished': false,
          'logoUrl': logoUrl,
          'illustration': illustrationList,
          'admin': _auth.currentUser!.uid,
          'projectId': projectId,
        });

        // Send a welcome message to the project's chat collection
        await _database.ref('projects/$projectId/chats').push().set({
          'message': 'Project was created',
          'type': 'welcome',
        });
      }

      Fluttertoast.showToast(
        msg: "Project created",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      _loader.hideLoader();
      Navigator.pop(context);
    } catch (error) {
      // Log the error in detail
      // developer.log('Error creating project: ${error.toString()}');
      print('Error creating project: ${error.toString()}');

      // Show the error message in a toast
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      _loader.hideLoader();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'App logo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: _image != null
                      ? Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: ThemeColors().blue,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: MemoryImage(_image!),
                            ),
                          ),
                        )
                      : Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: ThemeColors().blue,
                          ),
                        ),
                ),
              ),
            ],
          ),
          TextFieldWidget(
            controller: _name,
            hintText: 'Project name',
            prefixIcon: SvgPicture.asset(
              'assets/icons/projects.svg',
              fit: BoxFit.none,
            ),
          ),
          TextFieldWidget(
            controller: _description,
            hintText: 'Project description',
            prefixIcon: SvgPicture.asset(
              'assets/icons/edit.svg',
              fit: BoxFit.none,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          CustomButton(
              text: 'Create project',
              onTap: () {
                if (_name.text.trim().toString().isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Enter project name",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (_description.text.trim().toString().isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Enter description",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (_image == null) {
                  Fluttertoast.showToast(
                      msg: "Pick project logo",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  _loader.showLoader(context);
                  createNewProject();
                }
              }),
        ],
      ),
    );
  }
}
