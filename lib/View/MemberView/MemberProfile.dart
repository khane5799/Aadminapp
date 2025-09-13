import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/memberProfileProvider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
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
  final _cloudinary = CloudinaryPublic('dhpq5ao2s', 'flutter_profiles',
      cache: false); //where are these values?

  bool _isUploading = false;
  String photoUrl = '';

  Future<void> _pickAndUpload() async {
    final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final res = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(picked.path,
            resourceType: CloudinaryResourceType.Image, folder: 'profile_pics'),
      );
      setState(() {
        photoUrl = res.secureUrl; // <-- store this in your DB / user profile
      });
      // Optionally: save photoUrl to Firestore or your backend here.
    } on CloudinaryException catch (e) {
      debugPrint('Cloudinary error: ${e.message}');
      // handle error (show toast)
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Controllers
  final _nameController = TextEditingController();
  final _membershipController = TextEditingController();
  final _divisionController = TextEditingController();
  final _stateController = TextEditingController();
  final _positionController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _whatsappController = TextEditingController();

  @override
  void initState() {
    super.initState();
    photoUrl = widget.memberData['photoUrl']?.toString() ?? '';
    debugPrint("🔥 __________photoUrl received:______________ $photoUrl");
    debugPrint("🔥 MemberData received: ${widget.memberData}");
    _populateControllers(); // Populate controllers immediately
  }

  void _populateControllers() {
    final data = widget.memberData;

    _nameController.text = data['name']?.toString() ?? '';
    _membershipController.text = data['membershipNumber']?.toString() ??
        data['membershipCode']?.toString() ??
        '';
    _divisionController.text = data['division']?.toString() ?? '';
    _stateController.text = data['state']?.toString() ?? '';
    _positionController.text = data['position']?.toString() ?? '';
    _facebookController.text = data['facebook']?.toString() ?? '';
    _instagramController.text = data['instagram']?.toString() ?? '';
    _twitterController.text = data['twitter']?.toString() ?? '';
    _whatsappController.text = data['whatsapp']?.toString() ?? '';
    setState(() {}); // Update UI
    debugPrint("Populating with data: $data");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _membershipController.dispose();
    _divisionController.dispose();
    _stateController.dispose();
    _positionController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _resetProfile() {
    setState(() {
      _populateControllers();
    });
  }

  Future<void> _updateProfile() async {
    final provider = Provider.of<MemberProfileProvider>(context, listen: false);

    final uniqueID = widget.memberData['uniqueID']?.toString() ?? '';
    provider.updateMemberProfile(
      context: context,
      uniqueID: uniqueID,
      name: _nameController.text.trim(),
      memberShipNumber: _membershipController.text.trim(),
      division: _divisionController.text.trim(),
      state: _stateController.text.trim(),
      position: _positionController.text.trim(),
      facebook: _facebookController.text.trim(),
      instagram: _instagramController.text.trim(),
      twitter: _twitterController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.memberData;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetProfile,
              tooltip: 'Reset Profile',
            ),
            const SizedBox(width: 20)
          ],
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
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickAndUpload,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: (!_isUploading &&
                                    photoUrl.isNotEmpty)
                                ? NetworkImage(photoUrl)
                                : const AssetImage('assets/images/women.jpg')
                                    as ImageProvider,
                            backgroundColor: Colors.grey[300],
                            child: _isUploading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(
                                            0xFF0B3C86)), // ✅ your primerycolor
                                  )
                                : const Align(
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
                          ),
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Points',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
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
                  ),
                  const SizedBox(height: 24),
                  // Personal Information Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3C86),
                            ),
                          ),
                          const Divider(height: 24),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _membershipController,
                            decoration: const InputDecoration(
                              labelText: 'Membership Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Organization Information Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Organization Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3C86),
                            ),
                          ),
                          const Divider(height: 24),
                          TextField(
                            controller: _divisionController,
                            decoration: const InputDecoration(
                              labelText: 'Division',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _positionController,
                            decoration: const InputDecoration(
                              labelText: 'Position',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Social Media Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Social Media',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3C86),
                            ),
                          ),
                          const Divider(height: 24),
                          _buildEditableSocialRow(
                              'Facebook',
                              _facebookController,
                              "assets/images/Facebook.jpg"),
                          const SizedBox(height: 12),
                          _buildEditableSocialRow(
                              'Instagram',
                              _instagramController,
                              "assets/images/Instagram.jpg"),
                          const SizedBox(height: 12),
                          _buildEditableSocialRow('X (Twitter)',
                              _twitterController, "assets/images/X.jpg"),
                          const SizedBox(height: 12),
                          _buildEditableSocialRow(
                              'WhatsApp',
                              _whatsappController,
                              "assets/images/Whatsapp.jpg"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Additional Information
                  // Card(
                  //   elevation: 3,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(16.0),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         const Text(
                  //           'Additional Information',
                  //           style: TextStyle(
                  //             fontSize: 18,
                  //             fontWeight: FontWeight.bold,
                  //             color: Color(0xFF0B3C86),
                  //           ),
                  //         ),
                  //         const Divider(height: 24),
                  //         ListTile(
                  //           leading:  Icon(Icons.fingerprint,
                  //               color: primerycolor),
                  //           title: const Text('Unique ID'),
                  //           subtitle: Text(data['uniqueID'] ?? 'N/A'),
                  //         ),
                  //         ListTile(
                  //           leading:  Icon(Icons.calendar_today,
                  //               color: primerycolor),
                  //           title: const Text('Member Since'),
                  //           subtitle: Text(
                  //             data['createdAt'] != null
                  //                 ? '${(data['createdAt'] as dynamic).toDate()}'
                  //                     .split(' ')[0]
                  //                 : 'N/A',
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B3C86),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetProfile,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableSocialRow(
      String platform, TextEditingController controller, String assetPath) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            assetPath,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
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
