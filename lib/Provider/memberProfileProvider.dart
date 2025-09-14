import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';

class MemberProfileProvider extends ChangeNotifier {
  final cloudinary =
      CloudinaryPublic('dhpq5ao2s', 'flutter_profiles', cache: false);

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String _photoUrl = '';
  String get photoUrl => _photoUrl;

  // Controllers
  final nameController = TextEditingController();
  final membershipController = TextEditingController();
  final divisionController = TextEditingController();
  final stateController = TextEditingController();
  final positionController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final twitterController = TextEditingController();
  final whatsappController = TextEditingController();

  Map<String, dynamic> _memberData = {};
  Map<String, dynamic>? get memberData => _memberData;

  // Initialize data
  void initData(Map<String, dynamic> data) {
    _memberData = data;
    _photoUrl = data['photoUrl']?.toString() ?? '';
    debugPrint("🔥 Member data received in Provider: $_memberData");
    debugPrint("🔥 Initial photoUrl: $_photoUrl");

    nameController.text = data['name']?.toString() ?? '';
    membershipController.text = data['membershipNumber']?.toString() ??
        data['membershipCode']?.toString() ??
        '';
    divisionController.text = data['division']?.toString() ?? '';
    stateController.text = data['state']?.toString() ?? '';
    positionController.text = data['position']?.toString() ?? '';
    facebookController.text = data['facebook']?.toString() ?? '';
    instagramController.text = data['instagram']?.toString() ?? '';
    twitterController.text = data['twitter']?.toString() ?? '';
    whatsappController.text = data['whatsapp']?.toString() ?? '';

    notifyListeners();
  }

  // Reset fields to original values
  void resetProfile() {
    initData(_memberData);
  }

  // Pick & Upload Image
  Future<void> uploadProfileImage(String path, BuildContext context) async {
    _isUploading = true;
    notifyListeners();

    try {
      final res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(path,
            resourceType: CloudinaryResourceType.Image, folder: 'profile_pics'),
      );

      _photoUrl = res.secureUrl;
      FlushbarHelper.showSuccess(
          "Profile Image uploaded successfully", context);
      debugPrint("✅ Uploaded photoUrl: $_photoUrl");

      // TODO: Save photoUrl to Firestore
    } on CloudinaryException catch (e) {
      FlushbarHelper.showError("Image upload failed: ${e.message}", context);
      debugPrint("❌ Cloudinary error: ${e.message}");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Update profile (Firestore logic should be here)
// In your Provider - Comment out FlushbarHelper temporarily
  Future<bool> updateProfile(BuildContext context) async {
    final uniqueID = _memberData['uniqueID']?.toString() ?? '';

    if (uniqueID.isEmpty) {
      FlushbarHelper.showError("Something went wrong...", context);
      debugPrint("❌ uniqueID is missing, cannot update Firestore.");
      return false;
    }

    final updatedData = {
      'name': nameController.text.trim(),
      'membershipNumber': membershipController.text.trim(),
      'division': divisionController.text.trim(),
      'state': stateController.text.trim(),
      'position': positionController.text.trim(),
      'facebook': facebookController.text.trim(),
      'instagram': instagramController.text.trim(),
      'twitter': twitterController.text.trim(),
      'whatsapp': whatsappController.text.trim(),
      'photoUrl': _photoUrl,
      'uniqueID': uniqueID,
      'points': _memberData['points'],
    };

    debugPrint("🚀 Updating profile for $uniqueID");
    debugPrint("📤 Data: $updatedData");

    try {
      await FirebaseFirestore.instance
          .collection("Members")
          .doc(uniqueID)
          .update(updatedData);

      debugPrint("✅ Firestore updated successfully");

      // Update local data
      _memberData = {..._memberData, ...updatedData};

      // COMMENT OUT THIS LINE TEMPORARILY
      // FlushbarHelper.showSuccess("Profile updated successfully", context);

      return true;
    } catch (e) {
      debugPrint("❌ Firestore update failed: $e");
      FlushbarHelper.showError("Failed to update profile: $e", context);
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    membershipController.dispose();
    divisionController.dispose();
    stateController.dispose();
    positionController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    twitterController.dispose();
    whatsappController.dispose();
    super.dispose();
  }
}
