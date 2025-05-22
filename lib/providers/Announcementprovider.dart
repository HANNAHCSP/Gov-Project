import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../classes/announcement.dart';
import '../classes/comment.dart';

class AnnouncementProvider with ChangeNotifier {
  List<Announcement> _announcements = [];
  List<Comment> _comments = [];

  List<Announcement> get announcements {
    return _announcements;
  }

  List<Comment> get comments {
    return _comments;
  }

  Future<void> getAnnouncementsFromServer(String token, String userId) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/announcements.json/?auth=$token',
    );

    var allAnnouncements = await http.get(url);
    var announcements = json.decode(allAnnouncements.body);
    print("Announcements is $announcements");
    _announcements.clear();
    _comments.clear();
    if (announcements != null) {
      announcements.forEach((key, value) {
        if (value['comments'] != null) {
          value['comments'].forEach((keyTwo, element) {
            _comments.add(
              Comment(
                id: keyTwo,
                userId: element['userId'],
                userName: element['userName'],
                announcementId: key,
                text: element['text'],
                date: DateTime.parse(element['date']),
              ),
            );
          });
        }
        _announcements.add(
          Announcement(
            id: key,
            title: value['title'],
            description: value['description'],
            imageUrl: value['imageUrl'],
            date: DateTime.parse(value['date']),
          ),
        );
      });
    }
    notifyListeners();
  }

  Future<void> postComment(
    String announcementId,
    String userId,
    String userName,
    String token,
    String text,
  ) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/announcements/$announcementId/comments.json?auth=$token',
    );

    final dateTimeNow = DateTime.now();
    return http
        .post(
          url,
          body: json.encode({
            'userId': userId,
            'announcementId': announcementId,
            'userName': userName,
            'text': text,
            'date': dateTimeNow.toString(),
          }),
        )
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          _comments.add(
            Comment(
              id: content['name'],
              announcementId: announcementId,
              userName: userName,
              userId: userId,
              text: text,
              date: dateTimeNow,
            ),
          );
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> editAnnouncement(
    String token,
    String userId,
    String role,
    String announcementId,
    String title,
    String description,
    String imageUrl,
  ) async {
    var announcement = _announcements.firstWhere(
      (element) => element.id == announcementId,
    );
    if (role != "admin") return;
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/announcements/$announcementId.json?auth=$token',
    );

    return http
        .patch(
          url,
          body: jsonEncode({
            "title": title,
            "description": description,
            "image": imageUrl,
          }),
        )
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          _announcements.removeWhere((element) => element.id == announcementId);
          _announcements.add(
            Announcement(
              id: announcementId,
              title: title,
              description: description,
              imageUrl: imageUrl,
              date: announcement.date,
            ),
          );

          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> addAnnouncement(
    String token,
    String userId,
    String title,
    String description,
    String imageUrl,
  ) async {
    print(
      "token is $token and userId is $userId and title is $title and description is $description and imageUrl is $imageUrl",
    );
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/announcements.json/?auth=$token',
    );

    return http
        .post(
          url,
          body: json.encode({
            'title': title,
            'description': description,
            'imageUrl': imageUrl,
            'date': DateTime.now().toString(),
          }),
        )
        .then((response) {
          var content = json.decode(response.body);
          _announcements.add(
            Announcement(
              id: content.id,
              title: title,
              description: description,
              imageUrl: imageUrl,
              date: content.date,
            ),
          );

          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> deleteAnnouncement(
    String token,
    String role,
    String announcementId,
  ) async {
    if (role != "admin") return;
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/announcements/$announcementId.json?auth=$token',
    );

    return http
        .delete(url)
        .then((response) {
          print("Delete announcement response is $response");
          var content = json.decode(response.body);
          print("Content is $content");
          _announcements.removeWhere((element) => element.id == announcementId);
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }
}
