import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/RequestProvider.dart';
import 'providers/Authprovider.dart';
import 'RequestCard.dart';
import 'classes/request.dart';

class AdminRequestsPage extends StatefulWidget {
  @override
  _AdminRequestsPageState createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final requestProvider = Provider.of<RequestProvider>(context);

    if (requestProvider.requests.isEmpty) {
      requestProvider.getRequestsFromServer(
        authProvider.token,
        authProvider.userId,
      );
    }

    Future<void> acceptRequest(Request request) async {
      requestProvider.acceptRequest(
        authProvider.token,
        authProvider.userId,
        authProvider.role,
        request.id,
      );
    }

    Future<void> rejectRequest(Request request) async {
      requestProvider.rejectRequest(
        authProvider.token,
        authProvider.userId,
        authProvider.role,
        request.id,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Requests"), backgroundColor: Colors.red),
      body: ListView.builder(
        itemCount: requestProvider.requests.length,
        itemBuilder: (context, index) {
          return RequestCard(
            request: requestProvider.requests[index],
            acceptRequest: acceptRequest,
            rejectRequest: rejectRequest,
          );
        },
      ),
    );
  }
}
