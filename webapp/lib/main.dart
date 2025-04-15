import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:webapp/pages/student/home.dart' as student;
import 'package:webapp/pages/boha/menu_page.dart';
import 'package:webapp/pages/mess_manager/current_rebate.dart';
import 'package:webapp/pages/mess_manager/mess_details.dart';
import 'package:webapp/pages/mess_manager/feedback.dart';
import 'package:webapp/pages/student/get_details.dart';
import 'package:webapp/pages/student/mess_menu.dart';
import 'package:webapp/pages/student/rebate_history.dart';
import 'firebase_options.dart';
import 'pages/mess_manager/pending_rebate.dart';
import '../../components/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:webapp/pages/admin/home.dart' as admin;
import 'package:webapp/pages/admin/rebate_history.dart';
import 'package:webapp/pages/mess_manager/home.dart' as mess_manager;
import 'package:webapp/pages/boha/home.dart' as boha;
import 'package:webapp/pages/common/login.dart';
import 'pages/admin/refund.dart';
import 'pages/admin/mess_refund.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:webapp/pages/boha/mess.dart';
import 'package:webapp/pages/boha/announcements.dart';
import 'package:webapp/pages/boha/mess_committee.dart';
import 'package:webapp/pages/boha/feedback.dart';
import 'package:webapp/pages/student/profile.dart';
import 'package:webapp/pages/student/rebateform.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setPathUrlStrategy();
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
        '/home_boha': (context) => boha.HomeScreen(),
        '/home_student' : (context) => student.HomeScreen(),
        '/mess_committee_boha': (context) => MessCommitteeScreenBoha(),
        '/pending-request': (context) => PendingRequestPage(),
        '/current-request': (context) => CurrentRequestPage(),
        '/refund' : (content) => RefundPage(),
        '/menu_page': (context) => MenuPage(),
        '/rebate_history': (context) => RebateHistoryPage(),
        '/mess_committee': (context) => MessCommitteePage(),
        '/announcements': (context) => AnnouncementPage(),
        '/mess_details_mess_manager' : (context) => MessCommitteeMessManagerPage(),
        '/feedback': (context) => FeedbackScreen(),
        '/feedback_mess': (context) => FeedbackMessScreen(),
        '/get_student_details': (context) => GetStudentDetails(),
        '/rebate_form': (context) => RebateformPage(),
        '/mess_menu_student': (context) => MessMenuStudentPage(),
        '/processed_rebates': (context) => RebateHistoryProcessedPage(),
        '/profile_student': (context) => ProfileStudentPage(),
        '/rebate_history_student' : (context) => RebateHistoryStudentPage(),
        //'/profile': (context) => MessManagerProfile(),
      },
    );
  }
}

