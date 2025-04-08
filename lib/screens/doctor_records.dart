import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ehr_service.dart';

class DoctorRecordsScreen extends StatefulWidget {
  final String patientId;

  DoctorRecordsScreen({required this.patientId});

  @override
  _DoctorRecordsScreenState createState() => _DoctorRecordsScreenState();
}

class _DoctorRecordsScreenState extends State<DoctorRecordsScreen> {
  final EHRService _ehrService = EHRService();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _testResultsController = TextEditingController();

  // Save medical record
  Future<void> _saveRecord() async {
    await _ehrService.addOrUpdateRecord(widget.patientId, {
      "diagnosis": _diagnosisController.text,
      "prescriptions": _prescriptionController.text,
      "test_results": _testResultsController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Record updated!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Medical Record")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _diagnosisController,
              decoration: InputDecoration(labelText: "Diagnosis"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _prescriptionController,
              decoration: InputDecoration(labelText: "Prescriptions"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _testResultsController,
              decoration: InputDecoration(labelText: "Test Results"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRecord,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
