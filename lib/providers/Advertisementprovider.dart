import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../classes/advertisement.dart';

class AdvertisementProvider with ChangeNotifier {
  List<Advertisement> _advertisements = [];
  List<Advertisement> _allAdvertisements = [];

  List<Advertisement> get advertisements {
    return _advertisements;
  }

  List<Advertisement> get allAdvertisements {
    return _allAdvertisements;
  }

  List<Advertisement> getPendingAdvertisements() {
    return _allAdvertisements
        .where((element) => element.status == 'pending')
        .toList();
  }

  Future<void> getAdvertisementsFromServer(String token, String userId) async {
    _allAdvertisements.clear();
    _advertisements.clear();
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/advertisements.json/?auth=$token',
    );

    try {
      var allAdvertisements = await http.get(url);
      var advertisements = json.decode(allAdvertisements.body);
      print("Advertisements is $advertisements");
      if (advertisements != null) {
        advertisements.forEach((key, value) {
          if (value['status'] != 'rejected') {
            _allAdvertisements.add(
              Advertisement(
                id: key,
                userId: value['userId'],
                businessName: value['businessName'],
                title: value['title'],
                description: value['description'],
                image: value['image'],
                date: DateTime.parse(value['date']),
                status: value['status'],
              ),
            );
          }
          if (value['status'] == 'approved') {
            _advertisements.add(
              Advertisement(
                id: key,
                userId: value['userId'],
                businessName: value['businessName'],
                title: value['title'],
                description: value['description'],
                image: value['image'],
                date: DateTime.parse(value['date']),
                status: value['status'],
              ),
            );
          }
        });
      }
      notifyListeners();
    } catch (err) {
      print("The error is: " + err.toString());
    }
  }

  Future<void> addAdvertisement(
    String token,
    String userId,
    String businessName,
    String title,
    String description,
    String imageUrl,
  ) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/advertisements.json/?auth=$token',
    );

    return http
        .post(
          url,
          body: json.encode({
            'userId': userId,
            'businessName': businessName,
            'title': title,
            'description': description,
            'image': imageUrl,
            'date': DateTime.now().toString(),
            'status': 'pending',
          }),
        )
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          _allAdvertisements.add(
            Advertisement(
              id: content['name'],
              userId: userId,
              businessName: businessName,
              title: title,
              description: description,
              image: imageUrl,
              date: DateTime.now(),
              status: 'pending',
            ),
          );
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> editAdvertisement(
    String token,
    String userId,
    String businessName,
    String advertisementId,
    String title,
    String description,
    String imageUrl,
  ) async {
    var advertisement = _allAdvertisements.firstWhere(
      (element) => element.id == advertisementId,
    );
    if (advertisement.userId != userId) return;

    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/advertisements/$advertisementId.json?auth=$token',
    );

    return http
        .patch(
          url,
          body: json.encode({
            'userId': userId,
            'businessName': businessName,
            'title': title,
            'description': description,
            'image': imageUrl,
            'status': advertisement.status,
          }),
        )
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          _allAdvertisements.removeWhere(
            (element) => element.id == advertisementId,
          );
          _advertisements.removeWhere(
            (element) => element.id == advertisementId,
          );
          if (advertisement.status != 'rejected') {
            _allAdvertisements.add(
              Advertisement(
                id: advertisement.id,
                userId: advertisement.userId,
                businessName: advertisement.businessName,
                title: title,
                description: description,
                image: imageUrl,
                date: advertisement.date,
                status: advertisement.status,
              ),
            );
          }
          if (advertisement.status == 'approved') {
            _advertisements.add(
              Advertisement(
                id: advertisement.id,
                userId: advertisement.userId,
                businessName: advertisement.businessName,
                title: title,
                description: description,
                image: imageUrl,
                date: advertisement.date,
                status: advertisement.status,
              ),
            );
          }
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> approveAdvertisement(
    String token,
    String userId,
    String role,
    String advertisementId,
  ) async {
    if (role != 'admin') return;
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/advertisements/$advertisementId.json?auth=$token',
    );

    return http
        .patch(url, body: json.encode({'status': 'approved'}))
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          var advertisement = _allAdvertisements.firstWhere(
            (element) => element.id == advertisementId,
          );
          _advertisements.add(
            Advertisement(
              id: advertisement.id,
              userId: advertisement.userId,
              businessName: advertisement.businessName,
              title: advertisement.title,
              description: advertisement.description,
              image: advertisement.image,
              date: advertisement.date,
              status: advertisement.status,
            ),
          );
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> rejectAdvertisement(
    String token,
    String userId,
    String role,
    String advertisementId,
  ) async {
    if (role != 'admin') return;
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/advertisements/$advertisementId.json?auth=$token',
    );

    return http
        .patch(url, body: json.encode({'status': 'rejected'}))
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }
}
