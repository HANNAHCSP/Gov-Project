class Vote {
  String id;
  String pollId;
  String userId;
  String option;

  Vote({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.option,
  });

  @override
  toString() => 'Vote{pollId: $pollId, userId: $userId, option: $option}';
}
