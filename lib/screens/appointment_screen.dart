import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this package for formatting

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
  bool _isLoadingDoctors = false;
  bool _isLoadingSlots = false;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() => _isLoadingDoctors = true);
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('doctor').get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ No doctors found!");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No doctors available")));
        return;
      }

      setState(() {
        _doctors = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "name": data["name"] ?? "Unknown Doctor",
            "specialization": data["specialization"] ?? "General",
            "availableSlots": (data["availableSlots"] as List<dynamic>? ?? [])
                .map((slot) {
              if (slot is Timestamp) {
                return slot.toDate().toString(); // or use DateFormat for prettier display
              }
              return slot.toString();
            }).toList(),
          };
        }).toList();
      });
    } catch (e) {
      print("❌ Error fetching doctors: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load doctors. Please try again")));
    } finally {
      setState(() => _isLoadingDoctors = false);
    }
  }

  void _fetchSlots(String doctorId) {
    setState(() {
      _isLoadingSlots = true;
    });
    var selectedDoctor = _doctors.firstWhere(
          (doc) => doc["id"] == doctorId,
      orElse: () => {},
    );

    if (selectedDoctor.isNotEmpty) {
      setState(() {
        _selectedDoctorId = doctorId;
        _selectedDoctorName = selectedDoctor["name"];
        _availableSlots = List<String>.from(selectedDoctor["availableSlots"] ?? []);
        _selectedSlot = null;
      });
    }

    setState(() {
      _isLoadingSlots = false;
    });
  }

  // Function to parse string into DateTime
  DateTime parseTimeSlot(String slot) {
    final now = DateTime.now();
    final format = DateFormat.jm(); // 12-hour format with AM/PM

    // Parse the slot into a DateTime object
    DateTime parsedTime = format.parse(slot);

    // Create a new DateTime object with the current date and parsed time
    return DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
  }

  void bookAppointment() async {
    if (nameController.text.isEmpty ||
        dateController.text.isEmpty ||
        _selectedDoctorId == null ||
        _selectedSlot == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields!")));
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Convert string slot into DateTime
      DateTime slotDateTime = parseTimeSlot(_selectedSlot!);

      await FirebaseFirestore.instance.collection('appointments').add({
        'patient_name': nameController.text,
        'appointment_date': dateController.text,
        'doctor_id': _selectedDoctorId,
        'doctor_name': _selectedDoctorName,
        'time_slot': Timestamp.fromDate(slotDateTime), // ✅ store as Timestamp
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
    } catch (e) {
      print("❌ Error booking appointment: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error booking appointment")));
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
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
            _isLoadingDoctors
                ? Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
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
              _isLoadingSlots
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButton<String>(
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
              onPressed: _isBooking ? null : bookAppointment,
              child: _isBooking ? CircularProgressIndicator() : Text("Book Appointment"),
            )
          ],
        ),
      ),
    );
  }
}
