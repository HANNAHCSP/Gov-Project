import 'package:flutter/material.dart';
import 'package:bgam3/classes/announcement.dart';
import 'dart:convert';

class AnnouncementCardBasic extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCardBasic({Key? key, required this.announcement})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        announcement.imageUrl?.isNotEmpty == true
            ? announcement.imageUrl
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTogPfhbLOk_neriTUlJLrzYaVQG1DszGsBLQ&s';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child:
                  announcement.imageUrl != null
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
    );
  }
}
