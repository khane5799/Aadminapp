import 'dart:io';

import 'package:adminapp/Constents/Colors.dart';
import 'package:flutter/material.dart';

class Addmember extends StatefulWidget {
  const Addmember({super.key});

  @override
  State<Addmember> createState() => _AddmemberState();
}

class _AddmemberState extends State<Addmember> {
  File? _profileImage;

  // Controllers with dummy data
  final _nameController = TextEditingController();
  final _membershipController = TextEditingController();
  final _divisionController = TextEditingController();
  final _stateController = TextEditingController();
  final _positionController = TextEditingController();

  // Social controllers with dummy data
  final _facebookController = TextEditingController();
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

  void _resetProfile() {
    setState(() {
      _profileImage = null;
      _nameController.clear();
      _membershipController.clear();
      _divisionController.clear();
      _stateController.clear();
      _positionController.clear();
      _facebookController.clear();
      _instagramController.clear();
      _twitterController.clear();
      _whatsappController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Scrollable content
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
                          onTap: () {},
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage('assets/images/women.jpg')
                                    as ImageProvider,
                            backgroundColor: Colors.grey[300],
                            child: const Align(
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Points',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '1,250',
                              style: TextStyle(
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
                ],
              ),
            ),
          ),

          // Sticky Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Member Added successfully')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B3C86),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 130),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save Member'),
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
