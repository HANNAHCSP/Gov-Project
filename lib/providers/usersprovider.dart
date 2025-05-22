import 'package:flutter/material.dart';
import '../classes/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:bcrypt/bcrypt.dart";

class UsersProvider with ChangeNotifier {
  List<User> _users = [];

  final usersURL = Uri.parse(
    'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/',
  );

  Future<void> getUsersFromServer() async {
    try {
      var response = await http.get(usersURL);

      var fetchedData = json.decode(response.body) as Map<String, dynamic>;
      _users.clear();
      fetchedData.forEach((key, value) {
        _users.add(
          User(
            id: value['id'],
            name: value['name'],
            email: value['email'],
            password: value['password'],
            phone: value['phone'],
            address: value['address'],
          ),
        );
      });
      notifyListeners();
    } catch (err) {}
  }

  Future<void> createUser(
    String name,
    String email,
    String password,
    String phone,
    String address,
  ) async {
    await getUsersFromServer();
    for (var i = 0; i < _users.length; i++) {
      if (_users[i].email == email) {
        throw Exception('Email already exists');
      }
    }
    String id = DateTime.now().toString();
    var hashedPassword = await BCrypt.hashpw(password, BCrypt.gensalt());
    return http
        .post(
          usersURL,
          body: json.encode({
            'id': id,
            'name': name,
            'email': email,
            'password': hashedPassword,
            'phone': phone,
            'address': address,
          }),
        )
        .then((response) {
          _users.add(
            User(
              id: id,
              name: name,
              email: email,
              password: password,
              phone: phone,
              address: address,
            ),
          );
          notifyListeners();
        })
        .catchError((err) {
          print("Provider: ${err.toString()}");
          throw err;
        });
  }
}
