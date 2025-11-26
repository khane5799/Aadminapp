// // lib/widgets/shimmer/top_members_shimmer.dart
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:adminapp/Constents/Colors.dart';

// class TopMembersShimmer extends StatelessWidget {
//   const TopMembersShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 160,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: 5,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           return Shimmer.fromColors(
//             baseColor: Colors.grey.shade300,
//             highlightColor: Colors.grey.shade100,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
//                 child: Container(
//                   width: 160,
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         primerycolor.withOpacity(0.5),
//                         secondaryColor.withOpacity(0.5),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: Colors.white24),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 10,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: 28,
//                         backgroundColor: Colors.grey.shade300,
//                       ),
//                       const SizedBox(height: 10),
//                       Container(
//                         height: 14,
//                         width: 80,
//                         color: Colors.grey.shade300,
//                       ),
//                       const SizedBox(height: 6),
//                       Container(
//                         height: 12,
//                         width: 50,
//                         color: Colors.grey.shade300,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
