import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/View/Summery/Events_JoindAttendees.dart';
import 'package:adminapp/Widgets/AnimatedCard.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:animate_do/animate_do.dart'; // animation package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // for date formatting

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  int? selectedYear;
  int? selectedMonth;
  List<int> availableYears = [];

  String query = "";
  List<Map<String, dynamic>> eventsWithAttendees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // ✅ Generate years from 2022 up to current year
    int currentYear = DateTime.now().year;
    availableYears = List.generate(
      currentYear - 2022 + 1,
      (index) => 2022 + index,
    ).reversed.toList(); // reversed so latest year comes first

    selectedYear = currentYear; // default to current year
    fetchEvents();
  }

  IconData? getEventIcon(String name) {
    final lower = name.toLowerCase();

    if (lower.contains("meeting") || lower.contains("conference")) {
      return Icons.people;
    } else if (lower.contains("sports") ||
        lower.contains("match") ||
        lower.contains("tournament")) {
      return Icons.sports_soccer;
    } else if (lower.contains("dinner") ||
        lower.contains("lunch") ||
        lower.contains("party")) {
      return Icons.restaurant;
    } else if (lower.contains("workshop") ||
        lower.contains("training") ||
        lower.contains("class")) {
      return Icons.school;
    } else if (lower.contains("concert") ||
        lower.contains("music") ||
        lower.contains("festival")) {
      return Icons.music_note;
    } else if (lower.contains("award") ||
        lower.contains("ceremony") ||
        lower.contains("celebration")) {
      return Icons.emoji_events;
    } else if (lower.contains("charity") || lower.contains("fundraiser")) {
      return Icons.volunteer_activism;
    } else if (lower.contains("religious") ||
        lower.contains("prayer") ||
        lower.contains("church") ||
        lower.contains("mosque")) {
      return Icons.church; // closest Flutter has
    } else if (lower.contains("tech") ||
        lower.contains("hackathon") ||
        lower.contains("seminar")) {
      return Icons.computer;
    } else if (lower.contains("holiday") ||
        lower.contains("trip") ||
        lower.contains("tour")) {
      return Icons.flight_takeoff;
    }

    return null; // 👈 means no match found
  }

  Future<void> fetchEvents() async {
    setState(() => isLoading = true);

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection("events")
        .orderBy("date", descending: true)
        .get();

    List<Map<String, dynamic>> tempEvents = [];

    for (var eventDoc in eventsSnapshot.docs) {
      final eventId = eventDoc.id;
      final eventData = eventDoc.data();

      final attendeesSnapshot = await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("attendance")
          .get();

      DateTime? dateTime;
      if (eventData["date"] != null && eventData["date"] is Timestamp) {
        dateTime = (eventData["date"] as Timestamp).toDate();
      }

      tempEvents.add({
        "uid": eventId,
        "name": eventData["name"] ?? "Unknown Event",
        "attendees": attendeesSnapshot.docs.length,
        "date": dateTime,
        "points": eventData["points"],
      });
    }

    setState(() {
      eventsWithAttendees = tempEvents;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔎 Apply filters
    final filteredEvents = eventsWithAttendees.where((event) {
      final nameMatch =
          event["name"].toLowerCase().contains(query.toLowerCase());

      final date = event["date"] as DateTime?;
      final yearMatch =
          selectedYear == null || (date != null && date.year == selectedYear);
      final monthMatch = selectedMonth == null ||
          (date != null && date.month == selectedMonth);

      return nameMatch && yearMatch && monthMatch;
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: "📅 Events",
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: fetchEvents,
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search events...",
                    prefixIcon: Icon(Icons.search, color: primerycolor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  onChanged: (val) => setState(() => query = val),
                ),
              ),
            ),

            // 🗓️ Month + Year Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField2<int>(
                      isExpanded: true,
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: "Select Year",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        height: 20,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),

                      // 👇 Custom UI for selected year (bold)
                      selectedItemBuilder: (context) {
                        return availableYears.map((year) {
                          return Text(
                            year.toString(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          );
                        }).toList();
                      },

                      // 👇 Dropdown items
                      items: availableYears
                          .map((year) => DropdownMenuItem<int>(
                                value: year,
                                child: Text(
                                  year.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),

                      onChanged: (val) => setState(() => selectedYear = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField2<int>(
                      isExpanded: true,
                      value: selectedMonth,
                      decoration: InputDecoration(
                        labelText: "Select Month",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        height: 20,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),

                      // 👇 Custom UI for the selected value
                      selectedItemBuilder: (context) {
                        return List.generate(12, (index) => index + 1)
                            .map((month) {
                          return Text(
                            DateFormat.MMMM().format(
                                DateTime(2025, month)), // 👈 Full month name

                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          );
                        }).toList();
                      },

                      items: List.generate(12, (index) => index + 1)
                          .map((month) => DropdownMenuItem<int>(
                                value: month,
                                child: Text(
                                  DateFormat.MMMM()
                                      .format(DateTime(2025, month)),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),

                      onChanged: (val) => setState(() => selectedMonth = val),
                    ),
                  ),
                ],
              ),
            ),

            // 📋 Event List
            Expanded(
              child: isLoading
                  ? Center(child: eventShimmer())
                  : filteredEvents.isEmpty
                      ? const Center(
                          child: Text(
                            "No events found",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            String dateText = "";
                            if (event["date"] != null) {
                              try {
                                dateText = DateFormat("dd MMM yyyy")
                                    .format(event["date"]);
                              } catch (_) {}
                            }
                            Color avatarColor;
                            switch (index % 8) {
                              // use modulo to loop over 8 colors
                              case 0:
                                avatarColor = Colors.blue;
                                break;
                              case 1:
                                avatarColor = Colors.red;
                                break;
                              case 2:
                                avatarColor = Colors.green;
                                break;
                              case 3:
                                avatarColor = Colors.orange;
                                break;
                              case 4:
                                avatarColor = Colors.purple;
                                break;
                              case 5:
                                avatarColor = Colors.teal;
                                break;
                              case 6:
                                avatarColor = Colors.indigo;
                                break;
                              case 7:
                                avatarColor = Colors.brown;
                                break;
                              default:
                                avatarColor = Colors.blueGrey; // fallback
                            }

                            return ZoomIn(
                              duration:
                                  Duration(milliseconds: 200 + (index * 100)),
                              child: EventCard(
                                event: event,
                                index: index,
                                secondaryColor: secondaryColor,
                                getEventIcon: getEventIcon,
                                onTap: (eventId, eventName) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Events_JoindAttendees(
                                        eventId: eventId,
                                        eventName: eventName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),

            // 📊 Sticky Footer showing total events
            Container(
              padding: const EdgeInsets.all(16),
              color: primerycolor.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "📊 Total Events: ${filteredEvents.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
              ),
            ),
            title: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 150, // adjust width to mimic title length
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 120, // mimic date text
                      height: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 100, // mimic attendees text
                      height: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 80, // mimic points text
                      height: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
