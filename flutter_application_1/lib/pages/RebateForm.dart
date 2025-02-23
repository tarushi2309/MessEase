import 'package:flutter/material.dart';

import '../components/footer.dart'; // Import your footer
import '../components/header.dart'; // Import your header

class RebateFormPage extends StatefulWidget {
  const RebateFormPage({super.key});

  @override
  _RebateFormPageState createState() => _RebateFormPageState();
}

class _RebateFormPageState extends State<RebateFormPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers for text input
  TextEditingController hostelController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController rebateFromController = TextEditingController();
  TextEditingController rebateToController = TextEditingController();
  TextEditingController daysController = TextEditingController();

  // Function to show Date Picker
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          Header(scaffoldKey: _scaffoldKey), // Ensure header is added
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rebate Form",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              buildTextField("Hostel Name", hostelController),
                              buildTextField("Room Number", roomController),
                              buildDateField("Rebate From", rebateFromController),
                              buildDateField("Rebate To", rebateToController),
                              buildTextField("Number of Days", daysController,
                                  keyboardType: TextInputType.number),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Form Submitted")),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Submit Form",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
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
            ),
          ),
          CustomNavigationBar(selectedIndex: 1), // Footer
        ],
      ),
    );
  }

  // Text field builder
  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }

  // Date picker field
  Widget buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        onTap: () => _selectDate(context, controller),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select a date";
          }
          return null;
        },
      ),
    );
  }
}
