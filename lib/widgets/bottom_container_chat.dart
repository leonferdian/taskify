// ignore_for_file: prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomContainerChat extends StatefulWidget {
  final String projectId;

  const BottomContainerChat({
    super.key,
    required this.projectId,
  });

  @override
  State<BottomContainerChat> createState() => _BottomContainerChatState();
}

class _BottomContainerChatState extends State<BottomContainerChat> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance; // Change here

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  sendMessage() async {
    String message = _controller.text;
    if (message.isNotEmpty) {
      // Create a reference to the chats under the projectId
      final messageRef = _database
          .reference()
          .child('projects')
          .child(widget.projectId)
          .child('chats')
          .push(); // Using push() to create a unique key for the new message

      // Set the message data
      await messageRef.set({
        'senderId': _auth.currentUser!.uid,
        'message': message,
        'type': 'text',
        'date': DateTime.now().toString(), // Convert DateTime to String for storage
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 100, minHeight: 50),
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/icons/emoji.svg'),
          ),
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              sendMessage();
              _controller.clear();
            },
            icon: SvgPicture.asset(
              'assets/icons/send.svg',
            ),
          ),
        ],
      ),
    );
  }
}
