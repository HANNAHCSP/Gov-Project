import 'package:flutter/material.dart';
import 'package:bgam3/classes/advertisement.dart';
import 'dart:convert';

class AdvertisementAdminCard extends StatelessWidget {
  final Advertisement advertisement;
  final Function(String) approveAd;
  final Function(String) rejectAd;

  const AdvertisementAdminCard({
    Key? key,
    required this.advertisement,
    required this.approveAd,
    required this.rejectAd,
  }) : super(key: key);

  Future<void> _showConfirmationDialog(
    BuildContext context,
    String action,
    Function(String) actionFunction,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action Advertisement'),
          content: Text('Are you sure you want to $action this advertisement?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                action,
                style: TextStyle(
                  color: action == 'Approve' ? Colors.green : Colors.red,
                ),
              ),
              onPressed: () {
                actionFunction(advertisement.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        advertisement.image?.isNotEmpty == true
            ? advertisement.image
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTogPfhbLOk_neriTUlJLrzYaVQG1DszGsBLQ&s';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with Admin Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.orange[50],
                  child:
                      advertisement.image != null
                          ? Image.memory(
                            base64Decode(advertisement.image!),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                          : Image.network(
                            imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                          ),
                ),
              ),
              // Admin badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  advertisement.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  advertisement.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Approval Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          () => _showConfirmationDialog(
                            context,
                            'Approve',
                            approveAd,
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          () => _showConfirmationDialog(
                            context,
                            'Reject',
                            rejectAd,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
