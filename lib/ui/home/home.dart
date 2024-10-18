// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskify/theme/theme_colors.dart';
import 'package:taskify/ui/project_ui/choose_members.dart';
import 'package:taskify/ui/project_ui/create_project.dart';
import 'package:taskify/widgets/custom_widget.dart';
import 'package:taskify/widgets/widget_home.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 15,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder(
                  stream: _database.ref('users/${_auth.currentUser!.uid}').onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return Container();
                    } else {
                      Map<dynamic, dynamic> userData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                      return Row(
                        children: [
                          userData['photoUrl'] != null && userData['photoUrl'].isNotEmpty
                              ? CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(userData['photoUrl']),
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.person, color: Colors.white, size: 30),
                                ),
                          SizedBox(width: 10),
                          Text(
                            'Hello, ${userData['name']}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 25),
            // Body layout
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Blue top card
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 20),
                          StreamBuilder(
                            stream: _database
                                .ref('users/${_auth.currentUser!.uid}/projects')
                                .orderByChild('finished')
                                .equalTo(false)
                                .onValue,
                            builder: ((context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                                return Container();
                              } else {
                                Map<dynamic, dynamic> projects = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                                return projects.length > 1
                                    ? Text(
                                        '${projects.length} projects',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : projects.isEmpty
                                        ? Text(
                                            'You have no projects',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : Text(
                                            '${projects.length} project',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    // In progress section
                    Row(
                      children: [
                        Text(
                          'In progress',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          height: 25,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: StreamBuilder(
                            stream: _database
                                .ref('users/${_auth.currentUser!.uid}/projects')
                                .orderByChild('finished')
                                .equalTo(false)
                                .onValue,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                                return Container();
                              } else {
                                Map<dynamic, dynamic> projects = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                                return Center(
                                  child: Text(
                                    projects.length.toString(),
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    // In progress Stream builder
                    SizedBox(
                      height: 140,
                      child: StreamBuilder(
                        stream: _database
                            .ref('users/${_auth.currentUser!.uid}/projects')
                            .orderByChild('finished')
                            .equalTo(false)
                            .onValue,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                            return Container();
                          } else {
                            Map<dynamic, dynamic> projects = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                            return ListView.builder(
                              itemCount: projects.length,
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: ((context, index) {
                                var project = projects.values.elementAt(index);
                                var time = DateFormat('d MMM y').format(DateTime.parse(project['createDate']));
                                return CustomContainer(
                                  description: project['description'],
                                  title: project['name'],
                                  createDate: time,
                                );
                              }),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    // Finished projects section
                    Row(
                      children: [
                        Text(
                          'Finished projects',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        StreamBuilder(
                          stream: _database
                              .ref('users/${_auth.currentUser!.uid}/projects')
                              .orderByChild('finished')
                              .equalTo(true)
                              .onValue,
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                              return Container();
                            } else {
                              Map<dynamic, dynamic> finishedProjects = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                              return Container(
                                height: 25,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    finishedProjects.length.toString(),
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                    // Finished projects ListView
                    StreamBuilder(
                      stream: _database
                          .ref('users/${_auth.currentUser!.uid}/projects')
                          .orderByChild('finished')
                          .equalTo(true)
                          .onValue,
                      builder: ((context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                          return Container();
                        } else {
                          Map<dynamic, dynamic> finishedProjects = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                          return ListView.builder(
                            itemCount: finishedProjects.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: ((context, index) {
                              var project = finishedProjects.values.elementAt(index);
                              var time = DateFormat('d MMM y').format(DateTime.parse(project['createDate']));
                              return WidgetHome(
                                description: project['description'],
                                progress_percentage: '100',
                                createDate: time,
                                title: project['name'],
                              );
                            }),
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // New project floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) {
                return ChooseMembers();
              }),
            ),
          );
        },
        backgroundColor: Colors.blue,
        label: Text(
          'New project',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
