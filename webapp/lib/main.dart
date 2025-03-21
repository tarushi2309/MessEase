import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:webapp/pages/mess_manager/mess_committee.dart';
import 'package:webapp/pages/mess_manager/profile.dart';

import 'firebase_options.dart';
import '../pages/mess_manager/pending_request.dart';
import '../../components/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:webapp/pages/admin/home.dart' as admin;
import 'package:webapp/pages/mess_manager/home.dart' as mess_manager;
import 'package:webapp/pages/common/login.dart';
import 'firebase_options.dart';
import 'components/user_provider.dart';
import 'pages/mess_manager/mess_committee.dart';
import 'pages/admin/refund.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(), // Provide the UserProvider globally
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MessEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFF0753C, {
          50: Color(0xFFFFEBE0),
          100: Color(0xFFFFCCB3),
          200: Color(0xFFFFAA80),
          300: Color(0xFFFF8850),
          400: Color(0xFFFF6F2B),
          500: Color(0xFFF0753C),
          600: Color(0xFFE06635),
          700: Color(0xFFC0552E),
          800: Color(0xFFA04527),
          900: Color(0xFF80351F),
        }),
        fontFamily: "Roboto",
      ),
      initialRoute: '/login',
      home: LoginScreen(),
      routes: {

        '/login': (context) => LoginScreen(),
        '/home_admin': (context) => admin.HomeScreen(),
        '/home_mess_manager': (context) => mess_manager.HomeScreen(),
        '/mess_committee': (context) => MessCommitteeScreen(),
        '/pending-request': (context) => PendingRequestPage(),
        '/refund' : (content) => RefundPage(),
        //'/profile': (context) => MessManagerProfile(),
      },
    );
  }
}

