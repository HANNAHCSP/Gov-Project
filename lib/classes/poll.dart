class Poll {
  String id;
  String question;
  List<String> options;
  DateTime date;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.date,
  });
}
