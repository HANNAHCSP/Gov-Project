import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/reportprovider.dart';
import '/providers/Authprovider.dart';

class AdminReportPage extends StatefulWidget {
  @override
  _AdminReportPageState createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  bool _isLoading = true;

  bool _isBase64(String str) {
    return !str.startsWith('http');
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    await reportProvider.fetchReportsByStatusFromServer('token', "pending");
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final reports = reportProvider.getAllReports;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - All Reports'),
        backgroundColor: Colors.red,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (ctx, index) {
                    final report = reports[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  _isBase64(report.imageUrl)
                                      ? Image.memory(
                                        base64Decode(report.imageUrl),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.network(
                                        report.imageUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.content,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Location: ${report.location}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color.fromARGB(
                                        255,
                                        75,
                                        58,
                                        58,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Status: ${report.status}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          report.status == 'pending'
                                              ? Colors.orange
                                              : Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  report.status == "pending"
                                      ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            147,
                                            99,
                                            229,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await reportProvider
                                              .updateReportStatus(
                                                report.id,
                                                "reviewed",
                                                'token',
                                              );
                                          await _loadReports(); // refresh
                                        },
                                        child: Text(
                                          'Mark Reviewed',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                      : Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          "Reviewed",
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
