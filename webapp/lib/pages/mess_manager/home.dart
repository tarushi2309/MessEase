import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webapp/components/header_manager.dart';
import 'package:webapp/models/addon.dart';
import 'package:webapp/models/announcement.dart';
import 'package:webapp/models/mess_menu.dart';
import 'package:webapp/services/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseModel db = DatabaseModel();

  @override
  void initState() {
    super.initState();
    initialise();
  }

  Future<void> initialise() async {
    await db.getMessId(FirebaseAuth.instance.currentUser!.uid);
    db.removePrevAddons();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MessMenuModel?>(
      future: db.getMenu(),
      builder: (context, menusnapshot) {
        if (menusnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (menusnapshot.hasError) {
          return Center(child: Text("Error: ${menusnapshot.error}"));
        }

        final String today = DateFormat('EEEE').format(DateTime.now());
        final MessMenuModel messMenu =
            menusnapshot.data ?? MessMenuModel(menu: {});
        Map<String, List<String>> menuForDay =
            messMenu.menu[today] ??
                {'Breakfast': [], 'Lunch': [], 'Dinner': []};

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Header(currentPage: 'Home'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Konark Mess',
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // ─── Add‑ons + Announcements (responsive) ──────────────
                LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  if (isNarrow) {
                    // stack vertically on phones
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAddOnsSection(),
                        const SizedBox(height: 24),
                        _buildAnnouncementsBlock(),
                      ],
                    );
                  }
                  // side‑by‑side on wider screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildAddOnsSection()),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: _buildAnnouncementsBlock()),
                    ],
                  );
                }),

                const SizedBox(height: 16),
                const Text("Today's Menu",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                _buildMealSection("Breakfast", menuForDay['Breakfast']!),
                _buildMealSection("Lunch", menuForDay['Lunch']!),
                _buildMealSection("Dinner", menuForDay['Dinner']!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) => Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('addon.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(items[index],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Today's Add Ons",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () => _showAddItemDialog(context, "Add‑On"),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: () => _showRemoveItemDialog(context, "Add‑On"),
            ),
          ],
        ),
        FutureBuilder<List<AddonModel>>(
          future: db.fetchAddons(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No add‑ons available"));
            }

            final addons = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: addons
                    .map((addon) => Column(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: const DecorationImage(
                                  image: AssetImage('addon.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text('${addon.name}  –  ₹${addon.price}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementsBlock() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Announcements",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAnnouncementsSection(),
        ],
      );

  Widget _buildAnnouncementsSection() {
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder<List<AnnouncementModel>>(
        future: db.fetchAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No announcements available"));
          }

          final announcements = snapshot.data!.reversed.toList();
          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: announcements
                    .map((doc) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('➤', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(doc.announcement)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, String title) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add $title',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Item Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                      labelText: 'Price', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () async {
                        final msg = await db.addAddon(
                            nameController.text.trim(),
                            priceController.text.trim());
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)));
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0753C)),
                      child: const Text('Add')),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, String title) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remove $title',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Item Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () async {
                        final msg =
                            await db.removeAddon(nameController.text.trim());
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)));
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0753C)),
                      child: const Text('Remove')),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
