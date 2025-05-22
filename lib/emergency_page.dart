import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/Authprovider.dart';
import 'admin_emergency.dart';
import 'emergency_contact.dart';
import 'emergency_service.dart';

class EmergencyPage extends StatefulWidget {
  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeEmergencyServices();
  }

  Future<void> _initializeEmergencyServices() async {
    try {
      await EmergencyContactsService.initializeFirebase();
    } catch (e) {
      print('Error initializing emergency services: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.role;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Show the appropriate screen based on user role
    if (userRole == 'admin') {
      return AdminEmergencyScreen();
    } else {
      return EmergencyContactScreen();
    }
  }
}
