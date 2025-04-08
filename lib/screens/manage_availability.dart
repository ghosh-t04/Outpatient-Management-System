import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/availability_service.dart';

class ManageAvailabilityScreen extends StatefulWidget {
  @override
  _ManageAvailabilityScreenState createState() => _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen> {
  final AvailabilityService _availabilityService = AvailabilityService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _availableSlots = [];
  bool _isLoading = true;
  TextEditingController _slotController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  // Fetch availability from Firestore
  Future<void> _fetchAvailableSlots() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      List<String> slots = await _availabilityService.getAvailableSlots(currentUser.uid);
      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    }
  }

  // Add a new slot
  Future<void> _addSlot() async {
    if (_slotController.text.isNotEmpty) {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _availabilityService.addSlot(currentUser.uid, _slotController.text);
        _slotController.clear();
        _fetchAvailableSlots(); // Refresh slots
      }
    }
  }

  // Remove a slot
  Future<void> _removeSlot(String slot) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _availabilityService.removeSlot(currentUser.uid, slot);
      _fetchAvailableSlots(); // Refresh slots
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Availability")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Available Time Slots", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // List of available time slots
            _availableSlots.isEmpty
                ? Text("No available slots", style: TextStyle(color: Colors.grey))
                : Column(
              children: _availableSlots.map((slot) {
                return ListTile(
                  title: Text(slot),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeSlot(slot),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Add new slot
            TextField(
              controller: _slotController,
              decoration: InputDecoration(labelText: "Enter time slot (e.g., 10:00 AM - 11:00 AM)"),
            ),
            SizedBox(height: 10),

            Center(
              child: ElevatedButton(
                onPressed: _addSlot,
                child: Text("Add Slot"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
