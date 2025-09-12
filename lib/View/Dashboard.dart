import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/View/Events.dart';
import 'package:adminapp/View/MemberView/Member.dart';
import 'package:adminapp/View/Summery.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:adminapp/Widgets/statcard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of pages for each tab
  late final List<Widget> _pages = [
    const DashboardPage(),
    const MemberPage(),
    const EventsPage(),
    const SummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Only show AppBar on Dashboard tab
      appBar: _selectedIndex == 0
          ? CustomAppBar(
              automaticallyImplyLeading: false,
              title: "Dashboard",
              ActiononTap: () {},
              centertitle: true,
              primerycolor: primerycolor,
              secondaryColor: secondaryColor,
            )
          // ? PreferredSize(
          //     preferredSize: const Size.fromHeight(50),
          //     child: AppBar(
          //       automaticallyImplyLeading: false,
          //       flexibleSpace: Container(
          //         decoration: BoxDecoration(
          //           gradient: LinearGradient(
          //             colors: [primerycolor, secondaryColor],
          //             begin: Alignment.topLeft,
          //             end: Alignment.bottomRight,
          //           ),
          //           borderRadius: const BorderRadius.only(
          //             bottomLeft: Radius.circular(14),
          //             bottomRight: Radius.circular(14),
          //           ),
          //         ),
          //       ),
          //       backgroundColor: Colors.transparent,
          //       elevation: 4,
          //       title: Text(
          //         "Dashboard",
          //         style: TextStyle(
          //           fontSize: 22,
          //           fontWeight: FontWeight.bold,
          //           color: whiteColor,
          //         ),
          //       ),
          //       centerTitle: true,
          //     ),
          //   )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primerycolor,
        currentIndex: _selectedIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Members"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Summary"),
        ],
      ),
    );
  }
}

// ---------------- Pages -----------------

// Dashboard Page
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Latest Event Card
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Latest Event",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        SizedBox(height: 6),
                        Text("Tech Meetup 2025",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text("Attendance: 150",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Ongoing",
                        style: TextStyle(
                          color: Colors.green,
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
                    value: "120",
                    icon: Icons.people,
                    iconColor: primerycolor,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                    child: StatCard(
                        title: "Events",
                        value: "45",
                        icon: Icons.event,
                        iconColor: Color(0xFFFF9800))),
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
                      maxY: 160,
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
                              toY: 120, color: const Color(0xFF4CAF50))
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(
                              toY: 45, color: const Color(0xFFFF9800))
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(
                              toY: 12, color: const Color(0xFF2196F3))
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

// // Summary Page
// class SummaryPage extends StatelessWidget {
//   const SummaryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text("Summary Page Content", style: TextStyle(fontSize: 22)),
//     );
//   }
// }
