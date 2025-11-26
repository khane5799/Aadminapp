import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/NFCProvider.dart';
import 'package:adminapp/Provider/eventProviders/eventProvider.dart';
import 'package:adminapp/View/Events/EventCustomeButton.dart';
import 'package:adminapp/View/Events/NFCDilog.dart';
import 'package:adminapp/View/Events/QR_Dilog.dart';
import 'package:adminapp/Widgets/CustomCard.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

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
  bool _isNfcAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch events from Firestore on init
    Provider.of<EventProvider>(context, listen: false).fetchEvents();
  }

  Future<void> _checkNfcAvailability() async {
    bool available = await NfcManager.instance.isAvailable();
    if (mounted) {
      setState(() {
        _isNfcAvailable = available;
      });
    }
  }

  void _openEditEventDialog(Map<String, dynamic> event) {
    final TextEditingController editNameController =
        TextEditingController(text: event["name"]);
    final TextEditingController editPointsController =
        TextEditingController(text: event["points"].toString());

    DateTime selectedDate = (event["date"] as Timestamp).toDate();
    DateTime startTime = (event["startTime"] as Timestamp).toDate();
    DateTime endTime = (event["endTime"] as Timestamp).toDate();

    bool isLoading = false;

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
                  Text("Edit Event",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primerycolor)),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: editNameController,
                    decoration: InputDecoration(
                      labelText: "Event Name",
                      prefixIcon: const Icon(Icons.event),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: editPointsController,
                    decoration: InputDecoration(
                      labelText: "Event Points",
                      prefixIcon: const Icon(Icons.star),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setStateDialog(() {
                          selectedDate = pickedDate;
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
                              "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}"),
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
                        initialTime: TimeOfDay.fromDateTime(startTime),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          startTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              picked.hour,
                              picked.minute);
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
                          Text(TimeOfDay.fromDateTime(startTime)
                              .format(context)),
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
                        initialTime: TimeOfDay.fromDateTime(endTime),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          endTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              picked.hour,
                              picked.minute);
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
                          Text(TimeOfDay.fromDateTime(endTime).format(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        iconData: const Icon(Icons.cancel),
                        buttonColor: Colors.red,
                        buttonTitle: 'Cancel',
                      ),
                      const SizedBox(width: 12),
                      CustomButton(
                        onPressed: () async {
                          if (editNameController.text.isEmpty) {
                            FlushbarHelper.showError(
                                "Event name is required", context);
                            return;
                          }

                          setStateDialog(() {
                            isLoading = true;
                          });

                          final updatedEvent = {
                            "name": editNameController.text,
                            "points":
                                int.tryParse(editPointsController.text) ?? 10,
                            "day": _getDayName(selectedDate.weekday),
                            "date": selectedDate,
                            "startTime": startTime,
                            "endTime": endTime,
                          };

                          await Provider.of<EventProvider>(context,
                                  listen: false)
                              .updateEvent(event["uid"], updatedEvent);

                          setStateDialog(() {
                            isLoading = false;
                          });

                          Navigator.pop(context);
                        },
                        iconData: const Icon(Icons.save),
                        buttonColor: Colors.green,
                        buttonTitle: 'Save',
                        isLoading: isLoading,
                      )
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

  Widget _buildEventCard(Map<String, dynamic> event) {
    final nfcProvider = Provider.of<NfcProvider>(context, listen: false);
 
    String formatTime(DateTime dateTime) {
      return DateFormat("ha").format(dateTime).replaceAll(":00", "");
    }

    return ZoomIn(
      duration: const Duration(milliseconds: 500),
      child: CustomCard(
        title: event["name"]!,
        details: [
          "🎯 ${event["day"]}",
          "📅 ${_formatDate(event["date"].toDate())}",
          "⏰ ${formatTime(event["startTime"].toDate())}-${formatTime(event["endTime"].toDate())}",
          "⭐ Points: ${event["points"]}"
        ],
        icons: const [
          Icons.contactless,
          Icons.remove_red_eye,
          Icons.qr_code,
          Icons.delete,
        ],
        iconActions: [
          () async {
            // First, check NFC availability
            final isNfcAvailable = await nfcProvider.checkNFCAvailability();

            if (isNfcAvailable) {
              // Store the context before showing dialog
              final currentContext = context;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => NfcDialog(
                  currentContext: context,
                  nfcProvider: nfcProvider,
                  event: event["uid"],
                  qrKey: qrKey,
                  primerycolor: primerycolor,
                  secondaryColor: secondaryColor,
                  SubTitle: 'Scan the NFC to share event\'s details',
                ),
              );

              try {
                // Write to NFC tag
                debugPrint(
                    "Starting NFC write operation for event: ${event["uid"]}");
                await nfcProvider.writeToTag(event["uid"]);

                debugPrint("NFC Write operation completed successfully");

                // Close dialog after successful write
                if (currentContext.mounted) {
                  Navigator.pop(currentContext);

                  // Show success message
                  FlushbarHelper.showSuccess(
                      "NFC Tag Written Successfully", context);
                  // ScaffoldMessenger.of(currentContext).showSnackBar(
                  //   const SnackBar(
                  //     content: Text("NFC Tag Written Successfully"),
                  //     backgroundColor: Colors.green,
                  //     duration: Duration(seconds: 2),
                  //   ),
                  // );
                }
              } catch (e) {
                debugPrint("Error in NFC write operation: $e");

                // Close dialog and show error
                if (currentContext.mounted) {
                  Navigator.pop(currentContext);
                  FlushbarHelper.showError(
                      "Something went wrong, Try again", context);
                }
              }
            } else {
              // NFC not available - show error dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Error Icon
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 42,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Title
                              const Text(
                                "NFC Not Available",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Subtitle
                              const Text(
                                "Oops! NFC is not available on this device or is currently disabled.\n\nPlease use Share QR instead.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Action buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Close button
                                  OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.white70),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 10),
                                    ),
                                    child: const Text("Close"),
                                  ),
                                  // QR Fallback
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Add your QR share logic here
                                      showDialog(
                                        context: context,
                                        builder: (context) => QrDialog(
                                          eventUid: event["uid"],
                                          qrKey: qrKey,
                                          primerycolor: primerycolor,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.qr_code,
                                        color: Colors.white),
                                    label: const Text("Share QR"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.white.withOpacity(0.2),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              debugPrint("NFC Not Supported");
            }
          },
          () {
            _openEditEventDialog(event);
          },
          () {
            showDialog(
              context: context,
              builder: (context) => QrDialog(
                eventUid: event["uid"],
                qrKey: qrKey,
                primerycolor: primerycolor,
              ),
            );
          },
          () async {
            debugPrint("this is Event delete button");
            // Confirm deletion with the user
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  "Delete Event",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                content: const Text(
                  "Are you sure you want to delete this Event? This action cannot be undone.",
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );

            if (confirm != true) return; // user canceled
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.redAccent),
                      SizedBox(height: 16),
                      Text(
                        "Deleting event...",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            );

            try {
              debugPrint("this is my eventID: ${event["uid"]}");
              // Delete from Firestore using document ID
              await FirebaseFirestore.instance
                  .collection('events')
                  .doc(event[
                      'uid']) // or 'membershipNumber' if you use it as doc ID
                  .delete();

              // Refresh events list
              await Provider.of<EventProvider>(context, listen: false)
                  .fetchEvents();
              Navigator.pop(context); // Close loader

              FlushbarHelper.showSuccess("Event deleted successfully", context);
            } catch (e) {
              debugPrint("Error deleting event: $e");
              FlushbarHelper.showError("Failed to delete event", context);
            }
          }
        ],
        iconColor: primerycolor,
        showStatusSelector: true,
        // initialStatus: initialStatus,
        onStatusChanged: (status) {
          print("Selected: $status");
        },
      ),
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
                      CustomButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        iconData: const Icon(Icons.cancel),
                        buttonColor: Colors.red,
                        buttonTitle: 'Cancel',
                      ),
                      const SizedBox(width: 12),
            
                      CustomButton(
                        onPressed: () async {
                          if (_eventNameController.text.isEmpty ||
                              _selectedDate == null ||
                              _startTime == null ||
                              _endTime == null) {
                            FlushbarHelper.showError(
                                "All fields are required", context);
                            return;
                          }

                          // ✅ Validate End Time >= Start Time
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

                          if (endDateTime.isBefore(startDateTime)) {
                            FlushbarHelper.showError(
                                "End time cannot be before Start time",
                                context);
                            return;
                          }

                          setStateDialog(() {
                            isLoading = true;
                          });

                          // 👇 Apply default value if empty
                          final int eventPoints = _eventPointController
                                  .text.isEmpty
                              ? 10
                              : int.tryParse(_eventPointController.text) ?? 10;

                          final newEvent = {
                            "name": _eventNameController.text,
                            "points": eventPoints,
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
                        iconData: const Icon(Icons.check),
                        buttonColor: Colors.green,
                        buttonTitle: 'Create',
                        isLoading: isLoading,
                      )
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
