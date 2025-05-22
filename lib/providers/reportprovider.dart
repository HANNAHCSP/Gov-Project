import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../classes/report.dart';
import 'Authprovider.dart';

class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];

  List<Report> get getAllReports {
    print("getting all reports...");
    print("Reports: ${_reports.length}");
    return [..._reports]; // return a copy of the list
  }

  // Add report
  Future<void> addReport(
    String content,
    String imageUrl,
    String location,
    String userId,
    String token,
  ) async {
    final reportsURL = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/Reports.json?auth=$token',
    );
    print('Submitting report...');

    try {
      final response = await http.post(
        reportsURL,
        body: json.encode({
          'content': content,
          'imageUrl': imageUrl,
          'location': location,
          'userId': userId,
          'status': 'pending',
        }),
      );
      print("Response: ${response.body}");

      final newReport = Report(
        id: json.decode(response.body)['name'],
        content: content,
        userId: userId,
        imageUrl: imageUrl,
        location: location,
        status: 'pending',
      );

      _reports.add(newReport);
      print("Status Code: ${response.statusCode}");
      notifyListeners();
    } catch (err) {
      print("Error adding report: $err");
      throw err;
    }
  }

  // Delete report
  Future<void> deleteReport(String idToDelete, String token) async {
    final deleteURL = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/Reports.json?auth=$token',
    );

    try {
      await http.delete(deleteURL);
      _reports.removeWhere((report) => report.id == idToDelete);
      notifyListeners();
    } catch (err) {
      print("Error deleting report: $err");
    }
  }

  // Fetch reports for current user
  Future<void> fetchMyReportsFromServer(String token, String userId) async {
    final reportsURL = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/Reports.json?auth=$token&orderBy="userId"&equalTo="$userId"',
    );

    try {
      final response = await http.get(reportsURL);
      final fetchedData = json.decode(response.body) as Map<String, dynamic>;

      _reports.clear();
      fetchedData.forEach((key, value) {
        _reports.add(
          Report(
            id: key,
            content: value['content'],
            userId: value['userId'],
            imageUrl: value['imageUrl'],
            location: value['location'],
            status: value['status'],
          ),
        );
      });

      notifyListeners();
    } catch (err) {
      print("Error fetching reports: $err");
    }
  }
  // Fetch reports by status

  Future<void> fetchReportsByStatusFromServer(
    String token,
    String status,
  ) async {
    final Uri reportsURL = Uri.https(
      'mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app',
      '/Reports.json',
      {'auth': token, 'orderBy': '"status"', 'equalTo': '"$status"'},
    );

    try {
      final response = await http.get(reportsURL);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final decoded = json.decode(response.body);

      _reports.clear();

      // ✅ Check for errors and type safety
      if (decoded is Map<String, dynamic> && !decoded.containsKey("error")) {
        decoded.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            _reports.add(
              Report(
                id: key,
                content: value['content'],
                userId: value['userId'],
                imageUrl: value['imageUrl'],
                location: value['location'],
                status: value['status'],
              ),
            );
          } else {
            print("Invalid report format for key $key: $value");
          }
        });
        notifyListeners();
      } else {
        print("Firebase error: ${decoded['error']}");
      }
    } catch (err) {
      print("Error fetching reports: $err");
    }
  }

  Future<void> updateReportStatus(
    String id,
    String newStatus,
    String token,
  ) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/Reports/$id.json?auth=$token',
    );

    try {
      final response = await http.patch(
        url,
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        final index = _reports.indexWhere((r) => r.id == id);
        if (index != -1) {
          _reports[index].status = newStatus;
          notifyListeners();
        }
      } else {
        print("Failed to update report: ${response.body}");
      }
    } catch (err) {
      print("Error updating report status: $err");
    }
  }

  // Fetch all reports
  Future<void> fetchAllReportsFromServer(String token) async {
    print("Fetching all reports...");
    final reportsURL = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/Reports.json?auth=$token',
    );

    try {
      final response = await http.get(reportsURL);
      print("pre fetching data");
      final AuthProvider authProvider = AuthProvider();
      print("role: ${authProvider.role}");
      print("token: $token");
      final fetchedData = json.decode(response.body) as Map<String, dynamic>;
      print("Fetched Data: $fetchedData");
      _reports.clear();

      fetchedData.forEach((key, value) {
        _reports.add(
          Report(
            id: key,
            content: value['content'],
            userId: value['userId'],
            imageUrl: value['imageUrl'],
            location: value['location'],
            status: value['status'],
          ),
        );
      });
      print("Fetched reports: ${_reports.length}");
      print("Fetched Data: $fetchedData");
      print("Response: ${response.body}");
      notifyListeners();
    } catch (err) {
      print(
        "Error fetching all reports: $err" +
            (_reports.isNotEmpty ? _reports[0].content : ' empty reports'),
      );
    }
  }
}
