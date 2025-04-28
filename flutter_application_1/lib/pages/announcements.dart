import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/announcement.dart';
import 'package:flutter_application_1/services/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../components/footer.dart';
import '../components/header.dart';
import '../components/navbar.dart';
import '../components/user_provider.dart';

class AnnouncementScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  AnnouncementScreen({super.key});

  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late DatabaseModel dbService;
  String messId = '';
  List<AnnouncementModel> announcementHistory = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState(){
    super.initState();
    final uid = Provider.of<UserProvider>(context, listen: false).uid;
    dbService = DatabaseModel(uid: uid!);
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    _initData();
  }

  Future<void> _initData() async {
    final uid = Provider.of<UserProvider>(context, listen: false).uid;
    if(uid == null){
        setState((){
            isLoading = false;
            errorMessage = "No user found, please log in ";
        });
        return;
    }
    try{
        final studentDoc = await dbService.getStudentInfo(uid);
        messId = studentDoc!['mess'] as String;
        messId = messId[0].toUpperCase() + messId.substring(1);
        //print(messId);
        if(messId != null){
            await _fetchAnnouncementHistory(messId);
        } else {
            errorMessage = "No messId found";
        }
        
    } catch(e){
        setState(() {
            isLoading = false;
            errorMessage = "Failed to fetch the announcements";
        });
    }
  } 

  @override
  
    Future<void> _fetchAnnouncementHistory(String messId) async {
        setState(() {
            isLoading = true;
            errorMessage = null;
        });

        try{
             final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .where('mess', arrayContains: messId)
          .get();
            final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

            
            final List<AnnouncementModel> loadedAnnouncements = snapshot.docs
          .map((doc) =>
              AnnouncementModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((announcement) {
        final announcementDate = DateTime.parse(announcement.date);
        return announcementDate.isAfter(startOfDay) &&
            announcementDate.isBefore(startOfDay.add(const Duration(days: 1)));
      }).toList();

            setState(() {
                announcementHistory = loadedAnnouncements;
                isLoading = false;
            });
        } catch (e) {
            setState(() {
                isLoading = false;
                errorMessage = "Failed to load the assignments";
            });
        }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: widget.scaffoldKey),
      ),
      drawer: Navbar(),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ANNOUNCEMENTS",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Announcement History",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : announcementHistory.isEmpty
                          ? Center(child: Text("No announcements are available."))
                          : ListView.builder(
                              itemCount: announcementHistory.length,
                              itemBuilder: (context, index) {
                                final announcement = announcementHistory[index];
                                return _buildAnnouncementCard(
                                  announcement.announcement,
                                  announcement.date,
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }


  Widget _buildAnnouncementCard(String announcement, String date) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
                child: ListTile(
                    title: Text(
                        announcement,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                        date,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ),
            ),
        );
    }

  
}