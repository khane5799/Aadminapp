import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Widgets/BlurBackground.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class JoinRequests extends StatefulWidget {
  const JoinRequests({super.key});

  @override
  State<JoinRequests> createState() => _JoinRequestsState();
}

class _JoinRequestsState extends State<JoinRequests> {
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

  Future<void> showMemberQrDialog(BuildContext context, String membername,
      String membershipNumber, Color primerycolor) async {
    final qrKey = GlobalKey();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "QR Code for $membername",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 180,
                  height: 180,
                  child: RepaintBoundary(
                    key: qrKey,
                    child: QrImageView(
                      data: membershipNumber,
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
                      RenderRepaintBoundary boundary = qrKey.currentContext!
                          .findRenderObject() as RenderRepaintBoundary;
                      var image = await boundary.toImage(pixelRatio: 3.0);

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
                          text: "QR Code of $membername");
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

  /// ✅ Update status + Add member if approved
  Future<void> _updateStatus(
    String docId,
    String status,
    Map<String, dynamic> data,
  ) async {
    try {
      // show loader
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.3),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) {
          return const BlurryLoader();
        },
      );

      final uniqueID = generateUniqueID();
      final membershipNumber = await getNextMembershipNumber();

      await FirebaseFirestore.instance
          .collection("membershipApplications")
          .doc(docId)
          .update({"status": status});

      if (status == "approved") {
        final membersRef = FirebaseFirestore.instance.collection("Members");
        final memberData = {
          "uniqueID": uniqueID,
          "membershipNumber": membershipNumber,
          "name": data["name"] ?? "",
          "photoUrl": data["photoUrl"] ?? "",
          "position": data["position"] ?? "",
          "state": data["state"] ?? "",
          "division": data["division"] ?? "",
          "referralPoints": 0,
          "points": data["points"] ?? 0,
          "facebook": data["facebook"] ?? "",
          "instagram": data["instagram"] ?? "",
          "twitter": data["twitter"] ?? "",
          "whatsapp": data["whatsapp"] ?? "",
          "createdAt": DateTime.now(),
          "referral": data["referral"] ?? "",
        };

        await membersRef.doc(uniqueID).set(memberData);

        // ✅ Handle referral reward
        final referralNumber = data["referral"];
        if (referralNumber != null && referralNumber.toString().isNotEmpty) {
          final refSnapshot = await membersRef
              .where("membershipNumber", isEqualTo: referralNumber)
              .limit(1)
              .get();

          if (refSnapshot.docs.isNotEmpty) {
            final refDoc = refSnapshot.docs.first;
            final refUniqueID = refDoc["uniqueID"];
            final refPoints = (refDoc["points"] ?? 0) + 10;
            final referralPoints = (refDoc["referralPoints"] ?? 0) + 10;

            await membersRef.doc(refUniqueID).update({
              "points": refPoints,
              "referralPoints": referralPoints,
            });

            print(
                "🎉 Referral reward: $refUniqueID got +10 points (Total: $refPoints)");
          } else {
            print("⚠️ Referral membershipNumber $referralNumber not found.");
          }
        }

        if (!mounted) return;
        Navigator.of(context).pop(); // ✅ remove loader
        await showMemberQrDialog(
          context,
          memberData["name"],
          memberData["membershipNumber"],
          primerycolor,
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(); // ✅ remove loader
      }

      if (!mounted) return;
      FlushbarHelper.showSuccess(
        status == "approved"
            ? "✅ Application Approved & Member Added"
            : "❌ Application Rejected",
        context,
      );
    } catch (e, st) {
      print("❌ ERROR in _updateStatus: $e");
      print(st);
      if (!mounted) return;
      Navigator.of(context).pop(); // ✅ remove loader if error
      FlushbarHelper.showError("⚠️ Failed to update status: $e", context);
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
    Future<List<QueryDocumentSnapshot>> fetchPendingRequests() async {
      final snapshot = await FirebaseFirestore.instance
          .collection("membershipApplications")
          .where("status", isEqualTo: "pending")
          .get();
      return snapshot.docs;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        title: "Join Requests",
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // number of shimmer cards
              itemBuilder: (context, index) => buildShimmerCard(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No pending membership requests."),
            );
          }

          final requests = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              // simply call setState to reload FutureBuilder
              fetchPendingRequests();
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final doc = requests[index];
                final data = doc.data() as Map<String, dynamic>;
                final status = data["status"] ?? "pending";

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data["name"] ?? "Unknown",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    _statusBadge(status),
                                  ],
                                ),
                                const Divider(height: 20, thickness: 1),

                                // Scrollable details
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 300),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _infoRow(Icons.email,
                                            data["email"] ?? "N/A"),
                                        _infoRow(Icons.phone,
                                            data["phone"] ?? "N/A"),
                                        _infoRow(Icons.badge,
                                            "ID: ${data["idCard"] ?? "N/A"}"),
                                        _infoRow(Icons.cake,
                                            "DOB: ${data["dob"] ?? "N/A"}"),
                                        _infoRow(Icons.person,
                                            "Gender: ${data["gender"] ?? "N/A"}"),
                                        _infoRow(Icons.home,
                                            "${data["address"] ?? ""}, ${data["city"] ?? ""}"),
                                        _infoRow(Icons.markunread_mailbox,
                                            "Postcode: ${data["postcode"] ?? ""}"),
                                        _infoRow(Icons.map,
                                            "State: ${data["state"] ?? ""}"),
                                        _infoRow(Icons.work,
                                            data["occupation"] ?? "N/A"),
                                        _infoRow(Icons.star,
                                            "Membership: ${data["membershipType"] ?? ""}"),
                                        _infoRow(Icons.group,
                                            "Referral: ${data["referral"]?.isNotEmpty == true ? data["referral"] : "None"}"),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Action buttons
                                if (status == "pending")
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await _updateStatus(
                                                doc.id, "approved", data);
                                            setState(() {}); // Refresh list
                                          },
                                          icon: const Icon(Icons.check_circle,
                                              size: 18),
                                          label: const Text("Approve"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await _updateStatus(
                                                doc.id, "rejected", data);
                                            setState(() {}); // Refresh list
                                          },
                                          icon: const Icon(Icons.cancel,
                                              size: 18),
                                          label: const Text("Reject"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primerycolor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Close"),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Key info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["name"] ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email,
                                      size: 18, color: Colors.blueGrey),
                                  const SizedBox(width: 15),
                                  Text(data["email"] ?? "N/A"),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      size: 18, color: Colors.blueGrey),
                                  const SizedBox(width: 15),
                                  Text(data["phone"] ?? "N/A"),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Tap for full details",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          // Status + Arrow
                          Row(
                            children: [
                              _statusBadge(status),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildShimmerCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Key info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name placeholder
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                ),
                const SizedBox(height: 4),
                // Email row placeholder
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 18, color: Colors.blueGrey),
                      const SizedBox(width: 15),
                      Container(
                        width: 120,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // Phone row placeholder
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.blueGrey),
                      const SizedBox(width: 15),
                      Container(
                        width: 80,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Tap for full details
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 120,
                    height: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Status + arrow
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
