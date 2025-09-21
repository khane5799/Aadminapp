import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/NFCProvider.dart';
import 'package:adminapp/Provider/eventProvider.dart';
import 'package:adminapp/View/Events/EventCustomeButton.dart';
import 'package:adminapp/View/Events/NFCDilog.dart';
import 'package:adminapp/View/Events/QR_Dilog.dart';
import 'package:adminapp/Widgets/CustomCard.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:animate_do/animate_do.dart';
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
    // CardStatus initialStatus;
    // switch (event["status"]) {
    //   case "active":
    //     initialStatus = CardStatus.active;
    //     break;
    //   case "upcoming":
    //     initialStatus = CardStatus.upcoming;
    //     break;
    //   case "expired":
    //     initialStatus = CardStatus.expired;
    //     break;
    //   default:
    //     initialStatus = CardStatus.active;
    // }
    String formatTime(DateTime dateTime) {
      return DateFormat("ha").format(dateTime).replaceAll(":00", "");
    }

    return ZoomIn(
      duration: const Duration(milliseconds: 500),
      child: CustomCard(
        initials: event["name"][0]!,
        title: event["name"]!,
        details: [
          "🎯 ${event["day"]}",
          "📅 ${_formatDate(event["date"].toDate())}",
          "⏰ ${formatTime(event["startTime"].toDate())}-${formatTime(event["endTime"].toDate())}",
          "⭐ Points: ${event["points"]}"
        ],
        icons: const [
          Icons.contactless,
          Icons.qr_code,
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
            showDialog(
              context: context,
              builder: (context) => QrDialog(
                eventUid: event["uid"],
                qrKey: qrKey,
                primerycolor: primerycolor,
              ),
            );
          },
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
