import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/MemberProviders/memberProfileProvider.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MemberProfileScreen extends StatefulWidget {
  final Map<String, dynamic> memberData;
  const MemberProfileScreen({super.key, required this.memberData});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProfileProvider>().initData(widget.memberData);
    });
  }

  Future<void> _pickAndUpload() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked != null) {
      await context
          .read<MemberProfileProvider>()
          .uploadProfileImage(picked.path, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemberProfileProvider>();
    final data = provider.memberData ?? {};

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        appBar: CustomAppBar(
          centertitle: true,
          automaticallyImplyLeading: true,
          primerycolor: primerycolor,
          secondaryColor: secondaryColor,
          title: "Member Profile",
          appbarHeight: 50,
          icon: Icons.refresh,
          ActiononTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 28),
                    SizedBox(width: 8),
                    Text("Reset Points?"),
                  ],
                ),
                content: const Text(
                  "Are you sure you want to reset the user's points to 0?",
                  style: TextStyle(fontSize: 15),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                actions: [
                  TextButton(
                    style:
                        TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Yes, Reset",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              // ✅ Show loading dialog
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              );

              try {
                debugPrint("Resetting points for: ${data['uniqueID']}");

                await FirebaseFirestore.instance
                    .collection("Members")
                    .doc(data['uniqueID'])
                    .update({
                  "points": 0,
                  "referralPoints": 0,
                });

                // Simulate a short wait for UI sync
                await Future.delayed(const Duration(seconds: 1));

                if (context.mounted) {
                  Navigator.pop(context); // close loading dialog
                  Navigator.pop(context, true); // go back and refresh parent
                }

                FlushbarHelper.showSuccess("Points reset to 0", context);
              } catch (e) {
                if (context.mounted)
                  Navigator.pop(context); // close loading if open
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to reset points: $e")),
                );
              }
            }
          },
        ),
        //   AppBar(
        //     iconTheme: const IconThemeData(color: Colors.white),
        //     flexibleSpace: Container(
        //       decoration: BoxDecoration(
        //         gradient: LinearGradient(
        //           colors: [primerycolor, secondaryColor],
        //           begin: Alignment.topLeft,
        //           end: Alignment.bottomRight,
        //         ),
        //         borderRadius: const BorderRadius.only(
        //           bottomLeft: Radius.circular(14),
        //           bottomRight: Radius.circular(14),
        //         ),
        //       ),
        //     ),
        //     backgroundColor: Colors.transparent,
        //     elevation: 4,
        //     title: const Text(
        //       "Member Profile",
        //       style: TextStyle(
        //         fontSize: 22,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Image & Points
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: _pickAndUpload,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: (!provider.isUploading &&
                                      provider.photoUrl.isNotEmpty)
                                  ? NetworkImage(provider.photoUrl)
                                  : null, // only load when photo exists
                              child: provider.isUploading
                                  ? const CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0B3C86),
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        // Person icon shown when no photo
                                        if (provider.photoUrl.isEmpty)
                                          const Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),

                                        // Pencil edit icon (always shows)
                                        const Align(
                                          alignment: Alignment.bottomRight,
                                          child: CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Color(0xFF0B3C86),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            )),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Total Points",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '${data['points'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B3C86),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Personal Information
                    _buildInfoCard("Personal Information", [
                      TextField(
                        controller: provider.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: provider.membershipController,
                        decoration: const InputDecoration(
                          labelText: 'Membership Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      //🟢New fields
                      const SizedBox(height: 16),
                      TextField(
                        controller: provider.idCardController,
                        decoration: const InputDecoration(
                          labelText: 'ID Card Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: provider.phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: provider.addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: provider.emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: provider.occupationController,
                        decoration: const InputDecoration(
                          labelText: 'Occupation',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: provider.dobController,
                        readOnly: true, // 👈 prevents keyboard from showing
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          suffixIcon:
                              Icon(Icons.calendar_today), // calendar icon
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(
                              FocusNode()); // hide keyboard if open

                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000), // default date
                            firstDate: DateTime(1900), // earliest date
                            lastDate: DateTime
                                .now(), // latest date (can't pick future)
                            builder: (context, child) {
                              // optional: add theme customization
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary:
                                        Colors.blue, // header background color
                                    onPrimary:
                                        Colors.white, // header text color
                                    onSurface: Colors.black, // body text color
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            final formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            provider.dobController.text =
                                formattedDate; // update text field
                          }
                        },
                      )
                    ]),

                    const SizedBox(height: 16),

                    // Organization Info
                    _buildInfoCard("Organization Information", [
                      TextField(
                        controller: provider.divisionController,
                        decoration: const InputDecoration(
                          labelText: 'Division',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: provider.stateController,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: provider.positionController,
                        decoration: const InputDecoration(
                          labelText: 'Position',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      //New Fields
                      const SizedBox(height: 12),
                      TextField(
                        controller: provider.cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: provider.branchController,
                        decoration: const InputDecoration(
                          labelText: 'Branch',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: provider.postcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Postcode',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Social Media
                    _buildInfoCard("Social Media", [
                      _buildEditableSocialRow(
                          "Facebook",
                          provider.facebookController,
                          "assets/images/Facebook.jpg"),
                      const SizedBox(height: 12),
                      _buildEditableSocialRow(
                          "TikTok",
                          provider.tikTokController,
                          "assets/images/Tiktok.jpg"),
                      const SizedBox(height: 12),
                      _buildEditableSocialRow(
                          "Instagram",
                          provider.instagramController,
                          "assets/images/Instagram.jpg"),
                      const SizedBox(height: 12),
                      _buildEditableSocialRow("X (Twitter)",
                          provider.twitterController, "assets/images/X.jpg"),
                      const SizedBox(height: 12),
                      _buildEditableSocialRow(
                          "WhatsApp",
                          provider.whatsappController,
                          "assets/images/Whatsapp.jpg"),
                    ]),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      // In your UI - Modified button handler with force navigation
                      onPressed: () async {
                        try {
                          debugPrint("🔄 Starting profile update...");

                          final success = await provider.updateProfile(context);

                          debugPrint("📋 Update result: $success");

                          if (success) {
                            debugPrint("🔄 Attempting to pop screen...");

                            // Try immediate navigation first
                            if (mounted && Navigator.of(context).canPop()) {
                              debugPrint("✅ Popping screen immediately...");
                              Navigator.of(context).pop(true);
                              return;
                            }

                            // If immediate doesn't work, try with delay
                            await Future.delayed(
                                const Duration(milliseconds: 100));

                            if (mounted && Navigator.of(context).canPop()) {
                              debugPrint("✅ Popping screen after delay...");
                              Navigator.of(context).pop(true);
                              return;
                            }

                            // If still doesn't work, try popUntil
                            if (mounted) {
                              debugPrint("🔄 Using popUntil...");
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          } else {
                            debugPrint("❌ Update failed, not popping screen");
                          }
                        } catch (e) {
                          debugPrint("❌ Error in button handler: $e");
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("An error occurred: $e")),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B3C86),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Save Changes"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.resetProfile,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Reset",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B3C86))),
          const Divider(height: 24),
          ...children,
        ]),
      ),
    );
  }

  Widget _buildEditableSocialRow(
      String platform, TextEditingController controller, String assetPath) {
    return Row(
      children: [
        ClipOval(
          child:
              Image.asset(assetPath, width: 36, height: 36, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: platform,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
