import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'emergency_service.dart';
import 'providers/Authprovider.dart'; // Import your auth provider

class SuggestionsScreen extends StatefulWidget {
  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  final DatabaseReference _suggestionsRef =
      EmergencyContactsService.suggestionsRef;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  List<Map<String, dynamic>> _suggestionsList = [];
  bool _isLoading = false;
  String _currentFilter = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() {
    _suggestionsRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          setState(() {
            _suggestionsList =
                data.entries.map((e) {
                  final suggestion = Map<String, dynamic>.from(e.value as Map);
                  suggestion['id'] = e.key;
                  return suggestion;
                }).toList();

            // Sort by date (newest first)
            _suggestionsList.sort((a, b) {
              final dateA =
                  DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
              final dateB =
                  DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
              return dateB.compareTo(dateA);
            });
          });
        } else {
          setState(() {
            _suggestionsList = [];
          });
        }
      },
      onError: (error) {
        print('Error loading suggestions: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading suggestions: $error')),
        );
      },
    );
  }

  // Filter suggestions based on current filter and user role
  List<Map<String, dynamic>> get _filteredSuggestions {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    List<Map<String, dynamic>> filtered = List.from(_suggestionsList);

    // Role-based filtering
    if (authProvider.role != "admin") {
      // Non-admins only see approved suggestions and their own pending ones
      filtered =
          filtered.where((suggestion) {
            return suggestion['status'] == 'approved' ||
                (suggestion['status'] == 'pending' &&
                    suggestion['submittedBy'] ==
                        authProvider
                            .userId); // You'll need to add userId to auth provider
          }).toList();
    }

    // Status filtering
    if (_currentFilter != 'all') {
      filtered =
          filtered.where((suggestion) {
            return suggestion['status'] == _currentFilter;
          }).toList();
    }

    return filtered;
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 70,
      );
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<String?> _convertImageToBase64(File image) async {
    try {
      Uint8List imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);
      return base64String;
    } catch (e) {
      print('Error converting image to base64: $e');
      throw e;
    }
  }

  void _submitSuggestion() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both title and description')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? imageBase64;
      if (_selectedImage != null) {
        imageBase64 = await _convertImageToBase64(_selectedImage!);
      }

      Map<String, dynamic> newSuggestion = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'date': DateTime.now().toIso8601String(),
        'likes': 0,
        'dislikes': 0,
        'status': 'pending',
        'submittedBy': authProvider.userId ?? 'unknown', // Track who submitted
        'submitterName': authProvider.name ?? 'Anonymous', // Display name
        'imageBase64': imageBase64 ?? '',
        'location': {
          'latitude': _latitudeController.text.trim(),
          'longitude': _longitudeController.text.trim(),
        },
      };

      await EmergencyContactsService.submitSuggestion(newSuggestion);

      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _latitudeController.clear();
        _longitudeController.clear();
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Suggestion submitted successfully! It will be reviewed by administrators.',
          ),
        ),
      );
    } catch (e) {
      print('Error submitting suggestion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting suggestion: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Admin functions for managing suggestions
  void _updateSuggestionStatus(String id, String newStatus) async {
    try {
      await EmergencyContactsService.updateSuggestionStatus(id, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suggestion $newStatus successfully!')),
      );
    } catch (e) {
      print('Error updating suggestion status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating suggestion status')),
      );
    }
  }

  void _likeSuggestion(String id) async {
    try {
      await EmergencyContactsService.likeSuggestion(id);
    } catch (e) {
      print('Error liking suggestion: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error liking suggestion')));
    }
  }

  void _dislikeSuggestion(String id) async {
    try {
      await EmergencyContactsService.dislikeSuggestion(id);
    } catch (e) {
      print('Error disliking suggestion: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error disliking suggestion')));
    }
  }

  Widget _buildImageFromBase64(String base64String) {
    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: Icon(Icons.error, color: Colors.grey),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
        break;
      case 'pending':
      default:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.pending;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', 'All'),
          if (authProvider.role == "admin") ...[
            SizedBox(width: 8),
            _buildFilterChip('pending', 'Pending'),
            SizedBox(width: 8),
            _buildFilterChip('approved', 'Approved'),
            SizedBox(width: 8),
            _buildFilterChip('rejected', 'Rejected'),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
      },
      selectedColor: Colors.red[100],
      checkmarkColor: Colors.red[700],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final filteredSuggestions = _filteredSuggestions;

    return Scaffold(
      appBar: AppBar(
        title: Text("Suggestions"),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Form section
          Container(
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Submit a New Suggestion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Title *",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description *",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latitudeController,
                            decoration: InputDecoration(
                              labelText: "Latitude",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _longitudeController,
                            decoration: InputDecoration(
                              labelText: "Longitude",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.image),
                          label: Text("Pick Image"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                          ),
                        ),
                        if (_selectedImage != null) ...[
                          SizedBox(width: 12),
                          Text(
                            "Image selected",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ],
                    ),
                    if (_selectedImage != null)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitSuggestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child:
                          _isLoading
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("Submitting..."),
                                ],
                              )
                              : Text(
                                "Submit Suggestion",
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter chips (only show for admins)
          if (authProvider.role == "admin") _buildFilterChips(),

          // Suggestions list section
          Expanded(
            child:
                filteredSuggestions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _currentFilter == 'all'
                                ? 'No suggestions yet'
                                : 'No ${_currentFilter} suggestions',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _currentFilter == 'all'
                                ? 'Be the first to submit one!'
                                : 'Try changing the filter',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = filteredSuggestions[index];
                        final date = DateTime.tryParse(
                          suggestion['date'] ?? '',
                        );
                        final formattedDate =
                            date != null
                                ? '${date.day}/${date.month}/${date.year}'
                                : 'Unknown date';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        suggestion['title'] ?? 'No title',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    _buildStatusChip(
                                      suggestion['status'] ?? 'pending',
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  suggestion['description'] ?? 'No description',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'By: ${suggestion['submitterName'] ?? 'Anonymous'}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Submitted: $formattedDate',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if ((suggestion['imageBase64'] ?? '')
                                    .isNotEmpty) ...[
                                  SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildImageFromBase64(
                                      suggestion['imageBase64'],
                                    ),
                                  ),
                                ],
                                if ((suggestion['location']?['latitude'] ?? '')
                                        .isNotEmpty ||
                                    (suggestion['location']?['longitude'] ?? '')
                                        .isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Location: ${suggestion['location']?['latitude'] ?? 'N/A'}, "
                                        "${suggestion['location']?['longitude'] ?? 'N/A'}",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    // Like/Dislike buttons (only for approved suggestions)
                                    if (suggestion['status'] == 'approved') ...[
                                      IconButton(
                                        icon: Icon(
                                          Icons.thumb_up,
                                          color: Colors.green,
                                        ),
                                        onPressed:
                                            () => _likeSuggestion(
                                              suggestion['id'],
                                            ),
                                      ),
                                      Text("${suggestion['likes'] ?? 0}"),
                                      SizedBox(width: 16),
                                      IconButton(
                                        icon: Icon(
                                          Icons.thumb_down,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _dislikeSuggestion(
                                              suggestion['id'],
                                            ),
                                      ),
                                      Text("${suggestion['dislikes'] ?? 0}"),
                                    ],
                                    Spacer(),
                                    // Admin approval/rejection buttons
                                    if (authProvider.role == "admin" &&
                                        suggestion['status'] == 'pending') ...[
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => _updateSuggestionStatus(
                                              suggestion['id'],
                                              'approved',
                                            ),
                                        icon: Icon(Icons.check, size: 16),
                                        label: Text("Approve"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(0, 32),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => _updateSuggestionStatus(
                                              suggestion['id'],
                                              'rejected',
                                            ),
                                        icon: Icon(Icons.close, size: 16),
                                        label: Text("Reject"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(0, 32),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
}
