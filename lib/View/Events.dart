import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Widgets/CustomCard.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> activeEvents = [
    {"name": "Unity Day", "day": "Monday", "date": "2025-09-01"},
    {"name": "Education Day", "day": "Wednesday", "date": "2025-09-03"},
    {"name": "Language Day", "day": "Friday", "date": "2025-09-03"},
    {"name": "Culture Day", "day": "Wednesday", "date": "2025-09-03"},
  ];

  final List<Map<String, String>> upcomingEvents = [
    {"name": "Women’s Day", "day": "Friday", "date": "2025-10-01"},
    {"name": "Health Day", "day": "Tuesday", "date": "2025-11-05"},
  ];

  final List<Map<String, String>> expiredEvents = [
    {"name": "Earth Day", "day": "Thursday", "date": "2024-04-22"},
    {"name": "Tech Meetup", "day": "Sunday", "date": "2024-05-15"},
  ];

  // Dialog controllers & fields
  final TextEditingController _eventNameController = TextEditingController();
  String? _selectedEventType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _eventTypes = [
    "Meeting",
    "Workshop",
    "Conference",
    "Party"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget _buildEventCard(Map<String, String> event) {
    return CustomCard(
      title: event["name"]!,
      details: ["Day: ${event["day"]}", "Date: ${event["date"]}"],
      icons: const [Icons.qr_code],
      iconActions: [
        () {
          // QR action
        }
      ],
      iconColor: primerycolor,
      showStatusSelector: true, // enable radio buttons
      initialStatus: CardStatus.active,
      onStatusChanged: (status) {
        print("Selected: $status");
      },
    );
  }

  Widget _buildEventList(List<Map<String, String>> events) {
    return events.isEmpty
        ? const Center(child: Text("No events found"))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _buildEventCard(events[index]);
            },
          );
  }

  // Function to open dialog
  void _openEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Create Event",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primerycolor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),

                    const SizedBox(height: 16),

                    // Event Name
                    TextField(
                      controller: _eventNameController,
                      decoration: InputDecoration(
                        labelText: "Event Name",
                        prefixIcon: const Icon(Icons.event),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _eventNameController,
                      decoration: InputDecoration(
                        labelText: "Event Name",
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Date Picker
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: primerycolor),
                            const SizedBox(width: 10),
                            Text(
                              _selectedDate == null
                                  ? "Select Date"
                                  : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Colors.grey.shade600
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Time Picker
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setStateDialog(() {
                            _selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: primerycolor),
                            const SizedBox(width: 10),
                            Text(
                              _selectedTime == null
                                  ? "Select Time"
                                  : _selectedTime!.format(context),
                              style: TextStyle(
                                color: _selectedTime == null
                                    ? Colors.grey.shade600
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            backgroundColor: primerycolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_eventNameController.text.isNotEmpty &&
                                _selectedDate != null) {
                              final newEvent = {
                                "name": _eventNameController.text,
                                "day": _getDayName(_selectedDate!.weekday),
                                "date":
                                    "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
                              };
                              setState(() {
                                activeEvents.add(newEvent);
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Event Created: ${_eventNameController.text}")),
                              );

                              // Clear inputs
                              _eventNameController.clear();
                              _selectedEventType = null;
                              _selectedDate = null;
                              _selectedTime = null;
                            }
                          },
                          child: Text(
                            "Create",
                            style: TextStyle(color: whiteColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // helper function for weekday name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primerycolor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 4,
          title: Text(
            "Events",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            unselectedLabelColor: whiteColor,
            labelColor: whiteColor,
            controller: _tabController,
            indicatorColor: whiteColor,
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Upcoming"),
              Tab(text: "Expired"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventList(activeEvents),
          _buildEventList(upcomingEvents),
          _buildEventList(expiredEvents),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: primerycolor,
        shape: const CircleBorder(),
        onPressed: _openEventDialog,
        child: Icon(Icons.add, color: whiteColor),
      ),
    );
  }
}
