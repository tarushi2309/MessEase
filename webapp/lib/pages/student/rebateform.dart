import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webapp/components/header_student.dart';
import 'package:webapp/components/user_provider.dart';
import 'package:webapp/models/rebate.dart';
import 'package:webapp/pages/student/image.dart';

class RebateformPage extends StatefulWidget {
  const RebateformPage({super.key});

  @override
  State<RebateformPage> createState() => _RebateformPageState();
}

class _RebateformPageState extends State<RebateformPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? uid;

  // Controllers
  TextEditingController hostelController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController rebateFromController = TextEditingController();
  TextEditingController rebateToController = TextEditingController();
  TextEditingController daysController = TextEditingController();
  hostel? selectedHostel;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
  }

  // Function to show Date Picker
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  DocumentSnapshot? studentRef;

  void submitRebateForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Convert date format
      List<String> startParts = rebateFromController.text.split('/');
      List<String> endParts = rebateToController.text.split('/');

      Timestamp startDate = Timestamp.fromDate(
        DateTime(int.parse(startParts[2]), int.parse(startParts[1]),
            int.parse(startParts[0])),
      );
      Timestamp endDate = Timestamp.fromDate(
        DateTime(int.parse(endParts[2]), int.parse(endParts[1]),
            int.parse(endParts[0])),
      );
      print('studentRef: ${studentRef!['mess']}');
      Rebate rebate = Rebate(
        req_id: '',
        student_id: studentRef!.reference,
        start_date: startDate,
        end_date: endDate,
        status_: status.pending,
        hostel_: selectedHostel!,
        mess_: studentRef!['mess'],
      );

      DocumentReference docRef =
          await _firestore.collection('rebates').add(rebate.toJson());
      await docRef.update({'req_id': docRef.id});

      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rebate request submitted successfully!')),
      );*/

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Rebate request submitted successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      try {
        setState(() {
          selectedHostel = null;
          hostelController.clear();
          roomController.clear();
          rebateFromController.clear();
          rebateToController.clear();
          daysController.clear();
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  void submitDate() async {
    try {
      // Parse the dates from the controllers
      DateTime rebateFrom =
          DateFormat('dd/MM/yyyy').parse(rebateFromController.text);
      DateTime rebateTo =
          DateFormat('dd/MM/yyyy').parse(rebateToController.text);
      studentRef = await _firestore.collection('students').doc(uid).get();
      // Calculate the difference in days
      int difference = rebateTo.difference(rebateFrom).inDays + 1;
      // Check if the difference is valid
      if (difference < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("The rebate period must be at least 3 days.")),
        );
        return;
      }
      DateTime lastRebateDate =
          (studentRef!['last_rebate'] as Timestamp).toDate();

      if (rebateFrom.isBefore(lastRebateDate) ||
          rebateFrom.isAtSameMomentAs(lastRebateDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The rebate for this period already exists.")),
        );
        return;
      }
      if (difference > (20 - studentRef!['days_of_rebate'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Required days exceed the allowed limit of 20 days per semester. You only have ${20 - studentRef!['days_of_rebate']} days left.")),
        );
        return;
      }
      if ((difference + studentRef!['days_of_rebate']) > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Adding current rebate will make you exceed the current 20 day limit per semester. Rebate request denied.")),
        );
        return;
      }
      print("submit rebate");
      submitRebateForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Invalid date format. Please select valid dates.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Rebate Form'),
      ),
      body: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth =
                constraints.maxWidth < 650 ? constraints.maxWidth * 0.9 : 600;

            return Center(
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "REBATE FORM",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "Enter the details below to submit a rebate request",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF757575)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              FractionallySizedBox(
                                widthFactor: 0.85,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: DropdownButtonFormField<hostel>(
                                    value: selectedHostel,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedHostel = newValue;
                                      });
                                    },
                                    items: hostel.values.map((hostel h) {
                                      return DropdownMenuItem<hostel>(
                                        value: h,
                                        child: Text(h.name
                                            .toUpperCase()), // Display names in uppercase
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Select Hostel',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // mess part added in the form

                              buildResponsiveTextField(
                                  "Room Number", roomController),
                              buildDateField(
                                  "Rebate From", rebateFromController),
                              buildDateField("Rebate To", rebateToController),
                              //buildTextField("Number of Days", daysController, keyboardType: TextInputType.number),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: submitDate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF0753C),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                child: const Text(
                                  "Submit Form",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildResponsiveTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter $label";
            }
            return null;
          },
        ),
      ),
    );
  }

  // Date picker field
  Widget buildDateField(String label, TextEditingController controller) {
    return FractionallySizedBox(
      widthFactor: 0.85,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today,
                color: Color.fromARGB(255, 8, 5, 0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            filled: true,
            fillColor: Colors.white,
          ),
          onTap: () => _selectDate(context, controller),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select a valid date";
            }
            return null;
          },
        ),
      ),
    );
  }
}
