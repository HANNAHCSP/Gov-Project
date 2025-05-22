import 'package:flutter/material.dart';
import 'package:bgam3/classes/advertisement.dart';
import 'dart:convert';

class AdvertisementCard extends StatelessWidget {
  final Advertisement advertisement;

  const AdvertisementCard({Key? key, required this.advertisement})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        advertisement.image?.isNotEmpty == true
            ? advertisement.image
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTogPfhbLOk_neriTUlJLrzYaVQG1DszGsBLQ&s';

    return GestureDetector(
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Ad Badge
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
                // Ad badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[800],
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
                  // Title with different styling
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

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
