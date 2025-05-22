import 'package:flutter/material.dart';
import '/providers/Authprovider.dart';
import 'package:provider/provider.dart';
import 'providers/RequestProvider.dart';

class AdvertiserApplication extends StatefulWidget {
  @override
  _AdvertiserApplicationState createState() => _AdvertiserApplicationState();
}

class _AdvertiserApplicationState extends State<AdvertiserApplication> {
  final businessNameController = TextEditingController();
  final descriptionController = TextEditingController();

  bool fetched = false;
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final requestProvider = Provider.of<RequestProvider>(context);

    void addRequest() {
      requestProvider.addRequest(
        authProvider.token,
        authProvider.userId,
        authProvider.role,
        authProvider.name,
        businessNameController.text.trim(),
        descriptionController.text.trim(),
      );

      Navigator.of(context).pushNamed('/Home');
    }

    if (requestProvider.requests.isEmpty && !fetched) {
      setState(() {
        requestProvider.getRequestsFromServer(
          authProvider.token,
          authProvider.userId,
        );
        fetched = true;
      });
    }

    bool requested = requestProvider.checkIfUserAlreadyApplied(
      authProvider.token,
      authProvider.userId,
    );

    print("Requested is $requested");

    return Scaffold(
      appBar: AppBar(
        title: Text("Apply to be an Advertiser"),
        backgroundColor: Colors.red,
      ),
      body: Container(
        width: double.infinity,
        height: 600,
        margin: EdgeInsets.only(top: 100, left: 10, right: 10),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child:
              requested
                  ? Center(
                    child: Text(
                      "You have already applied before",
                      style: TextStyle(color: Colors.red, fontSize: 25),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            fillColor: Colors.black,
                            hoverColor: Colors.black,
                            focusColor: Colors.black,
                            labelText: "Business Name",
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          controller: businessNameController,
                          keyboardType: TextInputType.text,
                        ),

                        TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Description",
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          controller: descriptionController,
                          maxLines: 4,
                        ),

                        ElevatedButton(
                          onPressed: () {
                            addRequest();
                          },
                          child: Text(
                            "Apply",
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
}
