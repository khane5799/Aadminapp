import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/View/MemberView/AddMember.dart';
import 'package:adminapp/View/MemberView/MemberProfile.dart';
import 'package:adminapp/Widgets/CustomCard.dart';
import 'package:flutter/material.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  final List<Map<String, dynamic>> members = [
    {
      "name": "John Doe",
      "membershipCode": "M123",
      "division": "North",
      "points": 120
    },
    {
      "name": "Jane Smith",
      "membershipCode": "M124",
      "division": "South",
      "points": 90
    },
    {
      "name": "Zakir",
      "membershipCode": "M343",
      "division": "West",
      "points": 130
    },
    {
      "name": "Nasir Khan",
      "membershipCode": "M984",
      "division": "South",
      "points": 70
    },
    // Add more members here
  ];

  List<Map<String, dynamic>> filteredMembers = [];

  @override
  void initState() {
    super.initState();
    filteredMembers = List.from(members); // Initially show all members
  }

  void _filterMembers(String query) {
    final filtered = members.where((member) {
      final nameLower = member["name"].toString().toLowerCase();
      final codeLower = member["membershipCode"].toString().toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower) || codeLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredMembers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
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
          title: const Text(
            "Members",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              decoration: InputDecoration(
                hintText: "Search by Name or ID",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: _filterMembers,
            ),

            // Member List
            Expanded(
              child: filteredMembers.isEmpty
                  ? const Center(
                      child: Text("No members found"),
                    )
                  : ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return CustomCard(
                            title: member["name"],
                            details: [
                              "Code: ${member["membershipCode"]}",
                              "Division: ${member["division"]}",
                              "Points: ${member["points"]}"
                            ],
                            icons: const [Icons.remove_red_eye, Icons.qr_code],
                            iconActions: [
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        const MemberProfileScreen(),
                                  ),
                                );
                              },
                              () {
                                // QR action
                              },
                            ],
                            iconColor:
                                secondaryColor // optional, QR icon can use default
                            );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: primerycolor,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const Addmember(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
    );
  }
}
