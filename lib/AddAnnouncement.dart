import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_field/image_field.dart';
import 'package:provider/provider.dart';
import 'providers/Announcementprovider.dart';
import 'package:image_picker/image_picker.dart';
import 'providers/Authprovider.dart';

class AddAnnouncement extends StatefulWidget {
  @override
  _AddAnnouncementState createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    final announcementProvider = Provider.of<AnnouncementProvider>(context);

    void addAnnouncement() async {
      if (titleController.text.trim().isEmpty ||
          descriptionController.text.trim().isEmpty ||
          _selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please provide a proper image")),
        );
      }

      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      announcementProvider.addAnnouncement(
        Provider.of<AuthProvider>(context, listen: false).token,
        Provider.of<AuthProvider>(context, listen: false).userId,
        titleController.text.trim(),
        descriptionController.text.trim(),
        base64Image,
      );
    }

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Announcement"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              addAnnouncement();
              Navigator.of(context).pushNamed('/Home');
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: 450,
        margin: EdgeInsets.only(top: 100, left: 10, right: 10),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: Colors.black,
                    hoverColor: Colors.black,
                    focusColor: Colors.black,
                    labelText: "Title",
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  controller: titleController,
                  keyboardType: TextInputType.text,
                ),

                TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  controller: descriptionController,
                ),
                SizedBox(height: 20),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
