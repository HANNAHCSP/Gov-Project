import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bgam3/providers/Advertisementprovider.dart';
import '/providers/Authprovider.dart';
import 'classes/advertisement.dart';

class EditAdvertisement extends StatefulWidget {
  final Advertisement advertisement;

  EditAdvertisement({required this.advertisement});

  @override
  _EditAdvertisementState createState() => _EditAdvertisementState();
}

class _EditAdvertisementState extends State<EditAdvertisement> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  File? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.advertisement.title);
    descriptionController = TextEditingController(
      text: widget.advertisement.description,
    );
    _existingImageUrl = widget.advertisement.image;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final advertisementProvider = Provider.of<AdvertisementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    void updateAdvertisement() async {
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

      await advertisementProvider.editAdvertisement(
        authProvider.token,
        authProvider.userId,
        authProvider.name,
        widget.advertisement.id,
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
        title: Text("Edit Advertisement"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(icon: Icon(Icons.check), onPressed: updateAdvertisement),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: 600,
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
