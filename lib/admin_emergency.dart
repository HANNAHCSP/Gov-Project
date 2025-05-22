import 'package:bgam3/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'emergency_service.dart';
import 'suggestions.dart';

class AdminEmergencyScreen extends StatefulWidget {
  @override
  _AdminEmergencyScreenState createState() => _AdminEmergencyScreenState();
}

class _AdminEmergencyScreenState extends State<AdminEmergencyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = 'Emergency';
  bool _isLoading = false;
  bool _showAddForm = false;

  // Available categories for emergency contacts
  final List<String> _categories = [
    'Emergency',
    'Police',
    'Fire',
    'Medical',
    'Rescue',
    'Utility',
    'Other',
  ];

  void _addEmergencyContact() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showSnackBar("Please fill in all fields", Colors.red[700]!);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String newKey =
          EmergencyContactsService.emergencyContactsRef.push().key ?? "";
      await EmergencyContactsService.emergencyContactsRef.child(newKey).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
      });

      _nameController.clear();
      _phoneController.clear();
      setState(() => _showAddForm = false);
      _showSnackBar(
        "Emergency contact added successfully!",
        Colors.red[700]!, // Changed from green to red
      );
    } catch (e) {
      _showSnackBar("Failed to add contact: $e", Colors.red[700]!);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteContact(String contactId, String contactName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 28),
                SizedBox(width: 8),
                Text(
                  "Delete Contact",
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text("Are you sure you want to delete '$contactName'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await EmergencyContactsService.emergencyContactsRef
                        .child(contactId)
                        .remove();
                    Navigator.pop(context);
                    _showSnackBar(
                      "Contact deleted successfully!",
                      Colors.red[700]!, // Changed from green to red
                    );
                  } catch (e) {
                    _showSnackBar(
                      "Failed to delete contact: $e",
                      Colors.red[700]!,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
                child: Text("Delete"),
              ),
            ],
          ),
    );
  }

  void _editContact(String contactId, Map<String, dynamic> contact) {
    final nameController = TextEditingController(text: contact['name']);
    final phoneController = TextEditingController(text: contact['phone']);
    String editCategory = contact['category'] ?? 'Emergency';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Colors.red[700],
                  size: 28,
                ), // Changed from blue to red
                SizedBox(width: 8),
                Text(
                  "Edit Contact",
                  style: TextStyle(
                    color: Colors.red[700], // Changed from blue to red
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: StatefulBuilder(
              builder:
                  (context, setDialogState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Contact Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: editCategory,
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items:
                            _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged:
                            (value) =>
                                setDialogState(() => editCategory = value!),
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty) {
                    _showSnackBar(
                      "Please fill in all fields",
                      Colors.red[700]!,
                    );
                    return;
                  }

                  try {
                    await EmergencyContactsService.emergencyContactsRef
                        .child(contactId)
                        .update({
                          'name': nameController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'category': editCategory,
                        });
                    Navigator.pop(context);
                    _showSnackBar(
                      "Contact updated successfully!",
                      Colors.red[700]!, // Changed from green to red
                    );
                  } catch (e) {
                    _showSnackBar(
                      "Failed to update contact: $e",
                      Colors.red[700]!,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700], // Changed from blue to red
                  foregroundColor: Colors.white,
                ),
                child: Text("Update"),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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

  Widget _buildAddContactForm() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _showAddForm ? null : 0,
      child:
          _showAddForm
              ? Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: Colors.red[700], // Changed from blue to red
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Add New Contact",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700], // Changed from blue to red
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () => setState(() => _showAddForm = false),
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Contact Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.red[700],
                        ), // Changed from blue to red
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red[700]!, // Changed from blue to red
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.red[700],
                        ), // Changed from blue to red
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red[700]!, // Changed from blue to red
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.category,
                          color: Colors.red[700], // Changed from blue to red
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red[700]!, // Changed from blue to red
                            width: 2,
                          ),
                        ),
                      ),
                      items:
                          _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => _selectedCategory = value!),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addEmergencyContact,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red[700], // Changed from blue to red
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add),
                                        SizedBox(width: 8),
                                        Text(
                                          "Add Contact",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      body: Column(
        children: [
          // Search bar (moved from header but functionality preserved)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.grey[800]),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                hintText: "Search emergency contacts...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.red[700]!, width: 2),
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

          // Add Contact Form
          _buildAddContactForm(),

          // Emergency Contacts List
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: EmergencyContactsService.getEmergencyContactsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.red[700],
                        ), // Changed from blue to red
                        SizedBox(height: 16),
                        Text(
                          "Loading contacts...",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[400]),
                        SizedBox(height: 16),
                        Text(
                          "Error loading contacts",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[600],
                          ),
                        ),
                        Text(
                          "${snapshot.error}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null || data is! Map) {
                  return Center(
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
                          "No emergency contacts available",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Add some contacts to get started",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final contacts = data as Map<Object?, Object?>;

                // Apply Search Filtering with proper type handling
                final filteredContacts =
                    contacts.entries.where((entry) {
                      if (entry.value is! Map) return false;
                      final contact = entry.value as Map<Object?, Object?>;
                      final contactName =
                          (contact['name'] ?? '').toString().toLowerCase();
                      final contactCategory =
                          (contact['category'] ?? '').toString().toLowerCase();
                      final contactPhone =
                          (contact['phone'] ?? '').toString().toLowerCase();

                      return contactName.contains(_searchQuery) ||
                          contactCategory.contains(_searchQuery) ||
                          contactPhone.contains(_searchQuery);
                    }).toList();

                // Sort contacts
                filteredContacts.sort((a, b) {
                  final aContact = a.value as Map<Object?, Object?>;
                  final bContact = b.value as Map<Object?, Object?>;
                  final categoryComparison = (aContact['category'] ?? '')
                      .toString()
                      .compareTo((bContact['category'] ?? '').toString());
                  if (categoryComparison != 0) return categoryComparison;
                  return (aContact['name'] ?? '').toString().compareTo(
                    (bContact['name'] ?? '').toString(),
                  );
                });

                if (filteredContacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No contacts found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Try adjusting your search query",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final entry = filteredContacts[index];
                    final contact = entry.value as Map<Object?, Object?>;
                    final contactId = entry.key.toString();
                    final name = (contact['name'] ?? 'No Name').toString();
                    final category =
                        (contact['category'] ?? 'Unknown').toString();
                    final phone = (contact['phone'] ?? 'N/A').toString();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Category Icon
                            _buildCategoryIcon(category.toString()),
                            SizedBox(width: 16),

                            // Contact Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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

                            // Action Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      // Convert Map<Object?, Object?> to Map<String, dynamic>
                                      Map<String, dynamic> convertedContact =
                                          {};
                                      contact.forEach((key, value) {
                                        convertedContact[key.toString()] =
                                            value;
                                      });
                                      _editContact(contactId, convertedContact);
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.grey[800],
                                      size: 20,
                                    ),
                                    tooltip: 'Edit $name',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed:
                                        () => _deleteContact(contactId, name),
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red[700],
                                      size: 20,
                                    ),
                                    tooltip: 'Delete $name',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showAddForm = !_showAddForm),
        backgroundColor: Colors.red[700], // Changed from blue to red
        foregroundColor: Colors.white,
        icon: Icon(_showAddForm ? Icons.close : Icons.add),
        label: Text(_showAddForm ? "Cancel" : "Add Contact"),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
