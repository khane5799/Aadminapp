// Screens

import 'package:adminapp/Routes/routes.dart';
import 'package:adminapp/View/Dashboard.dart';
import 'package:adminapp/View/Events.dart';
import 'package:adminapp/View/Login.dart';
import 'package:adminapp/View/MemberView/AddMember.dart';
import 'package:adminapp/View/MemberView/Member.dart';
import 'package:adminapp/View/MemberView/MemberProfile.dart';
import 'package:adminapp/View/Summery/Summery.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case Routes.Addmember:
        return MaterialPageRoute(builder: (_) => const Addmember());

      case Routes.MemberPage:
        return MaterialPageRoute(builder: (_) => const MemberPage());
//  final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//             builder: (_) => ComplaintViewer(
//                   complaintId: args['complaintId'],
//                 ));

      case Routes.MemberProfileScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MemberProfileScreen(memberData: args),
        );

      case Routes.DashboardScreen:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case Routes.EventsPage:
        return MaterialPageRoute(builder: (_) => const EventsPage());
      case Routes.SummaryPage:
        return MaterialPageRoute(builder: (_) => const SummaryPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404: Page Not Found')),
          ),
        );
    }
  }
}
