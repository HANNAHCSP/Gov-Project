import 'dart:convert';
import 'package:flutter/material.dart';
import 'providers/Authprovider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var nameController = TextEditingController();

  var authenticationMode = 0;
  // 0 for login and 1 for signup.
  // when 0: only email and password fields appear + button login + button sign up instead
  // when 1: email and password and confimp password appear + button sign up + button login instead

  void toggleAuthMode() {
    setState(() {
      authenticationMode == 0 ? authenticationMode = 1 : authenticationMode = 0;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: 600,
        margin: EdgeInsets.only(top: 100, left: 10, right: 10),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Image.network(
                  'https://img.freepik.com/free-vector/illustration-egypt-flag_53876-27140.jpg?semt=ais_hybrid&w=740',
                  width: 200,
                  height: 200,
                ),
                Center(
                  child: Text(
                    "Egypt Government App",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                if (authenticationMode == 1)
                  TextField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      fillColor: Colors.black,
                      hoverColor: Colors.black,
                      focusColor: Colors.black,
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    controller: nameController,
                    keyboardType: TextInputType.name,
                  ),
                TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: Colors.black,
                    hoverColor: Colors.black,
                    focusColor: Colors.black,
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  controller: passwordController,
                  obscureText: true,
                ),

                if (authenticationMode == 1)
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),

                ElevatedButton(
                  onPressed: () {
                    loginORsignup();
                  },
                  child:
                      (authenticationMode == 1)
                          ? Text(
                            "Sign up",
                            style: TextStyle(color: Colors.redAccent),
                          )
                          : Text(
                            "Login",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                ),

                TextButton(
                  onPressed: () {
                    toggleAuthMode();
                  },
                  child:
                      (authenticationMode == 1)
                          ? Text(
                            "Login instead",
                            style: TextStyle(color: Colors.redAccent),
                          )
                          : Text(
                            "Sign up instead",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loginORsignup() async {
    var authProv = Provider.of<AuthProvider>(context, listen: false);
    if (authenticationMode == 1) {
      if (confirmPasswordController.text.trim() !=
          passwordController.text.trim()) {
        final snackBar = SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (passwordController.text.trim().length < 6) {
        final snackBar = SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
      var successOrError = await authProv.signup(
        n: nameController.text.trim(),
        em: emailController.text.trim(),
        pass: passwordController.text.trim(),
      );
      if (successOrError == "success") {
        Navigator.of(context).pushReplacementNamed('/Home');
      } else if (successOrError.contains("EMAIL_EXISTS")) {
        final snackBar = SnackBar(
          content: Text('Email already exists'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      var successOrError = await authProv.login(
        em: emailController.text.trim(),
        pass: passwordController.text.trim(),
      );

      if (successOrError == "success") {
        Navigator.of(context).pushReplacementNamed('/Home');
      } else if (successOrError.contains("INVALID_LOGIN_CREDENTIALS")) {
        print("Success or error is $successOrError");
        final snackBar = SnackBar(
          content: Text('Invalid Credentials'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
