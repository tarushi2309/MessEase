import 'package:flutter/material.dart';
import 'package:webapp/components/header_manager.dart';

class MessCommitteeMessManagerPage extends StatefulWidget {
  const MessCommitteeMessManagerPage({super.key});

  @override
  State<MessCommitteeMessManagerPage> createState() => _MessCommitteeMessManagerPageState();
}

class _MessCommitteeMessManagerPageState extends State<MessCommitteeMessManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Header(currentPage: 'Mess Committee'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 35.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konark Mess',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
              ],
            ),
          ),
        );
  }
}