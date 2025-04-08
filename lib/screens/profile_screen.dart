import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch User Profile
  Future<void> _fetchUserProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      UserModel? user = await _profileService.getUserProfile(currentUser.uid);
      if (user != null) {
        setState(() {
          _user = user;
          _nameController.text = user.name;
          _isLoading = false;
        });
      }
    }
  }

  // Update User Profile
  Future<void> _updateProfile() async {
    if (_user != null) {
      await _profileService.updateUserProfile(_user!.uid, _nameController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
