import 'dart:ui';

import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/View/Summery/EventsList.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>
    with TickerProviderStateMixin {
  Map<String, int> eventsPerMonth = {};

  Future<void> fetchEventsPerMonth() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("events").get();

    Map<String, int> monthlyCount = {
      "Jan": 0,
      "Feb": 0,
      "Mar": 0,
      "Apr": 0,
      "May": 0,
      "Jun": 0,
      "Jul": 0,
      "Aug": 0,
      "Sep": 0,
      "Oct": 0,
      "Nov": 0,
      "Dec": 0,
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data["date"] != null) {
        DateTime eventDate;

        if (data["date"] is Timestamp) {
          eventDate = (data["date"] as Timestamp).toDate();
        } else if (data["date"] is DateTime) {
          eventDate = data["date"];
        } else {
          continue; // skip invalid date
        }

        final monthName = _getMonthName(eventDate.month);
        monthlyCount[monthName] = (monthlyCount[monthName] ?? 0) + 1;
      }
    }

    setState(() {
      //here is showing the above exception
      eventsPerMonth = monthlyCount;
    });
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    fetchEventsPerMonth();
  }

  // final Map<String, int> eventsPerMonth = {
  //   "Jan": 5,
  //   "Feb": 3,
  //   "Mar": 7,
  //   "Apr": 6,
  //   "May": 4,
  //   "Jun": 5,
  // };

  // 🔹 Firestore Queries
  Future<List<Map<String, dynamic>>> getTopOverall() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("Members")
        .orderBy("points", descending: true)
        .limit(5)
        .get();

    return snapshot.docs
        .map((doc) => {
              "photoUrl": doc["photoUrl"],
              "name": doc["name"],
              "points": doc["points"],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTopReferrals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("Members")
        .orderBy("referralPoints", descending: true)
        .limit(5)
        .get();

    return snapshot.docs
        .map((doc) => {
              "photoUrl": doc["photoUrl"],
              "name": doc["name"],
              "referralPoints": doc["referralPoints"],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTopEventPoints() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("Members")
        .orderBy("EventPoints", descending: true)
        .limit(5)
        .get();

    return snapshot.docs
        .map((doc) => {
              "photoUrl": doc["photoUrl"],
              "name": doc["name"],
              "eventPoints": doc["EventPoints"],
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        title: "📊  Summary Dashboard",
        ActiononTap: () {},
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("🏆 Top Members (Overall Points)"),
            FutureBuilder(
              future: getTopOverall(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: _buildShimmerTopMembersCard());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No data found");
                }
                return _buildTopMembersCard(snapshot.data!, "points");
              },
            ),
            _buildSectionTitle("🎯 Top Members (Referral Points)"),
            FutureBuilder(
              future: getTopReferrals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: _buildShimmerTopMembersCard());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No data found");
                }
                return _buildTopMembersCard(snapshot.data!, "referralPoints");
              },
            ),
            _buildSectionTitle("🔥 Top Members (Event Points)"),
            FutureBuilder(
              future: getTopEventPoints(), // 🔹 pass your eventId here
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: _buildShimmerTopMembersCard());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No data found");
                }
                return _buildTopMembersCard(snapshot.data!, "eventPoints");
              },
            ),
            const SizedBox(height: 24),
            _buildEventCard(),
            const SizedBox(height: 24),
            _buildSectionTitle("📈 Events Per Month"),
            _buildEventsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTopMembersCard() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primerycolor.withOpacity(0.5),
                        secondaryColor.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 14,
                        width: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 50,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventListPage()),
        );
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, double scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primerycolor.withOpacity(0.85),
                secondaryColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primerycolor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.event_available_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "View All Events",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap to explore event attendance",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          shadows: [
            Shadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 3)
          ],
        ),
      ),
    );
  }

  Widget _buildTopMembersCard(
      List<Map<String, dynamic>> members, String keyName) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final member = members[index];
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

          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 250 + index * 100), // faster
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(scale: value, child: child),
              );
            },
            child: GestureDetector(
              onTap: () {
                // Optional: detailed popup
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250), // faster
                    curve: Curves.easeInOut,
                    width: 160,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primerycolor.withOpacity(0.5),
                          secondaryColor.withOpacity(0.5)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: (member["photoUrl"] != null &&
                                  member["photoUrl"] != "")
                              ? Colors.grey.shade300
                              : avatarColor,
                          child: (member["photoUrl"] != null &&
                                  member["photoUrl"] != "")
                              ? ClipOval(
                                  child: Image.network(
                                    member["photoUrl"],
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // This runs if the network image fails
                                      return Center(
                                        child: Text(
                                          member["name"][0],
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  member["name"][0],
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          member["name"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                              begin: 0, end: member[keyName].toDouble()),
                          duration: const Duration(milliseconds: 500), // faster
                          builder: (context, value, child) {
                            return Text(
                              "${value.toInt()} Points",
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Events Chart
  Widget _buildEventsChart() {
    if (eventsPerMonth.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final maxY =
        (eventsPerMonth.values.reduce((a, b) => a > b ? a : b) + 2).toDouble();
    final barGroups = eventsPerMonth.entries.map((entry) {
      return BarChartGroupData(
        x: eventsPerMonth.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            width: 22,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(colors: [primerycolor, secondaryColor]),
          )
        ],
      );
    }).toList();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final month = eventsPerMonth.keys.elementAt(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      month,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (val, meta) => Text(val.toInt().toString()),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}
