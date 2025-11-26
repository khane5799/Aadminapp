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

  Future<bool> isMembershipAvailable(String membershipNumber) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Members")
          .where("membershipNumber", isEqualTo: membershipNumber)
          .limit(1)
          .get();

      return snapshot.docs.isEmpty; // ✅ true means available
    } catch (e) {
      debugPrint("❌ Error checking membership number: $e");
      return false; // safer: block if error
    }
  }

  Future<String> getNextMembershipNumber() async {
    final membersRef = FirebaseFirestore.instance.collection("Members");
    final snapshot = await membersRef.get();

    int maxNumber = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final membershipNumber = data["membershipNumber"] ?? "";

      if (membershipNumber.startsWith("UMNO-")) {
        final numberPart =
            int.tryParse(membershipNumber.replaceAll("UMNO-", ""));
        if (numberPart != null && numberPart > maxNumber) {
          maxNumber = numberPart;
        }
      }
    }

    final newNumber = maxNumber + 1;

    // Pad with leading zeros (optional, 4 digits)
    final paddedNumber = newNumber.toString().padLeft(4, '0');

    print("📦 New membership number generated: UMNO-$paddedNumber");

    return "UMNO-$paddedNumber";
  }

  /// Generate a unique ID (can use timestamp + random string)
  String generateUniqueID() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomStr = String.fromCharCodes(
        List.generate(5, (index) => Random().nextInt(26) + 65)); // A-Z
    return "$timestamp$randomStr";
  }

  Future<bool> addMember({
    required BuildContext context,
    required String name,
    required String membershipNumber,
    required String division,
    required String state,
    required String position,
    required String facebook,
    required String tikTok,
    required String instagram,
    required String twitter,
    required String whatsapp,
    String? photoUrl,
    // 🟢 Added the previously commented fields
    required String idCard,
    required String dob,
    required String phone,
    required String address,
    required String email,
    required String occupation,
    required String city,
    required String branch,
    required String postcode,
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
        "tiktok": tikTok,
        "referralPoints": 0,
        "EventPoints": 0,
        "instagram": instagram,
        "twitter": twitter,
        "whatsapp": whatsapp,
        "uniqueID": uniqueID,
        "createdAt": DateTime.now(),
        'photoUrl': photoUrl ?? '',
        "idCard": idCard.trim(),
        "dob": dob,
        "phone": phone,
        "address": address,
        "email": email.trim(),
        "occupation": occupation,
        "city": city,
        "branch": branch,
        "postcode": postcode,
        /*
        idCard": idController.text.trim(),
        "dob": dobController.text.trim(),
        "phone": phoneController.text.trim(),
        "address": addressController.text.trim(),
        "email": emailController.text.trim(),
        "occupation": occupationController.text.trim(),
        "city": cityController.text.trim(),
        "branch": branchController.text.trim(),
        "postcode": postcodeController.text.trim(),



         */
      };

      await FirebaseFirestore.instance
          .collection("Members")
          .doc(uniqueID) // use uniqueID as doc ID
          .set(memberData);
      return true; // ✅ Success

      // FlushbarHelper.showSuccess("Member added successfully", context);
    } catch (e) {
      FlushbarHelper.showError("Error adding member: $e", context);
      return false; // ❌ Failure
    } finally {
      // ✅ Always stop the loading state
      _setLoading(false);
    }
  }
}
