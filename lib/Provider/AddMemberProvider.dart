import 'dart:math';

import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMemberProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  /// Generate a unique ID (can use timestamp + random string)
  String generateUniqueID() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomStr = String.fromCharCodes(
        List.generate(5, (index) => Random().nextInt(26) + 65)); // A-Z
    return "$timestamp$randomStr";
  }

  Future<void> addMember({
    required BuildContext context,
    required String name,
    required String membershipNumber,
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
      final uniqueID = generateUniqueID();

      final memberData = {
        "name": name,
        "membershipNumber": membershipNumber,
        "division": division,
        "state": state,
        "points": 0,
        "position": position,
        "facebook": facebook,
        "instagram": instagram,
        "twitter": twitter,
        "whatsapp": whatsapp,
        "uniqueID": uniqueID,
        "createdAt": DateTime.now(),
        'photoUrl': '',
      };

      await FirebaseFirestore.instance
          .collection("Members")
          .doc(uniqueID) // use uniqueID as doc ID
          .set(memberData);

      FlushbarHelper.showSuccess("Member added successfully", context);
    } catch (e) {
      FlushbarHelper.showError("Error adding member: $e", context);
    }

    _setLoading(false);
  }
}
