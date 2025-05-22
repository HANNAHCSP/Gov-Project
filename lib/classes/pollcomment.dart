class PollComment {
  String id;
  String userId;
  String userName;
  String pollId;
  String text;
  DateTime date;

  PollComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.pollId,
    required this.text,
    required this.date,
  });
}
