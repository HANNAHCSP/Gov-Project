import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String _token = "";
  DateTime _expiryDate = DateTime.utc(1970);
  String _name = "";
  String _userId = "";
  bool _authenticated = false;
  String _role = "";

  String get role {
    return _role;
  }

  bool get isAuthenticated {
    return _authenticated;
  }

  String get name {
    return _name;
  }

  String get token {
    if (_expiryDate != DateTime.utc(1970) &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != "") {
      return _token;
    }
    return "";
  }

  String get userId {
    return _userId;
  }

  Future<String> signup({
    required String n,
    required String em,
    required String pass,
  }) async {
    final url = Uri.parse(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyCYlzvMjM9QxntwqJ2fX9NbTJwumflThMI',
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': em,
          'password': pass,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        return responseData['error']['message'];
      } else {
        _authenticated = true;
        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expiryDate = DateTime.now().add(
          Duration(seconds: int.parse(responseData['expiresIn'])),
        );
        final userUrl = Uri.parse(
          'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/users.json/?auth=$_token',
        );

        var postUser = await http.post(
          userUrl,
          body: json.encode({
            'name': n,
            'email': em,
            'password': pass,
            'role': 'citizen',
          }),
        );

        _role = 'citizen';
        _name = n;
        return "success";
      }
    } catch (err) {
      print("The error is: " + err.toString());
      throw err;
    }
  }

  Future<String> login({required String em, required String pass}) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCYlzvMjM9QxntwqJ2fX9NbTJwumflThMI',
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': em,
          'password': pass,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        print(responseData['error']['message']);
        return responseData['error']['message'] as String;
      } else {
        _authenticated = true;
        _token = responseData['idToken'];
        _expiryDate = DateTime.now().add(
          Duration(seconds: int.parse(responseData['expiresIn'])),
        );
        final userUrl = Uri.parse(
          'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/users.json/?auth=$_token',
        );

        var allUsers = await http.get(userUrl);
        var users = json.decode(allUsers.body);
        users.forEach((key, value) {
          if (value['email'] == em) {
            _userId = key;
            _role = value['role'];
            _name = value['name'];
          }
        });
        return "success";
      }
    } catch (err) {
      print("The error is: " + err.toString());
      throw err;
    }
  }

  void logoutOfAccount() {
    _authenticated = false;
    _token = "";
    _userId = "";
    _expiryDate = DateTime.utc(1970);
    _role = "";
  }
}
