import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  List<Map<String, dynamic>> activeEvents = [];
  List<Map<String, dynamic>> upcomingEvents = [];
  List<Map<String, dynamic>> expiredEvents = [];

  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  EventProvider() {
    fetchEvents();
  }

  Future<void> addEvent(Map<String, dynamic> event) async {
    // Save to Firestore
    await eventsCollection.add({
      "name": event["name"],
      "day": event["day"],
      "date": event["date"],
      "startTime": event["startTime"],
      "endTime": event["endTime"],
    });

    await fetchEvents();
  }

  Future<void> fetchEvents() async {
    final snapshot = await eventsCollection.get();
    activeEvents = [];
    upcomingEvents = [];
    expiredEvents = [];

    final today = DateTime.now();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final DateTime eventDate = (data["date"] as Timestamp).toDate();

      if (isSameDate(eventDate, today)) {
        activeEvents.add({
          ...data,
          "status": "active",
        });
      } else if (eventDate.isAfter(today)) {
        upcomingEvents.add({
          ...data,
          "status": "upcoming",
        });
      } else {
        expiredEvents.add({
          ...data,
          "status": "expired",
        });
      }
    }

    notifyListeners();
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
