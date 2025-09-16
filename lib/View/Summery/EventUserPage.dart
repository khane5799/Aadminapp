import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:flutter/material.dart';

class EventUsersPage extends StatelessWidget {
  final String eventName;
  const EventUsersPage({super.key, required this.eventName});

  // Dummy user list
  final List<String> users = const [
    "Ali Khan",
    "Sara Ahmed",
    "John Doe",
    "Maryam Fatima",
    "Usman Tariq",
    "Hina Malik"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: "👥 Attendees - $eventName",
        ActiononTap: () {},
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: secondaryColor,
                child: Text(users[index][0]),
              ),
              title: Text(users[index]),
            ),
          );
        },
      ),
    );
  }
}
