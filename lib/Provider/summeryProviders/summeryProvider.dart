// // lib/providers/summary_provider.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';

// class SummaryProvider extends ChangeNotifier {
//   Map<String, int> eventsPerMonth = {};
//   bool isEventsLoading = false;
//   String? eventsError;

//   bool isTopOverallLoading = false;
//   bool isTopReferralLoading = false;
//   bool isTopEventPointsLoading = false;

//   List<Map<String, dynamic>> topOverall = [];
//   List<Map<String, dynamic>> topReferrals = [];
//   List<Map<String, dynamic>> topEventPoints = [];

//   String? topOverallError;
//   String? topReferralsError;
//   String? topEventPointsError;

//   SummaryProvider() {
//     // auto-load when provider is created
//     fetchEventsPerMonth();
//     fetchTopOverall();
//     fetchTopReferrals();
//     fetchTopEventPoints();
//   }

//   // 🔹 Month name helper
//   String _getMonthName(int month) {
//     const months = [
//       "Jan", "Feb", "Mar", "Apr", "May", "Jun",
//       "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
//     ];
//     return months[month - 1];
//   }

//   // 🔹 Events Per Month
//   Future<void> fetchEventsPerMonth() async {
//     try {
//       isEventsLoading = true;
//       eventsError = null;
//       notifyListeners();

//       final snapshot =
//           await FirebaseFirestore.instance.collection("events").get();

//       Map<String, int> monthlyCount = {
//         "Jan": 0,
//         "Feb": 0,
//         "Mar": 0,
//         "Apr": 0,
//         "May": 0,
//         "Jun": 0,
//         "Jul": 0,
//         "Aug": 0,
//         "Sep": 0,
//         "Oct": 0,
//         "Nov": 0,
//         "Dec": 0,
//       };

//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         if (data["date"] != null) {
//           DateTime eventDate;

//           if (data["date"] is Timestamp) {
//             eventDate = (data["date"] as Timestamp).toDate();
//           } else if (data["date"] is DateTime) {
//             eventDate = data["date"];
//           } else {
//             continue; // skip invalid date
//           }

//           final monthName = _getMonthName(eventDate.month);
//           monthlyCount[monthName] = (monthlyCount[monthName] ?? 0) + 1;
//         }
//       }

//       eventsPerMonth = monthlyCount;
//     } catch (e) {
//       eventsError = e.toString();
//     } finally {
//       isEventsLoading = false;
//       notifyListeners();
//     }
//   }

//   // 🔹 Top Overall Points
//   Future<void> fetchTopOverall() async {
//     try {
//       isTopOverallLoading = true;
//       topOverallError = null;
//       notifyListeners();

//       final snapshot = await FirebaseFirestore.instance
//           .collection("Members")
//           .where("points", isGreaterThan: 0)
//           .orderBy("points", descending: true)
//           .limit(5)
//           .get();

//       topOverall = snapshot.docs
//           .map((doc) => {
//                 "photoUrl": doc["photoUrl"],
//                 "name": doc["name"],
//                 "points": doc["points"],
//               })
//           .toList();
//     } catch (e) {
//       topOverallError = e.toString();
//     } finally {
//       isTopOverallLoading = false;
//       notifyListeners();
//     }
//   }

//   // 🔹 Top Referral Points
//   Future<void> fetchTopReferrals() async {
//     try {
//       isTopReferralLoading = true;
//       topReferralsError = null;
//       notifyListeners();

//       final snapshot = await FirebaseFirestore.instance
//           .collection("Members")
//           .where("referralPoints", isGreaterThan: 0)
//           .orderBy("referralPoints", descending: true)
//           .limit(5)
//           .get();

//       topReferrals = snapshot.docs
//           .map((doc) => {
//                 "photoUrl": doc["photoUrl"],
//                 "name": doc["name"],
//                 "referralPoints": doc["referralPoints"],
//               })
//           .toList();
//     } catch (e) {
//       topReferralsError = e.toString();
//     } finally {
//       isTopReferralLoading = false;
//       notifyListeners();
//     }
//   }

//   // 🔹 Top Event Points
//   Future<void> fetchTopEventPoints() async {
//     try {
//       isTopEventPointsLoading = true;
//       topEventPointsError = null;
//       notifyListeners();

//       final snapshot = await FirebaseFirestore.instance
//           .collection("Members")
//           .where("EventPoints", isGreaterThan: 0)
//           .orderBy("EventPoints", descending: true)
//           .limit(5)
//           .get();

//       topEventPoints = snapshot.docs
//           .map((doc) => {
//                 "photoUrl": doc["photoUrl"],
//                 "name": doc["name"],
//                 "eventPoints": doc["EventPoints"],
//               })
//           .toList();
//     } catch (e) {
//       topEventPointsError = e.toString();
//     } finally {
//       isTopEventPointsLoading = false;
//       notifyListeners();
//     }
//   }
// }
