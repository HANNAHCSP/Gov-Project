import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'providers/RequestProvider.dart';
import 'providers/Authprovider.dart';
import 'classes/request.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  Function acceptRequest;
  Function rejectRequest;
  RequestCard({
    required this.request,
    required this.acceptRequest,
    required this.rejectRequest,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(request.businessName),
        subtitle: Text(request.description),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  acceptRequest(request);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  rejectRequest(request);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
