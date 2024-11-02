import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: userId == null
          ? Center(child: Text('No user logged in'))
          : StreamBuilder(
              stream: _database.ref('users/$userId/projects').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data?.snapshot.value == null) {
                  return Center(child: Text('No notifications'));
                }

                final projects =
                    (snapshot.data!.snapshot.value as Map).values.toList();
                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index] as Map;
                    return ListTile(
                      title: Text(project['name'] ?? 'Project'),
                      subtitle: Text(project['description'] ?? ''),
                      trailing: project['isNew'] == true
                          ? Icon(Icons.circle, color: Colors.red, size: 10)
                          : null,
                    );
                  },
                );
              },
            ),
    );
  }
}
