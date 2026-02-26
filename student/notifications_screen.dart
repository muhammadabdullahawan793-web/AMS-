import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("New assignment uploaded"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Assignment due tomorrow"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Check your pending tasks"),
          ),
        ],
      ),
    );
  }
}
