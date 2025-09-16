import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/View/Summery/EventUserPage.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  String query = "";
  List<Map<String, dynamic>> eventsWithAttendees = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection("events") // exact collection name
        .orderBy("date", descending: true)
        .get();

    List<Map<String, dynamic>> tempEvents = [];

    for (var eventDoc in eventsSnapshot.docs) {
      final eventId = eventDoc.id;

      // Count attendees for this event (filtered by eventId)
      final attendeesSnapshot = await FirebaseFirestore.instance
          .collection("attendance")
          .where("eventId", isEqualTo: eventId)
          .get();

      // If no attendees, docs.length will be 0
      tempEvents.add({
        "uid": eventId,
        "name": eventDoc["name"],
        "attendees": attendeesSnapshot.docs.length,
      });
    }

    setState(() {
      eventsWithAttendees = tempEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = eventsWithAttendees
        .where((event) =>
            event["name"].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: "📅  Events",
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search events...",
                  prefixIcon: Icon(Icons.search, color: primerycolor),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                onChanged: (val) => setState(() => query = val),
              ),
            ),
          ),

          // 📋 Event List
          Expanded(
            child: eventsWithAttendees.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primerycolor.withOpacity(0.8),
                            child: const Icon(Icons.event, color: Colors.white),
                          ),
                          title: Text(
                            event["name"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text("Attendees: ${event["attendees"]}"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventUsersPage(eventName: event["name"]),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
