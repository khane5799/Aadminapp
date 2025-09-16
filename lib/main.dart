import 'package:adminapp/Provider/AddMemberProvider.dart';
import 'package:adminapp/Provider/LoginProvider.dart';
import 'package:adminapp/Provider/MembersProvider.dart';
import 'package:adminapp/Provider/eventProvider.dart';
import 'package:adminapp/Provider/memberProfileProvider.dart';
import 'package:adminapp/Routes/routes.dart';
import 'package:adminapp/Routes/routesGenerator.dart';
import 'package:adminapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => AddMemberProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => MemberProfileProvider()),
        // ChangeNotifierProvider(create: (_) => JoinRequestsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Community Points System',
      // home: ProfileImageUploader(),
      initialRoute: Routes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
