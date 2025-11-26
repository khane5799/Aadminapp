import 'dart:io';
import 'dart:ui' as ui;

import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/MemberProviders/MembersProvider.dart';
import 'package:adminapp/Provider/NFCProvider.dart';
import 'package:adminapp/Routes/routes.dart';
import 'package:adminapp/View/Events/NFCDilog.dart';
import 'package:adminapp/Widgets/CustomCard.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
    final nfcProvider = Provider.of<NfcProvider>(context, listen: false);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        appBar: CustomAppBar(
          automaticallyImplyLeading: false,
          title: "Members",
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
                    ? const Center(
                        child: CustomCardShimmerList(
                          itemCount: 3,
                          detailsCount: 3,
                          iconsCount: 4,
                        ),
                      )
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
                                profileImageUrl: member["photoUrl"],
                                title: member["name"],
                                details: [
                                  "Code: ${member["membershipNumber"]}",
                                  "Division: ${member["division"]}",
                                  "Points: ${member["points"]}"
                                ],
                                icons: const [
                                  Icons.contactless,
                                  Icons.remove_red_eye,
                                  Icons.qr_code,
                                  Icons.web,
                                  Icons.delete,
                                ],
                                iconActions: [
                                  () async {
                                    // First, check NFC availability
                                    final isNfcAvailable = await nfcProvider
                                        .checkNFCAvailability();

                                    if (isNfcAvailable) {
                                      // Store the context before showing dialog
                                      final currentContext = context;

                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => NfcDialog(
                                          currentContext: context,
                                          nfcProvider: nfcProvider,
                                          event: member["membershipNumber"],
                                          qrKey: qrKey,
                                          primerycolor: primerycolor,
                                          secondaryColor: secondaryColor,
                                          SubTitle:
                                              'Scan the NFC to share member’s profile',
                                        ),
                                      );

                                      try {
                                        // Write to NFC tag
                                        debugPrint(
                                            "Starting NFC write operation for event: ${member["membershipNumber"]}");
                                        await nfcProvider.writeToTag(
                                          "https://umno.web.app/#/${member["membershipNumber"]}",
                                        );

                                        debugPrint(
                                            "NFC Write operation completed successfully");

                                        // Close dialog after successful write
                                        if (currentContext.mounted) {
                                          Navigator.pop(currentContext);

                                          // Show success message
                                          FlushbarHelper.showSuccess(
                                              "NFC Tag Written Successfully",
                                              context);
                                          // ScaffoldMessenger.of(currentContext).showSnackBar(
                                          //   const SnackBar(
                                          //     content: Text("NFC Tag Written Successfully"),
                                          //     backgroundColor: Colors.green,
                                          //     duration: Duration(seconds: 2),
                                          //   ),
                                          // );
                                        }
                                      } catch (e) {
                                        debugPrint(
                                            "Error in NFC write operation: $e");

                                        // Close dialog and show error
                                        if (currentContext.mounted) {
                                          Navigator.pop(currentContext);
                                          FlushbarHelper.showError(
                                              "Something went wrong, Try again",
                                              context);
                                        }
                                      }
                                    } else {
                                      // NFC not available - show error dialog
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 24),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red.shade400,
                                                      Colors.red.shade700
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.redAccent
                                                          .withOpacity(0.6),
                                                      blurRadius: 20,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(24),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Error Icon
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(18),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.15),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.error_outline,
                                                          size: 42,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      // Title
                                                      const Text(
                                                        "NFC Not Available",
                                                        style: TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          letterSpacing: 1,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      // Subtitle
                                                      const Text(
                                                        "Oops! NFC is not available on this device or is currently disabled.\n\nPlease use Share QR instead.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 24),
                                                      // Action buttons
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          // Close button
                                                          OutlinedButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                              foregroundColor:
                                                                  Colors.white,
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .white70),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          18,
                                                                      vertical:
                                                                          10),
                                                            ),
                                                            child: const Text(
                                                                "Close"),
                                                          ),
                                                          // QR Fallback
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                      debugPrint("NFC Not Supported");
                                    }
                                  },
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
                                  () {
                                    _showQrWebDilog(member);
                                    debugPrint("this");
                                  },
                                  () async {
                                    // Step 1: Confirm deletion
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        title: const Text(
                                          "Delete Member",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        content: const Text(
                                          "Are you sure you want to delete this member? This action cannot be undone.",
                                          style: TextStyle(
                                              fontSize: 16, height: 1.4),
                                        ),
                                        actionsPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                        actionsAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade600,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm != true) return;

                                    // Step 2: Delete member from Firestore

                                    try {
                                      debugPrint(
                                          "this is my membershipID: ${member['uniqueID']}");

                                      await FirebaseFirestore.instance
                                          .collection('Members')
                                          .doc(member['uniqueID'])
                                          .delete();

                                      // Refresh the member list
                                      await memberProvider.fetchMembers();

                                      if (context.mounted) {
                                        FlushbarHelper.showSuccess(
                                            "Member deleted successfully",
                                            context);
                                      }
                                    } catch (e) {
                                      debugPrint("Error deleting member: $e");

                                      // Small delay before showing error message
                                      await Future.delayed(
                                          const Duration(milliseconds: 100));

                                      if (context.mounted) {
                                        FlushbarHelper.showError(
                                            "Failed to delete member", context);
                                      }
                                    }
                                  }
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
          onPressed: () async {
            // Navigate and wait for result
            final result = await Navigator.pushNamed(context, Routes.Addmember);

            // If a member was added successfully, refresh the list
            if (result == true) {
              FlushbarHelper.showSuccess("Member added successfully", context);
              final memberProvider =
                  Provider.of<MemberProvider>(context, listen: false);
              await memberProvider.fetchMembers();
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),

        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: primerycolor,
        //   shape: const CircleBorder(),
        //   onPressed: () {
        //     Navigator.pushNamed(context, Routes.Addmember);
        //   },
        //   child: const Icon(Icons.add, color: Colors.white),
        // ),
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
                Text("Login QR Code for ${member["name"]}",
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
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQrWebDilog(Map<String, dynamic> member) {
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
                Text("QR Code for Web Profile of ${member["name"]}",
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
                      data:
                          "https://umno.web.app/#/${member["membershipNumber"]}",
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      size: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
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
                            vertical: 12, horizontal: 5),
                      ),
                      onPressed: () async {
                        try {
                          RenderRepaintBoundary boundary = qrKey.currentContext!
                              .findRenderObject() as RenderRepaintBoundary;
                          ui.Image image =
                              await boundary.toImage(pixelRatio: 3.0);
                          ByteData? byteData = await image.toByteData(
                              format: ui.ImageByteFormat.png);
                          Uint8List pngBytes = byteData!.buffer.asUint8List();

                          final tempDir = await getTemporaryDirectory();
                          final file =
                              await File('${tempDir.path}/qr.png').create();
                          await file.writeAsBytes(pngBytes);

                          await Share.shareXFiles([XFile(file.path)],
                              text:
                                  "Profile Link for Member ${member["name"]} is:\nhttps://umno.web.app/#/${member["membershipNumber"]}");
                        } catch (e) {
                          debugPrint("Error sharing QR image: $e");
                        }
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      label: const Text("Copy Profile URL",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primerycolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 5),
                      ),
                      onPressed: () async {
                        try {
                          await Clipboard.setData(
                            ClipboardData(
                                text:
                                    "https://umno.web.app/#/${member["membershipNumber"]}"),
                          );
                          FlushbarHelper.showSuccess(
                              "URL Copied of Member ${member["membershipNumber"]}",
                              context);
                        } catch (e) {
                          debugPrint("Error sharing QR image: $e");
                          FlushbarHelper.showError(
                              "Something went wrong, please Try agian.",
                              context);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// Single card shimmer (compact version)
class CustomCardShimmer extends StatelessWidget {
  final int detailsCount;
  final int iconsCount;

  const CustomCardShimmer({
    super.key,
    this.detailsCount = 3,
    this.iconsCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile + Details Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar placeholder
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details placeholders
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title placeholder
                        Container(
                          height: 20,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Detail lines
                        ...List.generate(detailsCount, (index) {
                          double width = [180.0, 160.0, 120.0][index % 3];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Container(
                              height: 16,
                              width: width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Icon Row placeholders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(iconsCount, (index) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// List of multiple shimmer cards
class CustomCardShimmerList extends StatelessWidget {
  final int itemCount;
  final int detailsCount;
  final int iconsCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const CustomCardShimmerList({
    super.key,
    this.itemCount = 4,
    this.detailsCount = 3,
    this.iconsCount = 3,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return CustomCardShimmer(
          detailsCount: detailsCount,
          iconsCount: iconsCount,
        );
      },
    );
  }
}
