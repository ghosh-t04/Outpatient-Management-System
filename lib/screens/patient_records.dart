import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ehr_service.dart';

class PatientRecordsScreen extends StatelessWidget {
  final EHRService _ehrService = EHRService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Medical Records")),
      body: StreamBuilder(
        stream: _ehrService.getPatientRecords(user!.uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) return Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) return Center(child: Text("No medical records found."));

          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text("Diagnosis: ${data["diagnosis"] ?? "N/A"}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text("Prescriptions: ${data["prescriptions"] ?? "N/A"}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text("Test Results: ${data["test_results"] ?? "N/A"}", style: TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
    );
  }
}
