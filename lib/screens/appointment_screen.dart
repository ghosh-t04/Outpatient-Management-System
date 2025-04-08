import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<Map<String, dynamic>> _doctors = [];
  List<String> _availableSlots = [];
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('doctor').get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ No doctors found!");
        return;
      }

      setState(() {
        _doctors = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "name": data["name"] ?? "Unknown Doctor",
            "specialization": data["specialization"] ?? "General",
            "availableSlots": List<String>.from(data["availableSlots"] ?? []),
          };
        }).toList();
      });
    } catch (e) {
      print("❌ Error fetching doctors: $e");
    }
  }

  void _fetchSlots(String doctorId) {
    var selectedDoctor = _doctors.firstWhere(
            (doc) => doc["id"] == doctorId,
        orElse: () => {});

    if (selectedDoctor.isNotEmpty) {
      setState(() {
        _selectedDoctorId = doctorId;
        _selectedDoctorName = selectedDoctor["name"];
        _availableSlots = selectedDoctor["availableSlots"] ?? [];
        _selectedSlot = null;
      });
    }
  }

  void bookAppointment() {
    if (nameController.text.isEmpty ||
        dateController.text.isEmpty ||
        _selectedDoctorId == null ||
        _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields!")));
      return;
    }

    FirebaseFirestore.instance.collection('appointments').add({
      'patient_name': nameController.text,
      'appointment_date': dateController.text,
      'doctor_id': _selectedDoctorId,
      'doctor_name': _selectedDoctorName,
      'time_slot': _selectedSlot,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Appointment Booked")));

    nameController.clear();
    dateController.clear();
    setState(() {
      _selectedDoctorId = null;
      _selectedDoctorName = null;
      _selectedSlot = null;
      _availableSlots = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Appointment")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Patient Name"),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: "Appointment Date"),
            ),
            SizedBox(height: 16),
            Text("Select Doctor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              hint: Text("Choose a doctor"),
              value: _selectedDoctorId,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _fetchSlots(newValue);
                }
              },
              items: _doctors.map((doctor) {
                return DropdownMenuItem<String>(
                  value: doctor["id"],
                  child: Text("${doctor["name"]} - ${doctor["specialization"]}"),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            if (_availableSlots.isNotEmpty) ...[
              Text("Select Time Slot", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                hint: Text("Choose a time slot"),
                value: _selectedSlot,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSlot = newValue;
                  });
                },
                items: _availableSlots.map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: bookAppointment,
              child: Text("Book Appointment"),
            )
          ],
        ),
      ),
    );
  }
}