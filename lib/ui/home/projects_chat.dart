// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:taskify/theme/theme_colors.dart';
import 'package:taskify/ui/project_ui/projects_chat_page.dart';
import 'package:taskify/widgets/list_tile.dart';

class ProjectsChat extends StatefulWidget {
  const ProjectsChat({super.key});

  @override
  State<ProjectsChat> createState() => _ProjectsChatState();
}

class _ProjectsChatState extends State<ProjectsChat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 15,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header title section.
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discussions',
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
            ),

            // New messages section.
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Projects Section.
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, bottom: 15, top: 10),
                      child: Row(
                        children: [
                          Text(
                            'Projects',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 25,
                            width: 30,
                            decoration: BoxDecoration(
                              color: ThemeColors().grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: StreamBuilder(
                              stream: _database.ref('projects').onValue,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: Text(
                                      '0',
                                      style: TextStyle(
                                        color: ThemeColors().pink,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasData &&
                                    snapshot.data!.snapshot.value != null) {
                                  // Cast the value to Map<dynamic, dynamic>
                                  Map<dynamic, dynamic> projectData =
                                      (snapshot.data!.snapshot.value
                                          as Map<dynamic, dynamic>);
                                  return Center(
                                    child: Text(
                                      projectData.length.toString(),
                                      style: TextStyle(
                                        color: ThemeColors().pink,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: Text(
                                      '0',
                                      style: TextStyle(
                                        color: ThemeColors().pink,
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
                    ),

                    // Projects List
                    StreamBuilder(
                      stream: _database.ref('projects').onValue,
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasData &&
                            snapshot.data!.snapshot.value != null) {
                          // Cast the value to Map<dynamic, dynamic>
                          Map<dynamic, dynamic> projects = (snapshot
                              .data!.snapshot.value as Map<dynamic, dynamic>);

                          return ListView.builder(
                            itemCount: projects.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: ((context, index) {
                              // Convert map to list and access project by index
                              var project = projects.values.elementAt(index);
                              var description = project['description'];
                              var a = DateTime.parse(project['createDate']);
                              var time = DateFormat('d MMM y').format(a);

                              return ListTileWidget(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectsChatPage(
                                        projectName: project['name'],
                                        projectId: project['projectId'],
                                        projectLogo: project['logoUrl'],
                                        createDate: time,
                                      ),
                                    ),
                                  );
                                },
                                appLogoUrl: project['logoUrl'],
                                lastMessage: description,
                                title: project['name'],
                              );
                            }),
                          );
                        } else {
                          return Container();
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
    );
  }
}
