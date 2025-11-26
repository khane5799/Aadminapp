import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Events_JoindAttendees extends StatefulWidget {
  final String eventId;
  final String eventName;

  const Events_JoindAttendees({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<Events_JoindAttendees> createState() => _Events_JoindAttendeesState();
}

class _Events_JoindAttendeesState extends State<Events_JoindAttendees> {
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
          final memberQuery = await firestore
              .collection("Members")
              .where("uniqueID", isEqualTo: uniqueID)
              .limit(1)
              .get();

          if (memberQuery.docs.isNotEmpty) {
            final memberData = memberQuery.docs.first.data();
            tempAttendees.add({
              "name": memberData["name"] ?? "Unknown",
              "membershipNumber": memberData["membershipNumber"] ?? "N/A",
              "photoUrl": memberData["photoUrl"],
              "points": memberData["points"] ?? 0,
            });
          }
        }
      }

      // Sort by points descending
      tempAttendees.sort(
          (a, b) => (b["points"] ?? 0).compareTo(a["points"] ?? 0));

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
        title: widget.eventName,
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

                            // 🏅 Determine styled trailing for top 3
                            Widget? trailing;
                            if (index < 3) {
                              // Choose color based on rank
                              Color badgeColor;
                              String rankText;
                              switch (index) {
                                case 0:
                                  badgeColor = const Color(0xFFFFD700); // Gold
                                  rankText = "1st";
                                  break;
                                case 1:
                                  badgeColor =
                                      const Color(0xFFC0C0C0); // Silver
                                  rankText = "2nd";
                                  break;
                                case 2:
                                  badgeColor =
                                      const Color(0xFFCD7F32); // Bronze
                                  rankText = "3rd";
                                  break;
                                default:
                                  badgeColor = Colors.grey;
                                  rankText = "";
                              }

                              trailing = Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: badgeColor, width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.emoji_events_rounded,
                                      color: badgeColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rankText,
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              trailing = null;
                            }

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
                                  trailing: Transform.scale(
                                    scale: index < 3 ? 1.1 : 1.0,
                                    child: trailing,
                                  ),
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
