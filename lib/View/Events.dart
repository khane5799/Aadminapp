import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/eventProvider.dart';
import 'package:adminapp/Widgets/CustomCard.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

final GlobalKey qrKey = GlobalKey();

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventPointController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch events from Firestore on init
    Provider.of<EventProvider>(context, listen: false).fetchEvents();
  }

  // Widget _buildEventCard(Map<String, dynamic> event) {
  //   CardStatus initialStatus;
  //   switch (event["status"]) {
  //     case "active":
  //       initialStatus = CardStatus.active;
  //       break;
  //     case "upcoming":
  //       initialStatus = CardStatus.upcoming;
  //       break;
  //     case "expired":
  //       initialStatus = CardStatus.expired;
  //       break;
  //     default:
  //       initialStatus = CardStatus.active;
  //   }

  //   return CustomCard(
  //     title: event["name"]!,
  //     details: [
  //       "Day: ${event["day"]}",
  //       "Date: ${_formatDate(event["date"].toDate())}",
  //       "Start: ${_formatTime(event["startTime"].toDate())}",
  //       "End: ${_formatTime(event["endTime"].toDate())}",
  //     ],
  //     icons: const [Icons.qr_code],
  //     iconActions: [() {}],
  //     iconColor: primerycolor,
  //     showStatusSelector: true,
  //     initialStatus: initialStatus,
  //     onStatusChanged: (status) {
  //       print("Selected: $status");
  //     },
  //   );
  // }
  Widget _buildEventCard(Map<String, dynamic> event) {
    CardStatus initialStatus;
    switch (event["status"]) {
      case "active":
        initialStatus = CardStatus.active;
        break;
      case "upcoming":
        initialStatus = CardStatus.upcoming;
        break;
      case "expired":
        initialStatus = CardStatus.expired;
        break;
      default:
        initialStatus = CardStatus.active;
    }

    return CustomCard(
      title: event["name"]!,
      details: [
        "Day: ${event["day"]}",
        "Date: ${_formatDate(event["date"].toDate())}",
        "Start: ${_formatTime(event["startTime"].toDate())}",
        "End: ${_formatTime(event["endTime"].toDate())}",
      ],
      icons: const [Icons.qr_code],
      iconActions: [
        () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.all(20),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Event QR Code",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: RepaintBoundary(
                          key: qrKey,
                          child: QrImageView(
                            data: event["uid"],
                            version: QrVersions.auto,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text(
                          "Share",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primerycolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            // Get QR widget boundary
                            RenderRepaintBoundary boundary =
                                qrKey.currentContext!.findRenderObject()
                                    as RenderRepaintBoundary;
                            ui.Image image =
                                await boundary.toImage(pixelRatio: 3.0);

                            // Convert to byte data
                            ByteData? byteData = await image.toByteData(
                                format: ui.ImageByteFormat.png);
                            Uint8List pngBytes = byteData!.buffer.asUint8List();

                            // Save to temp directory
                            final tempDir = await getTemporaryDirectory();
                            final file =
                                await File('${tempDir.path}/qr.png').create();
                            await file.writeAsBytes(pngBytes);

                            // Share image file
                            await Share.shareXFiles([XFile(file.path)],
                                text: "");
                          } catch (e) {
                            debugPrint("Error sharing QR image: $e");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ],
      iconColor: primerycolor,
      showStatusSelector: true,
      initialStatus: initialStatus,
      onStatusChanged: (status) {
        print("Selected: $status");
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
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

  void _openEventDialog() {
    bool isLoading = false; // Dialog local state

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Create Event",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primerycolor)),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _eventNameController,
                    decoration: InputDecoration(
                      labelText: "Event Name",
                      prefixIcon: const Icon(Icons.event),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _eventPointController,
                    decoration: InputDecoration(
                      labelText: "Event Points",
                      prefixIcon: const Icon(Icons.event),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
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
                          Text(_selectedDate == null
                              ? "Select Date"
                              : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Start Time
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          _startTime = picked;
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
                          Icon(Icons.schedule, color: primerycolor),
                          const SizedBox(width: 10),
                          Text(_startTime == null
                              ? "Select Start Time"
                              : _startTime!.format(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // End Time
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          _endTime = picked;
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
                          Icon(Icons.schedule, color: primerycolor),
                          const SizedBox(width: 10),
                          Text(_endTime == null
                              ? "Select End Time"
                              : _endTime!.format(context)),
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
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          // Validate required fields
                          if (_eventNameController.text.isEmpty ||
                              _selectedDate == null ||
                              _startTime == null ||
                              _endTime == null) {
                            FlushbarHelper.showError(
                                "All fields are required", context);
                            return;
                          }

                          setStateDialog(() {
                            isLoading = true;
                          });

                          final startDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _startTime!.hour,
                            _startTime!.minute,
                          );

                          final endDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _endTime!.hour,
                            _endTime!.minute,
                          );

                          // 👇 Apply default value if empty
                          final int eventPoints = _eventPointController
                                  .text.isEmpty
                              ? 10
                              : int.tryParse(_eventPointController.text) ?? 10;

                          final newEvent = {
                            "name": _eventNameController.text,
                            "points": eventPoints, // ✅ Store points here
                            "day": _getDayName(_selectedDate!.weekday),
                            "date": _selectedDate,
                            "startTime": startDateTime,
                            "endTime": endDateTime,
                          };

                          await Provider.of<EventProvider>(context,
                                  listen: false)
                              .addEvent(newEvent);

                          setStateDialog(() {
                            isLoading = false;
                          });

                          Navigator.pop(context);
                          _eventNameController.clear();
                          _eventPointController.clear();
                          _selectedDate = null;
                          _startTime = null;
                          _endTime = null;
                        },
                        child: isLoading
                            ? CircularProgressIndicator(color: primerycolor)
                            : const Text("Create"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

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
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
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
              title: Text("Events",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: whiteColor)),
              centerTitle: true,
              bottom: TabBar(
                unselectedLabelColor: whiteColor,
                labelColor: whiteColor,
                controller: _tabController,
                indicatorColor: whiteColor,
                tabs: const [
                  Tab(text: "Active"),
                  Tab(text: "Upcoming"),
                  Tab(text: "Expired")
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(provider.activeEvents),
              _buildEventList(provider.upcomingEvents),
              _buildEventList(provider.expiredEvents),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openEventDialog,
            backgroundColor: primerycolor,
            shape: const CircleBorder(),
            child: Icon(Icons.add, color: whiteColor),
          ),
        );
      },
    );
  }
}
