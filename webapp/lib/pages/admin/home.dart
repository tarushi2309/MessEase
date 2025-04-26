import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp/components/header_admin.dart';
import 'package:webapp/models/batches.dart';
import 'package:webapp/models/mess.dart';
import 'package:webapp/models/messOptions.dart';
import 'package:webapp/services/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabControllerBatch;
  late TabController _tabControllerMess;
  String _selectedBatchToRemove = "";
  String _selectedMessToRemove = "";
  String? _selectedDegreeType;
  final TextEditingController _newMessController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final List<String> _degreeTypes = ["BTech", "MTech", "MSc", "PhD"];
  List<String> _messOptions = [];
  List<String> _batch = [];
  Map<String, String> _selectedMessMap = {}; // batchName -> messName

  late SharedPreferences _prefs;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabControllerBatch = TabController(length: 2, vsync: this);
    _tabControllerMess = TabController(length: 2, vsync: this);
    _initPrefsAndData();
  }

  Future<void> _initPrefsAndData() async {
    _prefs = await SharedPreferences.getInstance();
    await get_messOptions();
    await get_batches();
    _loadPersistedSelections();
    setState(() {
      _prefsLoaded = true;
    });
  }

  void _loadPersistedSelections() {
    for (var batch in _batch) {
      final mess = _prefs.getString('mess_for_$batch');
      if (mess != null && _messOptions.contains(mess)) {
        _selectedMessMap[batch] = mess;
      }
    }
    if (_batch.isNotEmpty) _selectedBatchToRemove = _batch[0];
    if (_messOptions.isNotEmpty) _selectedMessToRemove = _messOptions[0];
  }

  Future<void> _persistSelection(String batch, String mess) async {
    await _prefs.setString('mess_for_$batch', mess);
  }

  Future<void> allot_mess() async {
    MessModel mess = MessModel(messAllot: _selectedMessMap);
    DatabaseModel dbservice = DatabaseModel();
    await dbservice.addMessDetails(mess);
    for (var entry in _selectedMessMap.entries) {
      await _persistSelection(entry.key, entry.value);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mess Allotted Successfully!")),
    );
  }

  Future<void> get_messOptions() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('messOptions')
          .doc('messOptions')
          .get();

      if (doc.exists) {
        MessOptions options =
            MessOptions.fromJson(doc.data() as Map<String, dynamic>);
        setState(() {
          _messOptions = options.messNames;
          if (_messOptions.isNotEmpty) {
            _selectedMessToRemove = _messOptions[0];
            for (var batch in _batch) {
              _selectedMessMap[batch] ??= _messOptions[0];
            }
          }
        });
      }
    } catch (e) {
      print("Error getting mess options: $e");
    }
  }

  Future<void> get_batches() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('batches')
          .doc('batches')
          .get();

      if (doc.exists) {
        Batches batches = Batches.fromJson(doc.data() as Map<String, dynamic>);
        setState(() {
          List<String> newBatches = batches.batchNames;
          for (var batch in newBatches) {
            if (!_selectedMessMap.containsKey(batch)) {
              _selectedMessMap[batch] =
                  _messOptions.isNotEmpty ? _messOptions[0] : "";
            }
          }
          _selectedMessMap
              .removeWhere((key, value) => !newBatches.contains(key));
          _batch = newBatches;
          if (_batch.isNotEmpty) {
            _selectedBatchToRemove = _batch[0];
          }
        });
      }
    } catch (e) {
      print("Error getting batches: $e");
    }
  }

  Future<void> add_mess() async {
    if (_newMessController.text.isEmpty) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('messOptions')
          .doc('messOptions');
      await docRef.set({
        'messNames': FieldValue.arrayUnion([_newMessController.text.trim()])
      }, SetOptions(merge: true));

      _newMessController.clear();
      await get_messOptions();
    } catch (e) {
      print("Error adding mess: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding mess: ${e.toString()}")),
      );
    }
  }

  Future<void> delete_mess() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('messOptions')
          .doc('messOptions');

      if ((await docRef.get()).exists) {
        await docRef.update({
          'messNames': FieldValue.arrayRemove([_selectedMessToRemove])
        });
        await get_messOptions();
      }
    } catch (e) {
      print("Error deleting mess: $e");
    }
  }

  Future<void> add_batch() async {
    if (_yearController.text.isEmpty && _selectedDegreeType != "PhD") return;
    if (_selectedDegreeType == null) return;

    final newBatch = _selectedDegreeType! + _yearController.text.trim();

    try {
      final docRef =
          FirebaseFirestore.instance.collection('batches').doc('batches');
      if (!(await docRef.get()).exists) {
        await docRef.set({'batchNames': []});
      }
      await docRef.update({
        'batchNames': FieldValue.arrayUnion([newBatch])
      });
      _yearController.clear();
      await get_batches();
    } catch (e) {
      print("Error adding batch: $e");
    }
  }

  Future<void> delete_batch() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('batches').doc('batches');
      if ((await docRef.get()).exists) {
        await docRef.update({
          'batchNames': FieldValue.arrayRemove([_selectedBatchToRemove])
        });
        await get_batches();
      }
    } catch (e) {
      print("Error deleting batch: $e");
    }
  }

  @override
  void dispose() {
    _tabControllerBatch.dispose();
    _tabControllerMess.dispose();
    _newMessController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Home'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 600, child: _buildAllotMessesCard()),
                  const SizedBox(height: 16),
                  SizedBox(height: 400, child: _buildViewMessDetailsCard()),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildAllotMessesCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _buildViewMessDetailsCard()),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAllotMessesCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Allot Messes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _batch
                      .map((batch) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildDynamicFieldRow(batch),
                          ))
                      .toList(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.2,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _showBatchDialog(context);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFFF0753C)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                          ),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                        child: const Text(
                          "Edit Batch",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.2,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _showMessDialog(context);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFFF0753C)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.02,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                          ),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                        child: const Text(
                          "Edit Mess",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.2,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          allot_mess();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFFF0753C)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.02,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                          ),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                        child: const Text(
                          "Allot",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBatchDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              content: SizedBox(
                width: 300,
                height: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      controller: _tabControllerBatch,
                      tabs: const [
                        Tab(text: "Add Batch"),
                        Tab(text: "Remove Batch"),
                      ],
                      indicatorColor: const Color(0xFFF0753C),
                      labelColor: const Color(0xFFF0753C),
                      unselectedLabelColor: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        controller: _tabControllerBatch,
                        children: [
                          _buildAddBatchContent(),
                          _buildRemoveBatchContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_tabControllerBatch.index == 0) {
                      add_batch();
                    } else {
                      delete_batch();
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0753C),
                  ),
                  child: Text(
                    "Submit",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAddBatchContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _selectedDegreeType,
              decoration: const InputDecoration(
                labelText: "Degree Type",
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: _degreeTypes.map((String degree) {
                return DropdownMenuItem<String>(
                  value: degree,
                  child: Text(degree),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDegreeType = newValue;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: "Year",
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveBatchContent() {
    if (_batch.isEmpty) {
      return Center(child: Text("No batches available to remove"));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedBatchToRemove,
        decoration: const InputDecoration(
          labelText: "Select Batch to Remove",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: _batch.map((String batch) {
          return DropdownMenuItem<String>(
            value: batch,
            child: Text(batch),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedBatchToRemove = newValue!;
          });
        },
      ),
    );
  }

  Future<void> _showMessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              content: SizedBox(
                width: 300,
                height: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      controller: _tabControllerMess,
                      tabs: const [
                        Tab(text: "Add Mess"),
                        Tab(text: "Remove Mess"),
                      ],
                      indicatorColor: const Color(0xFFF0753C),
                      labelColor: const Color(0xFFF0753C),
                      unselectedLabelColor: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        controller: _tabControllerMess,
                        children: [
                          _buildAddMessContent(),
                          _buildRemoveMessContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_tabControllerMess.index == 0) {
                      add_mess();
                    } else {
                      delete_mess();
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0753C),
                  ),
                  child: Text(
                    "Submit",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAddMessContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: _newMessController,
        decoration: InputDecoration(
          labelText: "Mess Name",
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRemoveMessContent() {
    if (_messOptions.isEmpty) {
      return Center(child: Text("No batches available to remove"));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedMessToRemove,
        decoration: const InputDecoration(
          labelText: "Select Mess to Remove",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: _messOptions.map((String mess) {
          return DropdownMenuItem<String>(
            value: mess,
            child: Text(mess),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedMessToRemove = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildDynamicFieldRow(String batchName) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: batchName,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedMessMap[batchName],
            decoration: const InputDecoration(
              labelText: "Select Mess",
              border: OutlineInputBorder(),
            ),
            items: _messOptions.map((String mess) {
              return DropdownMenuItem(
                value: mess,
                child: Text(mess),
              );
            }).toList(),
            onChanged: (String? newValue) async {
              setState(() {
                _selectedMessMap[batchName] = newValue!;
              });
              await _persistSelection(batchName, newValue!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewMessDetailsCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "View Mess Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (_messOptions.isEmpty) {
                    return const Center(
                      child: Text("No messes available",
                          style: TextStyle(fontSize: 16)),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 600,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _messOptions.length,
                    itemBuilder: (context, index) {
                      final messName = _messOptions[index];

                      return _buildMessCard(context, messName);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


// Builds a single mess detail card.
  Widget _buildMessCard(BuildContext context, String messName) {

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 300,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7643),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      messName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/mess_details_admin',
                              arguments: messName);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFFF0753C)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                          ),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
