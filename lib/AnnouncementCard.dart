import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bgam3/classes/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final Future<void> Function(String announcementId)? swipeToDelete;
  final String role;

  const AnnouncementCard({
    Key? key,
    required this.announcement,
    this.swipeToDelete,
    this.role = 'user', // Default to 'user' if not specified
  }) : super(key: key);

  Future<void> _confirmDelete(BuildContext context) async {
    if (swipeToDelete == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Announcement'),
            content: const Text(
              'Are you sure you want to delete this announcement?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await swipeToDelete!(announcement.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Announcement deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  bool _isBase64(String str) {
    return !str.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    void navigateToAnnouncementPage() {
      Navigator.of(context).pushNamed('/AnnRoute', arguments: announcement);
    }

    void navigateToEditAnnouncement() {
      Navigator.of(
        context,
      ).pushNamed('/EditAnnouncement', arguments: announcement);
    }

    var imageUrl =
        announcement.imageUrl?.isNotEmpty == true
            ? announcement.imageUrl
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTogPfhbLOk_neriTUlJLrzYaVQG1DszGsBLQ&s';

    // Main card content
    Widget cardContent = GestureDetector(
      onTap: navigateToAnnouncementPage,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child:
                    announcement.imageUrl != null
                        ? _isBase64(announcement.imageUrl!)
                            ? Image.memory(
                              base64Decode(announcement.imageUrl!),
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
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    announcement.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Only wrap with Dismissible if role is admin
    return role == 'admin'
        ? Dismissible(
          key: Key(announcement.id),
          direction: DismissDirection.horizontal, // Allow both directions
          background: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe left to right (edit)
              navigateToEditAnnouncement();
              return false; // Prevent dismissal
            } else {
              // Swipe right to left (delete)
              await _confirmDelete(context);
              return false; // Let _confirmDelete handle the dismissal logic
            }
          },
          child: cardContent,
        )
        : cardContent;
  }
}
