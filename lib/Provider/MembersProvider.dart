import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> get members => _members;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool val) {
    _isLoading = val;
    // Delay notifyListeners until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Fetch members from Firestore
  Future<void> fetchMembers() async {
    _setLoading(true);

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("Members").get();

      _members = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "name": data["name"] ?? "",
          "membershipNumber": data["membershipNumber"] ?? "",
          "division": data["division"] ?? "",
          "position": data["position"] ?? "",
          "points": data["points"] ?? 0,
          "photoUrl": data["photoUrl"] ?? 0,
          "uniqueID": data["uniqueID"] ?? "",
          "createdAt": data["createdAt"] ?? "",
          "facebook": data["facebook"] ?? "",
          "instagram": data["instagram"] ?? "",
          "state": data["state"] ?? "",
          "twitter": data["twitter"] ?? "",
          "whatsapp": data["whatsapp"] ?? "",
        };
      }).toList();
    } catch (e) {
      debugPrint("Error fetching members: $e");
      _members = [];
    }

    _setLoading(false);
  }

  /// Search filter
  List<Map<String, dynamic>> filterMembers(String query) {
    if (query.isEmpty) return _members;

    final queryLower = query.toLowerCase();
    return _members.where((member) {
      final name = member["name"].toString().toLowerCase();
      final code = member["membershipCode"].toString().toLowerCase();
      return name.contains(queryLower) || code.contains(queryLower);
    }).toList();
  }
}
