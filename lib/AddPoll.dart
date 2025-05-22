import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/PollsProvider.dart';
import 'providers/Authprovider.dart';

class AddPoll extends StatefulWidget {
  @override
  _AddPollState createState() => _AddPollState();
}

class _AddPollState extends State<AddPoll> {
  final questionController = TextEditingController();
  final optionController = TextEditingController();
  final List<String> options = [];

  @override
  Widget build(BuildContext context) {
    final pollsProvider = Provider.of<PollsProvider>(context);

    void addPoll() {
      if (questionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please provide a question")));
        return;
      }
      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please provide at least 2 options")),
        );
        return;
      }

      pollsProvider.addPoll(
        Provider.of<AuthProvider>(context, listen: false).token,
        Provider.of<AuthProvider>(context, listen: false).userId,
        Provider.of<AuthProvider>(context, listen: false).role,
        questionController.text.trim(),
        options,
      );
      Navigator.of(context).pushNamed('/Home');
    }

    void addOption() {
      if (optionController.text.trim().isNotEmpty) {
        setState(() {
          options.add(optionController.text.trim());
          optionController.clear();
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Poll"),
        backgroundColor: Colors.red[700],
        actions: [IconButton(icon: Icon(Icons.check), onPressed: addPoll)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(
                        labelText: "Poll Question",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: optionController,
                            decoration: InputDecoration(
                              labelText: "Add Option",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.red),
                          onPressed: addOption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (options.isNotEmpty) ...[
              Text(
                "Poll Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Column(
                  children:
                      options
                          .map(
                            (option) => ListTile(
                              title: Text(option),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    options.remove(option);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
