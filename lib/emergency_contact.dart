import 'package:bgam3/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'emergency_service.dart';

class EmergencyContactScreen extends StatefulWidget {
  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = 'all'; // For filtering by category
  List<Map<String, dynamic>> _contactsList = [];
  bool _isLoading = false;

  // Available categories for filtering
  final List<String> _categories = [
    'all',
    'police',
    'fire',
    'medical',
    'rescue',
    'utility',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    setState(() => _isLoading = true);

    EmergencyContactsService.getEmergencyContactsStream().listen(
      (event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          setState(() {
            _contactsList =
                data.entries.map((e) {
                  final contact = Map<String, dynamic>.from(e.value as Map);
                  contact['id'] = e.key;
                  return contact;
                }).toList();

            // Sort by category and then by name
            _contactsList.sort((a, b) {
              final categoryComparison = (a['category'] ?? '')
                  .toString()
                  .compareTo((b['category'] ?? '').toString());
              if (categoryComparison != 0) return categoryComparison;
              return (a['name'] ?? '').toString().compareTo(
                (b['name'] ?? '').toString(),
              );
            });
            _isLoading = false;
          });
        } else {
          setState(() {
            _contactsList = [];
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        print('Error loading contacts: $error');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contacts: $error')),
        );
      },
    );
  }

  // Filter contacts based on search query and category
  List<Map<String, dynamic>> get _filteredContacts {
    List<Map<String, dynamic>> filtered = List.from(_contactsList);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((contact) {
            final name = (contact['name'] ?? '').toString().toLowerCase();
            final category =
                (contact['category'] ?? '').toString().toLowerCase();
            final phone = (contact['phone'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                category.contains(_searchQuery) ||
                phone.contains(_searchQuery);
          }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((contact) {
            return (contact['category'] ?? '').toString().toLowerCase() ==
                _selectedCategory;
          }).toList();
    }

    return filtered;
  }

  void _showPhoneInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.emergency, color: Colors.red[700], size: 28),
              SizedBox(width: 8),
              Text(
                "Emergency Call",
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Enter phone number",
                  prefixIcon: Icon(Icons.phone, color: Colors.red[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "This will initiate an emergency call",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _phoneController.clear();
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                _submitNumber(_phoneController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Call Now"),
            ),
          ],
        );
      },
    );
  }

  void _submitNumber(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      try {
        final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          throw Exception('Could not launch phone dialer');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not make call: $e"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _makeCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw Exception('Could not launch phone dialer');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not make call: $e"),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Widget _buildCategoryIcon(String category) {
    IconData icon;
    Color color;

    switch (category.toLowerCase()) {
      case 'police':
        icon = Icons.local_police;
        color = Colors.blue[700]!;
        break;
      case 'fire':
        icon = Icons.local_fire_department;
        color = Colors.red[700]!;
        break;
      case 'medical':
        icon = Icons.local_hospital;
        color = Colors.green[700]!;
        break;
      case 'rescue':
        icon = Icons.security;
        color = Colors.orange[700]!;
        break;
      case 'utility':
        icon = Icons.build;
        color = Colors.purple[700]!;
        break;
      default:
        icon = Icons.phone;
        color = Colors.grey[700]!;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      selectedColor: Colors.red[100],
      checkmarkColor: Colors.red[700],
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.red[700] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('all', 'All'),
          SizedBox(width: 8),
          _buildCategoryChip('police', 'Police'),
          SizedBox(width: 8),
          _buildCategoryChip('fire', 'Fire'),
          SizedBox(width: 8),
          _buildCategoryChip('medical', 'Medical'),
          SizedBox(width: 8),
          _buildCategoryChip('rescue', 'Rescue'),
          SizedBox(width: 8),
          _buildCategoryChip('utility', 'Utility'),
          SizedBox(width: 8),
          _buildCategoryChip('other', 'Other'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _filteredContacts;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header section with search and SOS
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      hintText: "Search contacts...",
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),

                // SOS Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showPhoneInputDialog,
                        customBorder: CircleBorder(),
                        splashColor: Colors.red.withOpacity(0.1),
                        highlightColor: Colors.red.withOpacity(0.2),
                        child: Ink(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.red[600]!,
                                Colors.red[700]!,
                                Colors.red[800]!,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emergency,
                                size: 36,
                                color: Colors.white,
                              ),
                              SizedBox(height: 6),
                              Text(
                                "SOS",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Filter Chips
          SizedBox(height: 16),
          _buildFilterChips(),
          SizedBox(height: 8),

          // Emergency Contacts List
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.red[700]),
                          SizedBox(height: 16),
                          Text(
                            "Loading contacts...",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : filteredContacts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contact_phone,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ||
                                    _selectedCategory != 'all'
                                ? "No contacts found"
                                : "No emergency contacts available",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchQuery.isNotEmpty ||
                              _selectedCategory != 'all')
                            Text(
                              "Try adjusting your search or filter",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        final name = contact['name'] ?? 'No Name';
                        final category = contact['category'] ?? 'Unknown';
                        final phone = contact['phone'] ?? 'N/A';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          child: InkWell(
                            onTap: () => _makeCall(phone),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Category Icon
                                  _buildCategoryIcon(category),
                                  SizedBox(width: 16),

                                  // Contact Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                category.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          phone,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Call Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: () => _makeCall(phone),
                                      icon: Icon(
                                        Icons.phone,
                                        color: Colors.green[700],
                                        size: 24,
                                      ),
                                      tooltip: 'Call $name',
                                    ),
                                  ),
                                ],
                              ),
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
    _searchController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
