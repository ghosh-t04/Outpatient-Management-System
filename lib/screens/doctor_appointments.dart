import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/appointment_service.dart';
import 'package:intl/intl.dart';

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

  /// 🔹 Fetch all doctors from Firestore
  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("doctor").get();

      List<Map<String, String>> fetchedDoctors = querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "name": doc["name"]?.toString() ?? "Unknown",
          "email": doc["email"]?.toString() ?? "N/A",
          "phone": doc["phone number"]?.toString() ?? "N/A",
        };
      }).toList();


      setState(() {
        _doctors = fetchedDoctors;
        if (_doctors.isNotEmpty) {
          _selectedDoctorId = _doctors[0]["id"];
          _fetchSlots(_selectedDoctorId!);
        }
      });

      print("✅ Doctors loaded: $_doctors");
    } catch (e) {
      print("❌ Error fetching doctors: $e");
      _showSnackBar("Failed to load doctors: ${e.toString().split(':').last.trim()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Fetch available slots for selected doctor
  Future<void> _fetchSlots(String doctorId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("doctor")
          .doc(doctorId)
          .get();

      if (doc.exists && doc.data() != null) {
        List<String> rawSlots = List<String>.from(
          (doc["availableSlots"] ?? []).map((slot) => slot.toString()),
        );

        rawSlots.sort(); // Sort slots by time

        setState(() {
          _availableSlots = rawSlots;
          _selectedSlot = _availableSlots.isNotEmpty ? _availableSlots[0] : null;
        });

        print("✅ Available slots: $_availableSlots");
      }
    } catch (e) {
      print("❌ Error fetching slots: $e");
      _showSnackBar("Failed to load slots: ${e.toString().split(':').last.trim()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _getDoctorName() {
    return _doctors
        .firstWhere((doc) => doc["id"] == _selectedDoctorId,
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
          "Book appointment with Dr. ${_getDoctorName()} at ${_formatSlot(_selectedSlot!)}?",
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
        currentUser.uid,
        _selectedDoctorId!,
        _getDoctorName(),
        _selectedSlot!,
      );

      _showSnackBar("✅ Appointment booked successfully!");

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      print("❌ Error booking appointment: $e");
      _showSnackBar("Failed to book appointment. Try again later.");
    }
  }

  String _formatSlot(String slot) {
    try {
      DateTime dt = DateTime.parse(slot);
      return DateFormat('EEEE, MMM d • hh:mm a').format(dt);
    } catch (e) {
      return slot; // Fallback in case of parsing issues
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
                : _doctors.isEmpty
                ? Text("No doctors available at the moment.")
                : DropdownButton<String>(
              hint: Text("Select Doctor"),
              value: _selectedDoctorId,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDoctorId = newValue;
                  _availableSlots = [];
                  _selectedSlot = null;
                  if (newValue != null) {
                    _fetchSlots(newValue);
                  }
                });
              },
              items: _doctors.map((doctor) {
                return DropdownMenuItem<String>(
                  value: doctor["id"],
                  child: Text("${doctor["name"]} (${doctor["phone"]})"),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            _availableSlots.isEmpty
                ? Text("No available time slots.")
                : DropdownButton<String>(
              hint: Text("Select Time Slot"),
              value: _selectedSlot,
              onChanged: (String? newValue) {
                setState(() => _selectedSlot = newValue);
              },
              items: _availableSlots.map((slot) {
                return DropdownMenuItem<String>(
                  value: slot,
                  child: Text(_formatSlot(slot)),
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
