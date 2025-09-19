import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/MembersProvider.dart';
import 'package:adminapp/Routes/routes.dart';
import 'package:adminapp/Widgets/CustomCard.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

// Global key for QR
final GlobalKey qrKey = GlobalKey();

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
            // Search Field with elevation and rounded corners
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by Name or ID",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // Member List
            Expanded(
              child: memberProvider.isLoading
                  ? Center(child: customCardShimmer())
                  : filteredMembers.isEmpty
                      ? const Center(
                          child: Text(
                            "No members found",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            return CustomCard(
                              initials: member["name"][0],
                              profileImageUrl: member["photoUrl"],
                              title: member["name"],
                              details: [
                                "Code: ${member["membershipNumber"]}",
                                "Division: ${member["division"]}",
                                "Points: ${member["points"]}"
                              ],
                              icons: const [
                                Icons.remove_red_eye,
                                Icons.qr_code
                              ],
                              iconActions: [
                                () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    Routes.MemberProfileScreen,
                                    arguments: member,
                                  );

                                  if (result == true) {
                                    FlushbarHelper.showSuccess(
                                        "Profile updated successfully",
                                        context);
                                    await memberProvider.fetchMembers();
                                  }
                                },
                                () {
                                  _showQrDialog(member);
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

  // Enhanced QR Dialog
  void _showQrDialog(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("QR Code for ${member["name"]}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        primerycolor.withOpacity(0.2),
                        secondaryColor.withOpacity(0.2)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: RepaintBoundary(
                    key: qrKey,
                    child: QrImageView(
                      data: member["membershipNumber"],
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      size: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text("Share QR Code",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primerycolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                  onPressed: () async {
                    try {
                      RenderRepaintBoundary boundary = qrKey.currentContext!
                          .findRenderObject() as RenderRepaintBoundary;
                      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                      ByteData? byteData = await image.toByteData(
                          format: ui.ImageByteFormat.png);
                      Uint8List pngBytes = byteData!.buffer.asUint8List();

                      final tempDir = await getTemporaryDirectory();
                      final file =
                          await File('${tempDir.path}/qr.png').create();
                      await file.writeAsBytes(pngBytes);

                      await Share.shareXFiles([XFile(file.path)],
                          text: "QR Code of ${member["name"]}");
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

  Widget customCardShimmer({int itemCount = 5}) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Avatar shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),

                // 🔹 Title & Details shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 140, // mimic title length
                          height: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Detail 1
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 100,
                          height: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Detail 2
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 120,
                          height: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Detail 3
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 80,
                          height: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // 🔹 Icons shimmer
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (_) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
