import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../classes/request.dart';

class RequestProvider with ChangeNotifier {
  List<Request> _requests = [];
  List<Request> _allRequests = [];

  List<Request> get requests {
    return _requests;
  }

  List<Request> get allRequests {
    return _allRequests;
  }

  Future<void> getRequestsFromServer(String token, String userId) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/requests.json/?auth=$token',
    );

    try {
      _requests.clear();
      var allRequests = await http.get(url);
      var requests = json.decode(allRequests.body);
      print("Requests is $requests");
      if (requests != null) {
        requests.forEach((key, value) {
          _allRequests.add(
            Request(
              id: key,
              userId: value['userId'],
              userName: value['userName'],
              businessName: value['businessName'],
              description: value['description'],
              status: value['status'],
            ),
          );
          if (value['status'] == 'pending') {
            _requests.add(
              Request(
                id: key,
                userId: value['userId'],
                userName: value['userName'],
                businessName: value['businessName'],
                description: value['description'],
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

  Future<void> addRequest(
    String token,
    String userId,
    String role,
    String userName,
    String businessName,
    String description,
  ) async {
    if (role == 'advertiser' || role == 'admin') {
      throw ErrorDescription('You cannot sign up to be an advertiser');
    }
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/requests.json/?auth=$token',
    );

    return http
        .post(
          url,
          body: json.encode({
            'userId': userId,
            'userName': userName,
            'businessName': businessName,
            'description': description,
            'status': 'pending',
          }),
        )
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          _requests.add(
            Request(
              id: content['name'],
              userId: userId,
              userName: userName,
              businessName: businessName,
              description: description,
              status: 'pending',
            ),
          );
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> changeUserRole(String token, String userId, String role) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/users/$userId.json?auth=$token',
    );
    return http
        .patch(url, body: json.encode({'role': role}))
        .then((response) {
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> changeUserName(String token, String userId, String name) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/users/$userId.json?auth=$token',
    );
    return http
        .patch(url, body: json.encode({'name': name}))
        .then((response) {
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> acceptRequest(
    String token,
    String userId,
    String role,
    String requestId,
  ) async {
    if (role != 'admin') {
      throw ErrorDescription('Only admins can accept requests');
    }
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/requests/$requestId.json?auth=$token',
    );

    return http
        .patch(url, body: json.encode({'status': 'accepted'}))
        .then((response) {
          var content = json.decode(response.body);
          var request = _requests.firstWhere(
            (element) => element.id == requestId,
          );
          changeUserRole(token, request.userId, role);
          changeUserName(token, request.userId, request.businessName);
          _requests.removeWhere((element) => element.id == requestId);
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  bool checkIfUserAlreadyApplied(String token, String userId) {
    var requested = false;
    _allRequests.forEach((element) {
      print("Element user id is $element.userId and user id is $userId");
      if (element.userId == userId) {
        requested = true;
      }
    });
    return requested;
  }

  Future<void> rejectRequest(
    String token,
    String userId,
    String role,
    String requestId,
  ) async {
    if (role != 'admin') {
      throw ErrorDescription('Only admins can reject requests');
      return;
    }
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/requests/$requestId.json?auth=$token',
    );

    return http
        .patch(url, body: json.encode({'status': 'rejected'}))
        .then((response) {
          var content = json.decode(response.body);
          _requests.removeWhere((element) => element.id == requestId);
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }
}
