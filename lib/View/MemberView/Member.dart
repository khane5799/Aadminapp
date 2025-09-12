import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/MembersProvider.dart';
import 'package:adminapp/Routes/routes.dart';
import 'package:adminapp/Widgets/CustomCard.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    // Fetch members after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final memberProvider =
          Provider.of<MemberProvider>(context, listen: false);
      memberProvider.fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final filteredMembers = memberProvider.filterMembers(_searchQuery);

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        title: "Members",
        ActiononTap: () {},
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
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
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 10),

            // Member List
            Expanded(
              child: memberProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredMembers.isEmpty
                      ? const Center(child: Text("No members found"))
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
                              icons: const [
                                Icons.remove_red_eye,
                                Icons.qr_code
                              ],
                              iconActions: [
                                () {
                                  debugPrint(
                                      "Navigating with member data: $member");
                                  Navigator.pushNamed(
                                    context,
                                    Routes.MemberProfileScreen,
                                    arguments: member,
                                  );
                                },
                                () {
                                  // QR action (pass member["uniqueID"])
                                },
                              ],
                              iconColor: secondaryColor,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primerycolor,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.pushNamed(context, Routes.Addmember);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
