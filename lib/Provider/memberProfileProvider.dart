// file: providers/member_profile_provider.dart
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  /// Update member profile in Firestore
  Future<void> updateMemberProfile({
    required BuildContext context,
    required String uniqueID,
    required String memberShipNumber,
    required String name,
    required String division,
    required String state,
    required String position,
    required String facebook,
    required String instagram,
    required String twitter,
    required String whatsapp,
  }) async {
    _setLoading(true);
    try {
      if (uniqueID.isEmpty) {
        FlushbarHelper.showError("Invalid member ID", context);
        _setLoading(false);
        return;
      }

      await FirebaseFirestore.instance
          .collection("Members")
          .doc(uniqueID)
          .update({
        "name": name,
        "division": division,
        "state": state,
        "membershipNumber": memberShipNumber,
        "position": position,
        "facebook": facebook,
        "instagram": instagram,
        "twitter": twitter,
        "whatsapp": whatsapp,
      });

      FlushbarHelper.showSuccess("Profile updated successfully!", context);
    } catch (e) {
      FlushbarHelper.showError("Failed to update profile: $e", context);
    }
    _setLoading(false);
  }
}
