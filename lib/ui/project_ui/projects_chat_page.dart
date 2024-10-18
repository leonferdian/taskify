// ignore_for_file: prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:taskify/theme/theme_colors.dart';
import 'package:taskify/widgets/bottom_container_chat.dart';
import 'package:taskify/widgets/custom_button.dart';

import '../../widgets/message_design.dart';

class ProjectsChatPage extends StatefulWidget {
  final String projectName;
  final String projectId;
  final String projectLogo;
  final String createDate;

  const ProjectsChatPage({
    super.key,
    required this.projectName,
    required this.projectId,
    required this.projectLogo,
    required this.createDate,
  });

  @override
  State<ProjectsChatPage> createState() => _ProjectsChatPageState();
}

class _ProjectsChatPageState extends State<ProjectsChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors().grey,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: ThemeColors().blue,
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.projectLogo),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(widget.projectName),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/icons/settings.svg'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 40,
                          width: 200,
                          decoration: BoxDecoration(
                            color: ThemeColors().purpleAccent.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.projectName} was created',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.createDate,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 10),
                  StreamBuilder(
                    stream: _database
                        .reference()
                        .child('projects')
                        .child(widget.projectId)
                        .child('chats')
                        .onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                        final messagesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                        final messagesList = messagesMap.entries.toList();

                        return ListView.builder(
                          reverse: true,
                          itemCount: messagesList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var messageData = messagesList[index].value;

                            // Safely accessing fields
                            String? dateTimeString = messageData['date'] as String?;
                            String? senderId = messageData['senderId'] as String?;
                            String? messageText = messageData['message'] as String?;

                            // Handle potential nulls for date and message
                            if (dateTimeString == null || messageText == null || senderId == null) {
                              return Container(); // Skip this message if any crucial field is null
                            }

                            var a = DateTime.parse(dateTimeString);
                            var time = DateFormat('HH:mm').format(a);
                            bool isMe = senderId == _auth.currentUser?.uid;

                            return MessageDesign(
                              isMe: isMe,
                              message: messageText,
                              time: time,
                              senderId: senderId,
                              projectId: widget.projectId,
                              messageIndex: messagesList[index].key, // Get the key for the message
                            );
                          },
                        );
                      } else {
                        return Container(); // Handle the loading or empty state
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Bottom Container
          BottomContainerChat(
            projectId: widget.projectId,
          ),
        ],
      ),
    );
  }
}
