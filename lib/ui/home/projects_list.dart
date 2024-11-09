// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskify/theme/theme_colors.dart';
import 'package:taskify/ui/project_ui/EditProjectPage.dart';
import 'package:taskify/widgets/list_container.dart';

class ProjectsList extends StatefulWidget {
  const ProjectsList({super.key});

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database =
      FirebaseDatabase.instance; // Using Realtime Database
  final List<Color> _list = [
    ThemeColors().blue,
    ThemeColors().pink,
    ThemeColors().purple,
    ThemeColors().purpleAccent,
    ThemeColors().yellow,
  ];

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
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              //Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My projects',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/settings.svg',
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 25,
              ),
              //Body
              Expanded(
                child: StreamBuilder(
                  stream: _database
                      .ref('users/${_auth.currentUser!.uid}/projects')
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return Center(child: Text('No projects found.'));
                    } else {
                      Map<dynamic, dynamic> projects = snapshot
                          .data!.snapshot.value as Map<dynamic, dynamic>;
                      List<dynamic> projectList = projects.values.toList();

                      return ListView.builder(
                        itemCount: projectList.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: ((context, index) {
                          var colorsList =
                              _list[Random().nextInt(_list.length)];
                          var project = projectList[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProjectPage(
                                    projectId: project['projectId'],
                                    initialName: project['name'],
                                    initialDescription: project['description'],
                                    initialLogoUrl: project['logoUrl'],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ListContainer(
                                colorsList: colorsList,
                                illustration: project['illustration'],
                                description: project['description'],
                                title: project['name'],
                                logourl: project['logoUrl'],
                              ),
                            ),
                          );
                        }),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
