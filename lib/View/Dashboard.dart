import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/LoginProvider.dart';
import 'package:adminapp/View/Events/Events.dart';
import 'package:adminapp/View/JoinRequests.dart';
import 'package:adminapp/View/MemberView/Member.dart';
import 'package:adminapp/View/Summery/Summery.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:adminapp/Widgets/statcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
    final loginProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      appBar: _selectedIndex == 0
          ? CustomAppBar(
              automaticallyImplyLeading: false,
              title: "Dashboard",
              ActiononTap: () {
                loginProvider.logout(context);
              },
              icon: Icons.logout,
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
  // 👇 Dummy data
  // final List<Map<String, dynamic>> events = [
  //   {"name": "Orientation", "attendance": 12},
  //   {"name": "Workshop A", "attendance": 25},
  //   {"name": "Workshop B", "attendance": 18},
  //   {"name": "Hackathon", "attendance": 400},
  //   {"name": "Team Meetup", "attendance": 9},
  //   {"name": "Leadership Talk", "attendance": 30},
  //   {"name": "Annual Party", "attendance": 50},
  //   {"name": "Training Session", "attendance": 22},
  //   {"name": "Networking", "attendance": 16},
  //   {"name": "Closing Ceremony", "attendance": 35},
  // ];

  /// 🔹 Fetch all events and their attendance counts
  Future<List<Map<String, dynamic>>> fetchEventAttendance() async {
    final eventsSnapshot =
        await FirebaseFirestore.instance.collection("events").get();

    List<Map<String, dynamic>> eventsData = [];

    for (var doc in eventsSnapshot.docs) {
      final eventData = doc.data();

      // Count attendance sub-collection docs
      final attendanceSnapshot =
          await doc.reference.collection("attendance").get();

      eventsData.add({
        "name": eventData["name"] ?? "Unnamed Event",
        "attendance": attendanceSnapshot.size,
      });
    }

    return eventsData;
  }

  /// 🔹 Calculate dynamic Y-axis interval to prevent overlapping labels
  /// 🔹 Attendance chart widget

  double _calculateYAxisInterval(double maxY) {
    if (maxY <= 50) return 5.0;
    if (maxY <= 100) return 10.0;
    if (maxY <= 500) return 25.0;
    if (maxY <= 1000) return 50.0;
    if (maxY <= 5000) return 100.0;
    if (maxY <= 10000) return 200.0;
    return (maxY / 50).ceil() * 10.0; // For very large values
  }

  /// 🔹 Calculate reserved space for Y-axis labels based on number length
  double _calculateYAxisReservedSize(double maxY) {
    final maxLabel = maxY.toInt().toString();
    final digitCount = maxLabel.length;

    // Base size + extra space per digit
    return 30.0 + (digitCount * 8.0);
  }

  /// 🔹 Build attendance chart
  Widget buildAttendanceChart(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return const Center(child: Text("No attendance data available"));
    }

    // Find maximum attendance
    final maxAttendance = events
        .map((e) => e['attendance'] as int)
        .reduce((a, b) => a > b ? a : b);

    final maxY = ((maxAttendance / 5).ceil() * 5).toDouble();
    final yAxisInterval = _calculateYAxisInterval(maxY);
    final yAxisReservedSize = _calculateYAxisReservedSize(maxY);

    // Add top and bottom padding
    final displayMaxY = maxY + 10;
    const displayMinY = 0;

    // Chart size
    final chartWidth = events.length * 80.0;
    final chartHeight = displayMaxY > 50 ? 400 + (displayMaxY * 0.8) : 350;

    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return Container(
      height: 350,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Scrollbar(
        controller: verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: verticalController,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: horizontalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                height: chartHeight.toDouble(),
                child: BarChart(
                  BarChartData(
                    maxY: displayMaxY,
                    minY: displayMinY.toDouble(),
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final event = events[groupIndex];
                          return BarTooltipItem(
                            "${event['name']}\n${rod.toY.toInt()} Attendees",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: yAxisInterval,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade400, width: 1),
                        bottom:
                            BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: yAxisReservedSize,
                          interval: yAxisInterval,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < events.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Transform.rotate(
                                  angle: -0.5,
                                  child: Text(
                                    events[index]['name'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(events.length, (index) {
                      final event = events[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (event['attendance'] as int).toDouble(),
                            width: 22,
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              colors: [primerycolor, secondaryColor],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTodaysEventShimmer() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 120, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 20, width: 180, color: Colors.white),
                  ],
                ),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatsShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 2 ? 10 : 0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildAttendanceChartShimmer() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulate top title
              Container(height: 20, width: 150, color: Colors.white),
              const SizedBox(height: 16),
              // Simulate bars
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    5, // Number of bars in shimmer
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          height: 150 + index * 20.0, // Varying heights
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDashboardShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildTodaysEventShimmer(),
          buildStatsShimmer(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildAttendanceChartShimmer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine loading based on your data availability
    final isLoadingTopCards =
        totalMembers == 0 && totalEvents == 0 && todaysEvent == null;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Today's Event Card or Shimmer
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: isLoadingTopCards
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
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
                                Container(
                                  width: 120,
                                  height: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 180,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            Container(
                              width: 80,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Card(
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
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              const SizedBox(height: 6),
                              Text(
                                todaysEvent != null
                                    ? todaysEvent!['name'] ?? 'No Name'
                                    : "No Event Today",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
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
                                color: todaysEvent != null
                                    ? Colors.green
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Stats Row or Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: isLoadingTopCards
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 2 ? 10 : 0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  )
                : Row(
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
                          iconColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: StatCard(
                          title: "Summary",
                          value: "12",
                          icon: Icons.bar_chart,
                          iconColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
          ),

          // Attendance Chart
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchEventAttendance(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: buildAttendanceChartShimmer());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No events found");
                    }
                    return buildAttendanceChart(snapshot.data!);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
