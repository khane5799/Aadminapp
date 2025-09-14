import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/memberProfileProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
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
            "Member Profile",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
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
                          backgroundImage: (!provider.isUploading &&
                                  provider.photoUrl.isNotEmpty)
                              ? NetworkImage(provider.photoUrl)
                              : const AssetImage('assets/images/women.jpg')
                                  as ImageProvider,
                          backgroundColor: Colors.grey[300],
                          child: provider.isUploading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0B3C86),
                                  ),
                                )
                              : const Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.edit,
                                        size: 16, color: Color(0xFF0B3C86)),
                                  ),
                                ),
                        ),
                      ),
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
