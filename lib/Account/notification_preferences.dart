import 'package:flutter/material.dart';

class NotificationPreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification")),
      body: Center(
          child: Text("Your notification preferences will appear here.")),
    );
  }
}
