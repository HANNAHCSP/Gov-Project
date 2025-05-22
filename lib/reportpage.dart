import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'providers/reportprovider.dart';
import 'providers/Authprovider.dart';
import 'dart:convert';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  LatLng _problemLocation = LatLng(39.0, -76.7);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _problemLocation = point;
    });
  }

  /*Future<void> _submitReport() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final reportProvider = Provider.of<ReportProvider>(context, listen: false);

  if (_descriptionController.text.isEmpty || _selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please provide a description and an image")),
    );
    return;
  }

  try {
    
    final imageFile = File(_selectedImage!.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('report_images')
        .child('$fileName.jpg');

   final uploadTask = await storageRef.putFile(
  imageFile,
  SettableMetadata(contentType: 'image/jpeg'),
);
    final uploadedImageUrl = await uploadTask.ref.getDownloadURL();

    // Submit report with image URL
    await reportProvider.addReport(
      _descriptionController.text,
      uploadedImageUrl,
      "${_problemLocation.latitude},${_problemLocation.longitude}",
      authProvider.userId,
      authProvider.token,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Report submitted successfully")),
    );

    _descriptionController.clear();
    setState(() {
      _selectedImage = null;
      _problemLocation = LatLng(39.0, -76.7);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to submit report: ${e.toString()}")),
    );
    print("Error submitting report: ${e.toString()}"
    
    );
  }
}*/
  Future<void> _submitReport() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (_descriptionController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide a description and an image")),
      );
      return;
    }

    try {
      // Convert image file to base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Submit report with base64 image
      await reportProvider.addReport(
        _descriptionController.text,
        base64Image, // send base64 string instead of URL
        "${_problemLocation.latitude},${_problemLocation.longitude}",
        authProvider.userId,
        authProvider.token,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Report submitted successfully")));

      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
        _problemLocation = LatLng(39.0, -76.7);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit report: ${e.toString()}")),
      );
      print("Error submitting report: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Report"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitReport,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 20,
                // backgroundImage: AssetImage('assets/profile.png'),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Report a Problem",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 3.0,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Problem Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.upload),
                label: Text("Upload a picture"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                ),
              ),
              if (_selectedImage != null) ...[
                SizedBox(height: 10),
                Image.file(_selectedImage!, height: 150),
              ],
              const SizedBox(height: 20),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Tap to select location on map",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _problemLocation,
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) => _onMapTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _problemLocation,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
