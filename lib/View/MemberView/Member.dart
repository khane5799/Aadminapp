import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

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

// Declare a global key
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
                  ? Center(
                      child: CircularProgressIndicator(
                      color: primerycolor,
                    ))
                  : filteredMembers.isEmpty
                      ? const Center(child: Text("No members found"))
                      : ListView.builder(
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            return CustomCard(
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
                                  debugPrint(
                                      "Navigating with member data: $member");
                                  final result = await Navigator.pushNamed(
                                    context,
                                    Routes.MemberProfileScreen,
                                    arguments: member,
                                  );

                                  if (result == true) {
                                    // Refresh members after update
                                    FlushbarHelper.showSuccess(
                                        "Profile Updated successfully",
                                        context);
                                    await memberProvider.fetchMembers();
                                  }

                                  // Navigator.pushNamed(
                                  //   context,
                                  //   Routes.MemberProfileScreen,
                                  //   arguments: member,
                                  // );
                                },
                                () {
                                  // Show QR Code dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        contentPadding:
                                            const EdgeInsets.all(20),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  "QR Code for ${member["name"]}",
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 20),
                                              SizedBox(
                                                width: 180,
                                                height: 180,
                                                child: RepaintBoundary(
                                                  key: qrKey,
                                                  child: QrImageView(
                                                    data: member[
                                                        "membershipCode"],
                                                    version: QrVersions.auto,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.share,
                                                    color: Colors.white),
                                                label: const Text(
                                                  "Share",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primerycolor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  try {
                                                    // Get QR widget boundary
                                                    RenderRepaintBoundary
                                                        boundary = qrKey
                                                                .currentContext!
                                                                .findRenderObject()
                                                            as RenderRepaintBoundary;
                                                    ui.Image image =
                                                        await boundary.toImage(
                                                            pixelRatio: 3.0);

                                                    // Convert to byte data
                                                    ByteData? byteData =
                                                        await image.toByteData(
                                                            format: ui
                                                                .ImageByteFormat
                                                                .png);
                                                    Uint8List pngBytes =
                                                        byteData!.buffer
                                                            .asUint8List();

                                                    // Save to temp directory
                                                    final tempDir =
                                                        await getTemporaryDirectory();
                                                    final file = await File(
                                                            '${tempDir.path}/qr.png')
                                                        .create();
                                                    await file
                                                        .writeAsBytes(pngBytes);

                                                    // Share image file
                                                    await Share.shareXFiles(
                                                        [XFile(file.path)],
                                                        text:
                                                            "QR Code of ${member["name"]}");
                                                  } catch (e) {
                                                    debugPrint(
                                                        "Error sharing QR image: $e");
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
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
