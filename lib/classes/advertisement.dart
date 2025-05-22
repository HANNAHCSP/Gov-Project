import 'package:flutter/material.dart';

class Advertisement {
  String id;
  String userId;
  String businessName;
  String title;
  String description;
  String image;
  DateTime date;
  String status;

  Advertisement({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.status,
  });
}
