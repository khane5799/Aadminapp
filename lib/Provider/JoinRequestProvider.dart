// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class JoinRequestsProvider extends ChangeNotifier {
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   /// ✅ Generate Unique ID
//   String generateUniqueID() {
//     final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//     final randomStr = String.fromCharCodes(
//       List.generate(5, (index) => Random().nextInt(26) + 65), // A-Z letters
//     );
//     return "$timestamp$randomStr";
//   }

//   /// ✅ Generate Next Membership Number
//   Future<String> getNextMembershipNumber() async {
//     final membersRef = FirebaseFirestore.instance.collection("Members");
//     final snapshot = await membersRef.get();

//     int maxNumber = 0;
//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       final membershipNumber = data["membershipNumber"] ?? "";
//       if (membershipNumber.startsWith("UMNO")) {
//         final numberPart =
//             int.tryParse(membershipNumber.replaceAll("UMNO", ""));
//         if (numberPart != null && numberPart > maxNumber) {
//           maxNumber = numberPart;
//         }
//       }
//     }

//     final newNumber = maxNumber + 1;
//     debugPrint("📦 New membership number generated: UMNO$newNumber");
//     return "UMNO$newNumber";
//   }

//   /// ✅ Update Status + Add Member
//   Future<Map<String, dynamic>?> updateStatus(
//     BuildContext context,
//     String docId,
//     String status,
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       _setLoading(true);

//       final uniqueID = generateUniqueID();
//       final membershipNumber = await getNextMembershipNumber();

//       await FirebaseFirestore.instance
//           .collection("membershipApplications")
//           .doc(docId)
//           .update({"status": status});

//       if (status == "approved") {
//         final membersRef = FirebaseFirestore.instance.collection("Members");
//         final memberData = {
//           "uniqueID": uniqueID,
//           "membershipNumber": membershipNumber,
//           "name": data["name"] ?? "",
//           "photoUrl": data["photoUrl"] ?? "",
//           "position": data["position"] ?? "",
//           "state": data["state"] ?? "",
//           "division": data["division"] ?? "",
//           "points": data["points"] ?? 0,
//           "facebook": data["facebook"] ?? "",
//           "instagram": data["instagram"] ?? "",
//           "twitter": data["twitter"] ?? "",
//           "whatsapp": data["whatsapp"] ?? "",
//           "createdAt": DateTime.now(),
//           "referral": data["referral"] ?? "",
//         };

//         await membersRef.doc(uniqueID).set(memberData);

//         // ✅ Handle Referral Reward
//         final referralNumber = data["referral"];
//         if (referralNumber != null && referralNumber.toString().isNotEmpty) {
//           final refSnapshot = await membersRef
//               .where("membershipNumber", isEqualTo: referralNumber)
//               .limit(1)
//               .get();

//           if (refSnapshot.docs.isNotEmpty) {
//             final refDoc = refSnapshot.docs.first;
//             final refUniqueID = refDoc["uniqueID"];
//             final refPoints = (refDoc["points"] ?? 0) + 10;

//             await membersRef.doc(refUniqueID).update({"points": refPoints});

//             debugPrint(
//                 "🎉 Referral reward: $refUniqueID got +10 points (Total: $refPoints)");
//           } else {
//             debugPrint("⚠️ Referral membershipNumber $referralNumber not found.");
//           }
//         }

//         _setLoading(false);
//         return memberData; // 🔑 return new member data to show QR
//       } else {
//         _setLoading(false);
//         return null;
//       }
//     } catch (e, st) {
//       debugPrint("❌ ERROR in updateStatus: $e");
//       debugPrint(st.toString());
//       _setLoading(false);
//       return null;
//     }
//   }
// }
