import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalHistoryFormScreen extends StatefulWidget {
  final String userId;  // Accepting userId as a parameter

  MedicalHistoryFormScreen({required this.userId});  // Constructor

  @override
  _MedicalHistoryFormScreenState createState() => _MedicalHistoryFormScreenState();
}

class _MedicalHistoryFormScreenState extends State<MedicalHistoryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Example form fields for medical history
  String medicalCondition = '';
  String medications = '';
  String allergies = '';

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save data to Firestore
      try {
        await _firestore.collection('medical_history').doc(widget.userId).set({
          'medicalCondition': medicalCondition,
          'medications': medications,
          'allergies': allergies,
          'timestamp': FieldValue.serverTimestamp(), // Add timestamp
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medical history saved successfully!')));

        // Navigate to the next screen (e.g., patient dashboard)
        Navigator.pushReplacementNamed(context, '/patient_dashboard');
      } catch (e) {
        // Handle error
        print("Error saving medical history: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save medical history')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medical History Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Medical Condition", (value) => medicalCondition = value!),
              _buildTextField("Medications", (value) => medications = value!),
              _buildTextField("Allergies", (value) => allergies = value!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
