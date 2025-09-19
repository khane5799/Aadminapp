import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EventUsersPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  const EventUsersPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<EventUsersPage> createState() => _EventUsersPageState();
}

class _EventUsersPageState extends State<EventUsersPage> {
  List<Map<String, dynamic>> attendees = [];
  List<Map<String, dynamic>> filteredAttendees = [];
  bool isLoading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    fetchAttendees();
  }

  Future<void> fetchAttendees() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final attendanceSnap = await firestore
          .collection("events")
          .doc(widget.eventId)
          .collection("attendance")
          .get();

      List<Map<String, dynamic>> tempAttendees = [];

      for (var doc in attendanceSnap.docs) {
        final uniqueID = doc["uniqueID"];

        if (uniqueID != null) {
          final memberSnap =
              await firestore.collection("Members").doc(uniqueID).get();

          if (memberSnap.exists) {
            final memberData = memberSnap.data()!;
            tempAttendees.add({
              "name": memberData["name"] ?? "Unknown",
              "membershipNumber": memberData["membershipNumber"] ?? "N/A",
              "photoUrl": memberData["photoUrl"],
            });
          }
        }
      }

      setState(() {
        attendees = tempAttendees;
        filteredAttendees = tempAttendees;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching attendees: $e");
      setState(() => isLoading = false);
    }
  }

  void updateSearch(String value) {
    setState(() {
      query = value.toLowerCase();
      filteredAttendees = attendees.where((attendee) {
        final name = (attendee["name"] ?? "").toLowerCase();
        final membershipNo = (attendee["membershipNumber"] ?? "").toLowerCase();
        return name.contains(query) || membershipNo.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: "Attendees • ${widget.eventName}",
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: fetchAttendees,
        child: Column(
          children: [
            // 🔍 Search bar
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
                  onChanged: updateSearch,
                  decoration: InputDecoration(
                    hintText: "Search attendees...",
                    prefixIcon: Icon(Icons.search, color: primerycolor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // 👥 Attendee list
            Expanded(
              child: isLoading
                  ? attendeeShimmer()
                  : filteredAttendees.isEmpty
                      ? const Center(
                          child: Text(
                            "No attendees found",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredAttendees.length,
                          itemBuilder: (context, index) {
                            final attendee = filteredAttendees[index];

                            return TweenAnimationBuilder(
                              duration:
                                  Duration(milliseconds: 400 + index * 100),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              ),
                              child: Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: secondaryColor,
                                    backgroundImage:
                                        attendee["photoUrl"] != null
                                            ? NetworkImage(attendee["photoUrl"])
                                            : null,
                                    child: attendee["photoUrl"] == null
                                        ? Text(attendee["name"][0])
                                        : null,
                                  ),
                                  title: Text(attendee["name"]),
                                  subtitle: Text(
                                      "Membership No: ${attendee["membershipNumber"]}"),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget attendeeShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 24,
              ),
            ),
            title: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 100, // set your desired width here
                  height: 16,
                  color: Colors.white,
                ),
              ),
            ),
            subtitle: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 80, // set your desired width here
                  height: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
