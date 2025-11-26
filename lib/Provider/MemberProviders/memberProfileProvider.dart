import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';

class MemberProfileProvider extends ChangeNotifier {
  final cloudinary =
      CloudinaryPublic('dhpq5ao2s', 'flutter_profiles', cache: false);

  bool _isUploading = false;
  bool get isUploading => _isUploading;
  int _points = 0;
  int get points => _points;

  String _photoUrl = '';
  String get photoUrl => _photoUrl;

  // Controllers
  final nameController = TextEditingController();
  final membershipController = TextEditingController();
  final divisionController = TextEditingController();
  final stateController = TextEditingController();
  final positionController = TextEditingController();
  final facebookController = TextEditingController();
  final tikTokController = TextEditingController();
  final instagramController = TextEditingController();
  final twitterController = TextEditingController();
  final whatsappController = TextEditingController();
  // 🟢 Additional controllers for new fields
  final idCardController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final occupationController = TextEditingController();
  final cityController = TextEditingController();
  final branchController = TextEditingController();
  final postcodeController = TextEditingController();

  Map<String, dynamic> _memberData = {};
  Map<String, dynamic>? get memberData => _memberData;

  // Initialize data
  void initData(Map<String, dynamic> data) {
    _memberData = data;
    _points = data['points'] is int ? data['points'] : 0;
    _photoUrl = data['photoUrl']?.toString() ?? '';

    debugPrint("🔥 Member data received in Provider: $_memberData");
    debugPrint(
        "🔥 TikTok value from Firestore: '${data['tiktok']}'"); // Add this line
    debugPrint("🔥 Initial photoUrl: $_photoUrl");

    nameController.text = data['name']?.toString() ?? '';
    membershipController.text = data['membershipNumber']?.toString() ??
        data['membershipCode']?.toString() ??
        '';
    divisionController.text = data['division']?.toString() ?? '';
    stateController.text = data['state']?.toString() ?? '';
    positionController.text = data['position']?.toString() ?? '';
    facebookController.text = data['facebook']?.toString() ?? '';
    tikTokController.text = data['tiktok']?.toString() ?? '';
    debugPrint(
        "🔥 TikTok controller after init: '${tikTokController.text}'"); // Add this line
    instagramController.text = data['instagram']?.toString() ?? '';
    twitterController.text = data['twitter']?.toString() ?? '';
    whatsappController.text = data['whatsapp']?.toString() ?? '';
    // 🟢 New fields
    idCardController.text = data['idCard']?.toString() ?? '';
    dobController.text = data['dob']?.toString() ?? '';
    phoneController.text = data['phone']?.toString() ?? '';
    addressController.text = data['address']?.toString() ?? '';
    emailController.text = data['email']?.toString() ?? '';
    occupationController.text = data['occupation']?.toString() ?? '';
    cityController.text = data['city']?.toString() ?? '';
    branchController.text = data['branch']?.toString() ?? '';
    postcodeController.text = data['postcode']?.toString() ?? '';

    notifyListeners();
  }

  // Reset fields to original values
  void resetProfile() {
    initData(_memberData);
  }

  // Pick & Upload Image
  Future<String?> uploadandGetUrl(String path, BuildContext context) async {
    _isUploading = true;
    notifyListeners();

    try {
      final res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'profile_pics',
        ),
      );

      _photoUrl = res.secureUrl;

      // Update local memberData immediately
      _memberData['photoUrl'] = _photoUrl;

      FlushbarHelper.showSuccess(
          "Profile Image uploaded successfully", context);
      debugPrint("✅ Uploaded photoUrl: $_photoUrl");

      // Auto-save the photo URL to Firestore
      await _updatePhotoUrlInFirestore();

      return _photoUrl; // ✅ return Cloudinary URL
    } on CloudinaryException catch (e) {
      FlushbarHelper.showError("Image upload failed: ${e.message}", context);
      debugPrint("❌ Cloudinary error: ${e.message}");
      return null; // return null on failure
    } finally {
      _isUploading = false;
      notifyListeners();
    }
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

      // Update local memberData immediately
      _memberData['photoUrl'] = _photoUrl;

      FlushbarHelper.showSuccess(
          "Profile Image uploaded successfully", context);
      debugPrint("✅ Uploaded photoUrl: $_photoUrl");

      // Auto-save the photo URL to Firestore
      await _updatePhotoUrlInFirestore();
    } on CloudinaryException catch (e) {
      FlushbarHelper.showError("Image upload failed: ${e.message}", context);
      debugPrint("❌ Cloudinary error: ${e.message}");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Helper method to update only photo URL in Firestore
  Future<void> _updatePhotoUrlInFirestore() async {
    final uniqueID = _memberData['uniqueID']?.toString() ?? '';

    if (uniqueID.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection("Members")
            .doc(uniqueID)
            .update({'photoUrl': _photoUrl});
        debugPrint("✅ Photo URL updated in Firestore");
      } catch (e) {
        debugPrint("❌ Failed to update photo URL in Firestore: $e");
      }
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
    debugPrint("🔥 TikTok value before saving: ${tikTokController.text}");

    final updatedData = {
      'name': nameController.text.trim(),
      'membershipNumber': membershipController.text.trim(),
      'division': divisionController.text.trim(),
      'state': stateController.text.trim(),
      'position': positionController.text.trim(),
      'facebook': facebookController.text.trim(),
      'tiktok': tikTokController.text.trim(),
      'instagram': instagramController.text.trim(),
      'twitter': twitterController.text.trim(),
      'whatsapp': whatsappController.text.trim(),
      'photoUrl': _photoUrl,
      'uniqueID': uniqueID,
      'points': _memberData['points'],
      // 🟢 Include new fields
      'idCard': idCardController.text.trim(),
      'dob': dobController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'email': emailController.text.trim(),
      'occupation': occupationController.text.trim(),
      'city': cityController.text.trim(),
      'branch': branchController.text.trim(),
      'postcode': postcodeController.text.trim(),
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
    tikTokController.dispose();
    instagramController.dispose();
    twitterController.dispose();
    whatsappController.dispose();
    // 🟢
    idCardController.dispose();
    dobController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    occupationController.dispose();
    cityController.dispose();
    branchController.dispose();
    postcodeController.dispose();

    super.dispose();
  }
}
