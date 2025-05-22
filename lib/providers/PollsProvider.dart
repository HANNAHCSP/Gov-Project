import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../classes/poll.dart';
import '../classes/vote.dart';
import '../classes/pollcomment.dart';

class PollsProvider with ChangeNotifier {
  final List<Poll> _polls = [];

  final List<Vote> _votes = [];

  final List<PollComment> _pollComments = [];

  List<Poll> get polls {
    return _polls;
  }

  List<Vote> get votes {
    return _votes;
  }

  List<PollComment> get pollComments {
    return _pollComments;
  }

  Future<void> getPollsFromServer(String token, String userId) async {
    _polls.clear();
    _votes.clear();
    _pollComments.clear();
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/polls.json/?auth=$token',
    );
    var allPolls = await http.get(url);
    var polls = json.decode(allPolls.body);
    print("Pools is $polls");
    if (polls != null) {
      polls.forEach((key, value) {
        print("Value is $value");
        List<String> optionsArray = [];
        value['options'].forEach((element) {
          element = element.trim();
          optionsArray.add(element);
        });
        if (value['comments'] != null) {
          value['comments'].forEach((keyTwo, element) {
            _pollComments.add(
              PollComment(
                id: keyTwo,
                userId: element['userId'],
                userName: element['userName'],
                pollId: key,
                text: element['text'],
                date: DateTime.parse(element['date']),
              ),
            );
          });
        }
        if (value['votes'] != null) {
          value['votes'].forEach((keyTwo, element) {
            _votes.add(
              Vote(
                id: keyTwo,
                pollId: key,
                userId: element['userId'],
                option: element['option'],
              ),
            );
          });
        }
        _polls.add(
          Poll(
            id: key,
            question: value['question'],
            options: optionsArray,
            date: DateTime.parse(value['date']),
          ),
        );
      });
    }

    notifyListeners();
  }

  Future<void> postPollComment(
    String token,
    String userId,
    String userName,
    String pollId,
    String text,
  ) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/polls/$pollId/comments.json?auth=$token',
    );

    final dateTimeNow = DateTime.now();

    return http
        .post(
          url,
          body: json.encode({
            'userId': userId,
            'pollId': pollId,
            'userName': userName,
            'text': text,
            'date': dateTimeNow.toString(),
          }),
        )
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          _pollComments.add(
            PollComment(
              id: content['name'],
              userId: userId,
              userName: userName,
              pollId: pollId,
              text: text,
              date: dateTimeNow,
            ),
          );
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> voteInPoll(
    String token,
    String userId,
    String pollId,
    String option,
  ) async {
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/polls/$pollId/votes.json?auth=$token',
    );

    return http
        .post(url, body: json.encode({'userId': userId, 'option': option}))
        .then((response) {
          var content = json.decode(response.body);
          print("Content is $content");
          _votes.add(
            Vote(
              id: content['name'],
              pollId: pollId,
              userId: userId,
              option: option,
            ),
          );
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> deleteVote(
    String token,
    String userId,
    String pollId,
    String voteId,
  ) async {
    print("ENTERED DELETE VOTE");
    var url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/polls/$pollId/votes/$voteId.json?auth=$token',
    );

    return http
        .delete(url)
        .then((response) {
          var content = json.decode(response.body);
          print("Vote count before is ${_votes.length}");
          _votes.removeWhere((element) => element.id == voteId);
          print("Vote count after is ${_votes.length}");
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> addPoll(
    String token,
    String userId,
    String role,
    String question,
    List<String> options,
  ) async {
    if (role != "admin") return;
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/polls.json/?auth=$token',
    );

    return http
        .post(
          url,
          body: json.encode({
            'question': question,
            'options': options,
            'date': DateTime.now().toString(),
          }),
        )
        .then((response) {
          var content = json.decode(response.body);
          print("Poll response is $content");
          _polls.add(
            Poll(
              id: content.id,
              question: question,
              options: options,
              date: DateTime.parse(content['date']),
            ),
          );

          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }

  Future<void> deletePoll(
    String token,
    String role,
    String userId,
    String pollId,
  ) async {
    if (role != "admin") return;
    final url = Uri.parse(
      'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app/polls/$pollId.json?auth=$token',
    );

    return http
        .delete(url)
        .then((response) {
          var content = json.decode(response.body);
          _polls.removeWhere((element) => element.id == pollId);
          notifyListeners();
        })
        .catchError((err) {
          print("The error is: " + err.toString());
        });
  }
}
