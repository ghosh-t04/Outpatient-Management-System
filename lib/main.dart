import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/book_appointment.dart';
import 'screens/patient_dashboard.dart';  // Import the PatientDashboard screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD3SkVLv3M-cnOIDObFtPqMbuX32ecXHQg",
        authDomain: "patient-7a77f.firebaseapp.com",
        projectId: "patient-7a77f",
        storageBucket: "patient-7a77f.appspot.com",
        messagingSenderId: "995776881642",
        appId: "1:995776881642:web:a25eb0510921149c728893",
        measurementId: "G-RVX43WNLER",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Outpatient Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Set initial route
      routes: {
        '/': (context) => LoginScreen(), // Start with Login Screen
        '/doctor_dashboard': (context) => DoctorDashboard(), // Registered Doctor Dashboard
        '/book_appointment': (context) => BookAppointmentScreen(), // Registered Book Appointment Screen
        '/patient_dashboard': (context) => PatientDashboard(), // Added PatientDashboard route
      },
    );
  }
}
