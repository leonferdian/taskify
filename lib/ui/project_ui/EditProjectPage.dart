// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:typed_data';
import 'dart:math';
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
import '../../utils/pick_image.dart';

class EditProjectPage extends StatefulWidget {
  final String projectId;
  final String initialName;
  final String initialDescription;
  final String initialLogoUrl;

  const EditProjectPage({
    Key? key,
    required this.projectId,
    required this.initialName,
    required this.initialDescription,
    required this.initialLogoUrl,
  }) : super(key: key);

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Uint8List? _image;
  String? _logoUrl;
  final CustomLoader _loader = CustomLoader();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _descriptionController.text = widget.initialDescription;
    _logoUrl = widget.initialLogoUrl;
  }

  Future<void> pickImage() async {
    Uint8List? im = await getPickedImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  Future<void> updateProject() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();

    try {
      _loader.showLoader(context);

      // Upload new image if picked
      if (_image != null) {
        _logoUrl = await StorageRes().uploadImageToStorage(_image!);
      }

      // Update project data in Realtime Database
      await _database.ref('projects/${widget.projectId}').update({
        'name': name,
        'description': description,
        'logoUrl': _logoUrl,
      });

      Fluttertoast.showToast(
        msg: "Project updated",
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Error updating project: ${error.toString()}",
        backgroundColor: Colors.red,
      );
    } finally {
      _loader.hideLoader();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Project')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: _image != null
                    ? Image.memory(_image!,
                        height: 150, width: 150, fit: BoxFit.cover)
                    : Image.network(_logoUrl!,
                        height: 150, width: 150, fit: BoxFit.cover),
              ),
            ),
            TextFieldWidget(
              controller: _nameController,
              hintText: 'Project name',
              prefixIcon: SvgPicture.asset('assets/icons/projects.svg',
                  fit: BoxFit.none),
            ),
            TextFieldWidget(
              controller: _descriptionController,
              hintText: 'Project description',
              prefixIcon:
                  SvgPicture.asset('assets/icons/edit.svg', fit: BoxFit.none),
            ),
            CustomButton(
              text: 'Save Changes',
              onTap: updateProject,
            ),
          ],
        ),
      ),
    );
  }
}
