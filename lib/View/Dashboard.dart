import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/View/Events.dart';
import 'package:adminapp/View/JoinRequests.dart';
import 'package:adminapp/View/MemberView/Member.dart';
import 'package:adminapp/View/Summery/Summery.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:adminapp/Widgets/statcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  int totalMembers = 0;
  int totalEvents = 0;
  Map<String, dynamic>? todaysEvent;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch members count
    final membersSnapshot = await firestore.collection('Members').get();
    totalMembers = membersSnapshot.docs.length;

    // Fetch events
    final eventsSnapshot = await firestore.collection('events').get();
    totalEvents = eventsSnapshot.docs.length;

    final today = DateTime.now();
    // Find today's event
    for (var doc in eventsSnapshot.docs) {
      final data = doc.data();
      final eventDate = (data['date'] as Timestamp).toDate();
      if (eventDate.year == today.year &&
          eventDate.month == today.month &&
          eventDate.day == today.day) {
        todaysEvent = data;
        break; // Take the first event of today
      }
    }

    setState(() {});
  }

  // List of pages for each tab
  late final List<Widget> _pages = [
    const DashboardPageWidget(),
    const MemberPage(),
    const JoinRequests(),
    const EventsPage(),
    const SummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? CustomAppBar(
              automaticallyImplyLeading: false,
              title: "Dashboard",
              ActiononTap: () {},
              centertitle: true,
              primerycolor: primerycolor,
              secondaryColor: secondaryColor,
            )
          : null,
      body: _selectedIndex == 0
          ? DashboardPageWidget(
              totalMembers: totalMembers,
              totalEvents: totalEvents,
              todaysEvent: todaysEvent,
            )
          : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primerycolor,
        currentIndex: _selectedIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Members"),
          BottomNavigationBarItem(
              icon: Icon(Icons.link), label: "Join Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Summary"),
        ],
      ),
    );
  }
}

// ---------------- Dashboard Page Widget -----------------

class DashboardPageWidget extends StatelessWidget {
  final int totalMembers;
  final int totalEvents;
  final Map<String, dynamic>? todaysEvent;

  const DashboardPageWidget({
    super.key,
    this.totalMembers = 0,
    this.totalEvents = 0,
    this.todaysEvent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Today's Event Card
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Today's Event",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          todaysEvent != null
                              ? todaysEvent!['name'] ?? 'No Name'
                              : "No Event Today",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        // const SizedBox(height: 6),
                        // Text(
                        //   todaysEvent != null
                        //       ? "Attendance: ${todaysEvent!['attendance'] ?? 'N/A'}"
                        //       : "",
                        //   style: const TextStyle(
                        //       fontSize: 14, color: Colors.black87),
                        // ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: todaysEvent != null
                            ? Colors.green[100]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        todaysEvent != null ? "Ongoing" : "No Event",
                        style: TextStyle(
                          color:
                              todaysEvent != null ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stat Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StatCard(
                    title: "Members",
                    value: "$totalMembers",
                    icon: Icons.people,
                    iconColor: primerycolor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: "Events",
                    value: "$totalEvents",
                    icon: Icons.event,
                    iconColor: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                    child: StatCard(
                        title: "Summary",
                        value: "12",
                        icon: Icons.bar_chart,
                        iconColor: Color(0xFF2196F3))),
              ],
            ),
          ),

          // Bar Chart
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 350,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (totalMembers > totalEvents
                                  ? totalMembers
                                  : totalEvents)
                              .toDouble() +
                          10,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Members');
                                case 1:
                                  return const Text('Events');
                                case 2:
                                  return const Text('Summary');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(
                              toY: totalMembers.toDouble(),
                              color: const Color(0xFF4CAF50))
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(
                              toY: totalEvents.toDouble(),
                              color: const Color(0xFFFF9800))
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(
                              toY: 3, color: const Color(0xFF2196F3))
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
