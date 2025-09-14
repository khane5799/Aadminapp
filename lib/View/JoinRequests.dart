import 'dart:math';

import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JoinRequests extends StatelessWidget {
  const JoinRequests({super.key});

  /// ✅ Generate Unique ID
  String generateUniqueID() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomStr = String.fromCharCodes(
      List.generate(5, (index) => Random().nextInt(26) + 65), // A-Z letters
    );
    return "$timestamp$randomStr";
  }

  Future<String> getNextMembershipNumber() async {
    final membersRef = FirebaseFirestore.instance.collection("Members");
    final snapshot = await membersRef.get();

    int maxNumber = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final membershipNumber = data["membershipNumber"] ?? "";
      if (membershipNumber.startsWith("UMNO")) {
        final numberPart =
            int.tryParse(membershipNumber.replaceAll("UMNO", ""));
        if (numberPart != null && numberPart > maxNumber) {
          maxNumber = numberPart;
        }
      }
    }

    final newNumber = maxNumber + 1;
    print("📦 New membership number generated: UMNO$newNumber");
    return "UMNO$newNumber";
  }

  /// ✅ Update status + Add member if approved
  Future<void> _updateStatus(
    String docId,
    String status,
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    try {
      final uniqueID = generateUniqueID();
      final membershipNumber = await getNextMembershipNumber();

      // Update application status
      await FirebaseFirestore.instance
          .collection("membershipApplications")
          .doc(docId)
          .update({"status": status});

      if (status == "approved") {
        // Add member
        final membersRef = FirebaseFirestore.instance.collection("Members");
        final memberData = {
          "uniqueID": uniqueID,
          "membershipNumber": membershipNumber,
          "name": data["name"] ?? "",
          "photoUrl": data["photoUrl"] ?? "",
          "position": data["position"] ?? "",
          "state": data["state"] ?? "",
          "division": data["division"] ?? "",
          "points": data["points"] ?? 0,
          "facebook": data["facebook"] ?? "",
          "instagram": data["instagram"] ?? "",
          "twitter": data["twitter"] ?? "",
          "whatsapp": data["whatsapp"] ?? "",
          "createdAt": DateTime.now(),
        };

        await membersRef.doc(uniqueID).set(memberData);

        // Show QR dialog reliably after member is added
      }

      // Show flushbar success
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlushbarHelper.showSuccess(
          status == "approved"
              ? "✅ Application Approved & Member Added"
              : "❌ Application Rejected",
          context,
        );
      });
    } catch (e, st) {
      print("❌ ERROR in _updateStatus: $e");
      print(st);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlushbarHelper.showError("⚠️ Failed to update status: $e", context);
      });
    }
  }

  /// ✅ Info row
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Status badge
  Widget _statusBadge(String status) {
    Color bgColor, textColor;
    if (status == "approved") {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else if (status == "rejected") {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    } else {
      bgColor = Colors.grey.shade200;
      textColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        title: "Join Requests",
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("membershipApplications")
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No pending membership requests."),
            );
          }

          final requests = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data["status"] ?? "pending";

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data["name"] ?? "Unknown",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _statusBadge(status),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),

                      /// Applicant Info
                      _infoRow(Icons.email, data["email"] ?? "N/A"),
                      _infoRow(Icons.phone, data["phone"] ?? "N/A"),
                      _infoRow(Icons.badge, "ID: ${data["idCard"] ?? "N/A"}"),
                      _infoRow(Icons.cake, "DOB: ${data["dob"] ?? "N/A"}"),
                      _infoRow(
                          Icons.person, "Gender: ${data["gender"] ?? "N/A"}"),
                      _infoRow(Icons.home,
                          "${data["address"] ?? ""}, ${data["city"] ?? ""}"),
                      _infoRow(Icons.markunread_mailbox,
                          "Postcode: ${data["postcode"] ?? ""}"),
                      _infoRow(Icons.map, "State: ${data["state"] ?? ""}"),
                      _infoRow(Icons.work, data["occupation"] ?? "N/A"),
                      _infoRow(Icons.star,
                          "Membership: ${data["membershipType"] ?? ""}"),
                      _infoRow(Icons.group,
                          "Referral: ${data["referral"]?.isNotEmpty == true ? data["referral"] : "None"}"),

                      const SizedBox(height: 16),

                      /// Buttons
                      if (status == "pending")
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  print(
                                      "🟢 Approve button clicked for ${doc.id}");
                                  await _updateStatus(
                                    doc.id,
                                    "approved",
                                    data,
                                    context,
                                  );
                                },
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text("Approve"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  print(
                                      "🔴 Reject button clicked for ${doc.id}");
                                  await _updateStatus(
                                    doc.id,
                                    "rejected",
                                    data,
                                    context,
                                  );
                                },
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text("Reject"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
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
      ),
    );
  }
}
