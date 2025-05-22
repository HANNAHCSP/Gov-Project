import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'providers/Announcementprovider.dart';
import 'providers/Authprovider.dart';
import 'classes/announcement.dart';

class EditAnnouncement extends StatefulWidget {
  final Announcement announcement;

  EditAnnouncement({required this.announcement});

  @override
  _EditAnnouncementState createState() => _EditAnnouncementState();
}

class _EditAnnouncementState extends State<EditAnnouncement> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  File? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.announcement.title);
    descriptionController = TextEditingController(
      text: widget.announcement.description,
    );
    _existingImageUrl = widget.announcement.imageUrl;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    void updateAnnouncement() async {
      if (titleController.text.trim().isEmpty ||
          descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all required fields")),
        );
        return;
      }

      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        base64Image = _existingImageUrl;
      }

      await announcementProvider.editAnnouncement(
        authProvider.token,
        authProvider.userId,
        authProvider.role,
        widget.announcement.id,
        titleController.text.trim(),
        descriptionController.text.trim(),
        base64Image ?? '',
      );

      Navigator.of(context).pushNamed('/Home');
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
        title: Text("Edit Announcement"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(icon: Icon(Icons.check), onPressed: updateAnnouncement),
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
                ] else if (_existingImageUrl != null &&
                    _existingImageUrl!.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Image.memory(
                    base64Decode(_existingImageUrl!),
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error loading image');
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
