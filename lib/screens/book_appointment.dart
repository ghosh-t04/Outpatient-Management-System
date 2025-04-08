import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/appointment_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  String? _selectedDoctorId;
  String? _selectedSlot;
  List<String> _availableSlots = [];
  List<Map<String, String>> _doctors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  // ✅ Fetch doctors from Firestore safely
  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("doctor").get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ No doctors found in Firestore.");
        _showSnackBar("No doctors available.");
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _doctors = querySnapshot.docs.map<Map<String, String>>((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "name": data["name"] ?? "Unknown",
            "email": data.containsKey("email") ? data["email"] : "N/A",
            "phone": data.containsKey("phone") ? data["phone"] : "N/A",
          };
        }).toList();
      });

      print("✅ Doctors loaded: $_doctors");
    } catch (e) {
      print("❌ Error fetching doctors: $e");
      _showSnackBar("Failed to load doctors. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Fetch available slots for selected doctor
  Future<void> _fetchSlots(String doctorId) async {
    try {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection("doctor").doc(doctorId).get();

      if (!doc.exists) {
        print("⚠️ Doctor ID $doctorId not found.");
        _showSnackBar("Doctor not found.");
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      setState(() {
        _availableSlots = List<String>.from(data["availableSlots"] ?? []);
      });

      print("✅ Available slots: $_availableSlots");
    } catch (e) {
      print("❌ Error fetching slots: $e");
      _showSnackBar("Failed to load time slots.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _getDoctorName() {
    return _doctors
        .firstWhere((doctor) => doctor["id"] == _selectedDoctorId,
        orElse: () => {"name": "Unknown"})["name"] ??
        "Unknown";
  }

  void _confirmBooking() {
    if (_selectedDoctorId == null || _selectedSlot == null) {
      _showSnackBar("Please select a doctor and time slot.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Appointment"),
        content: Text(
          "Book appointment with Dr. ${_getDoctorName()} at $_selectedSlot?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bookAppointment();
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _bookAppointment() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showSnackBar("You need to be logged in to book an appointment.");
      return;
    }

    try {
      await _appointmentService.bookAppointment(
        currentUser.uid, // Patient ID
        _selectedDoctorId!, // Doctor ID
        _getDoctorName(), // Doctor Name
        _selectedSlot!, // Time Slot
      );

      _showSnackBar("Appointment booked successfully!");

      // Navigate back after success
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      print("Error booking appointment: $e");
      _showSnackBar("Failed to book appointment. Try again later.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Appointment")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
              hint: Text("Select Doctor"),
              value: _selectedDoctorId,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDoctorId = newValue;
                    _availableSlots = [];
                  });
                  _fetchSlots(newValue);
                }
              },
              items: _doctors.map((doctor) {
                return DropdownMenuItem<String>(
                  value: doctor["id"],
                  child: Text("${doctor["name"]} (${doctor["phone"]})"),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text("Select Time Slot"),
              value: _selectedSlot,
              onChanged: (String? newValue) {
                setState(() => _selectedSlot = newValue);
              },
              items: _availableSlots.map((slot) {
                return DropdownMenuItem<String>(
                  value: slot,
                  child: Text(slot),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmBooking,
              child: Text("Confirm Appointment"),
            ),
          ],
        ),
      ),
    );
  }
}
