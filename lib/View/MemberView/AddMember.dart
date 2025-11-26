import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/MemberProviders/AddMemberProvider.dart';
import 'package:adminapp/Provider/MemberProviders/memberProfileProvider.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:adminapp/Widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

final GlobalKey _iconKey = GlobalKey();

class Addmember extends StatefulWidget {
  const Addmember({super.key});

  @override
  State<Addmember> createState() => _AddmemberState();
}

class _AddmemberState extends State<Addmember> {
  String? _photoUrl; // keep in state
  String? _suggestedId;
  final _picker = ImagePicker();

  // Controllers
  final _nameController = TextEditingController();
  final _membershipController = TextEditingController();
  final _divisionController = TextEditingController();
  final _stateController = TextEditingController();
  final _positionController = TextEditingController();

  final _facebookController = TextEditingController();
  final _tikTokController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _whatsappController = TextEditingController();

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

  Future<String?> _pickAndUpload() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked == null) return null;

    // Upload & get URL
    final url = await context
        .read<MemberProfileProvider>()
        .uploadandGetUrl(picked.path, context);

    return url; // ✅ now you can store this in registration
  }

  @override
  Widget build(BuildContext context) {
    final addMemberProvider = Provider.of<AddMemberProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: "Create Member",
        centertitle: true,
        primerycolor: primerycolor,
        secondaryColor: secondaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Image & Points (UI unchanged)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final url = await _pickAndUpload();
                            if (url != null) {
                              setState(() {
                                _photoUrl = url;
                              });
                              debugPrint("✅ Uploaded Image URL: $url");
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Consumer<MemberProfileProvider>(
                                builder: (context, provider, _) {
                                  if (provider.isUploading) {
                                    // 🔹 Show loading indicator while uploading
                                    return CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey[300],
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFF0B3C86)),
                                      ),
                                    );
                                  }

                                  // 🔹 Show uploaded image or placeholder
                                  return CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: _photoUrl != null
                                        ? NetworkImage(_photoUrl!)
                                        : null,
                                    child: _photoUrl == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          )
                                        : null,
                                  );
                                },
                              ),
                              const Positioned(
                                bottom: 0,
                                right: 0,
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
                        ),
                        const SizedBox(width: 30),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Points',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(height: 4),
                            Text('0',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3C86))),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Personal Information',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3C86))),
                          const Divider(height: 24),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'UMNO-\d{0,4}')),
                            ],
                            controller: _membershipController,
                            decoration: InputDecoration(
                              suffixIcon: Builder(
                                builder: (iconContext) {
                                  return IconButton(
                                    onPressed: () async {
                                      final membershipNumber =
                                          await addMemberProvider
                                              .getNextMembershipNumber();
                                      _membershipController.text =
                                          membershipNumber; // auto-fill

                                      final overlay = Overlay.of(context);

                                      // find position & size of the help icon
                                      final renderBox = iconContext
                                          .findRenderObject() as RenderBox;
                                      final size = renderBox.size;
                                      final offset =
                                          renderBox.localToGlobal(Offset.zero);

                                      // 👇 define popup width (you can adjust this value)
                                      const popupWidth = 120.0;

                                      final overlayEntry = OverlayEntry(
                                        builder: (context) => Positioned(
                                          left: offset.dx +
                                              (size.width / 2) -
                                              (popupWidth / 2) -
                                              (popupWidth * 0.52),
                                          top: offset.dy + (size.height * 0.70),

                                          // left: offset.dx +
                                          //     (size.width / 2) -
                                          //     (popupWidth / 2) -
                                          //     65,
                                          // top: offset.dy + size.height - 20,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              width:
                                                  popupWidth, // 👈 make width match what we used above
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 12),
                                              decoration: const BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8),
                                                  topRight: Radius.circular(0),
                                                ),
                                              ),
                                              child: Text(
                                                "Next ID: $membershipNumber",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );

                                      overlay.insert(overlayEntry);

                                      // Auto remove after 2 seconds
                                      await Future.delayed(
                                          const Duration(seconds: 2));
                                      overlayEntry.remove();
                                    },
                                    icon: const Icon(Icons.help),
                                  );
                                },
                              ),
                              labelText: 'Membership Number',
                              border: const OutlineInputBorder(),
                            ),
                          )

                          // TextField(
                          //   controller: _membershipController,
                          //   decoration: InputDecoration(
                          //       suffixIcon: IconButton(
                          //         onPressed: () async {
                          //           final membershipNumber =
                          //               await addMemberProvider
                          //                   .getNextMembershipNumber();

                          //           debugPrint(
                          //               "Next possible ID$membershipNumber");
                          //         },
                          //         icon: const Icon(Icons.help),
                          //       ),
                          //       labelText: 'Membership Number',
                          //       border: const OutlineInputBorder()),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Organization Information
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Organization Information',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3C86))),
                          const Divider(height: 24),
                          TextField(
                            controller: _divisionController,
                            decoration: const InputDecoration(
                                labelText: 'Division',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _positionController,
                            decoration: const InputDecoration(
                                labelText: 'Position',
                                border: OutlineInputBorder()),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Social Media
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Social Media',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3C86))),
                          const Divider(height: 24),
                          _buildEditableSocialRow(
                              'Facebook',
                              _facebookController,
                              "assets/images/Facebook.jpg",
                              TextInputType.text),
                          const SizedBox(height: 12),
                          _buildEditableSocialRow('TikTok', _tikTokController,
                              "assets/images/Tiktok.jpg", TextInputType.text),
                          const SizedBox(height: 12),
                          _buildEditableSocialRow(
                              'Instagram',
                              _instagramController,
                              "assets/images/Instagram.jpg",
                              TextInputType.text),
                          const SizedBox(height: 12),
                          _buildEditableSocialRow(
                              'X (Twitter)',
                              _twitterController,
                              "assets/images/X.jpg",
                              TextInputType.text),
                          const SizedBox(height: 12),
                          _buildEditableSocialRow(
                              'WhatsApp',
                              _whatsappController,
                              "assets/images/Whatsapp.jpg",
                              TextInputType.number),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Save Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity, // 👈 makes button take full width
              child: ElevatedButton(
                onPressed: addMemberProvider.isLoading
                    ? null
                    : () async {
                        if (_membershipController.text.isNotEmpty) {
                          final isAvailable =
                              await addMemberProvider.isMembershipAvailable(
                                  _membershipController.text.trim());

                          if (!isAvailable) {
                            FlushbarHelper.showError(
                              "A Member with this ID already exists.",
                              context,
                            );
                            return;
                          }
                        }
                        final success = await addMemberProvider.addMember(
                          context: context,
                          name: _nameController.text.trim(),
                          membershipNumber: _membershipController.text.trim(),
                          division: _divisionController.text.trim(),
                          state: _stateController.text.trim(),
                          position: _positionController.text.trim(),
                          facebook: _facebookController.text.trim(),
                          tikTok: _tikTokController.text.trim(),
                          instagram: _instagramController.text.trim(),
                          twitter: _twitterController.text.trim(),
                          whatsapp: _whatsappController.text.trim(),
                          photoUrl: _photoUrl,
                          idCard: '',
                          dob: '',
                          phone: '',
                          address: '',
                          email: '',
                          occupation: '',
                          city: '',
                          branch: '',
                          postcode: '',
                        );
                        if (success) {
                          Navigator.pop(context, true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B3C86),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14), // 👈 vertical only
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: addMemberProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Member',
                        style: TextStyle(fontSize: 16), // 👈 prevent wrapping
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // just in case
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEditableSocialRow(
      String platform,
      TextEditingController controller,
      String assetPath,
      TextInputType keyboardType) {
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
            keyboardType: keyboardType,
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
