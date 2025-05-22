import 'package:flutter/material.dart';
import 'classes/poll.dart';
import 'classes/vote.dart';

class PollCard extends StatelessWidget {
  final Poll poll;
  final Function onTap;
  final Function onDelete;
  final List<Vote> votes;
  final String userId;
  final String role;

  const PollCard({
    Key? key,
    required this.poll,
    required this.onTap,
    required this.onDelete,
    required this.votes,
    required this.userId,
    this.role = 'citizen',
  }) : super(key: key);

  Future<void> _confirmDelete(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Poll'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this poll?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                onDelete(poll.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool voted = false;
    final myVotes = votes.where((element) => element.userId == userId);
    final myVotesForThisPoll = myVotes.where(
      (element) => element.pollId == poll.id,
    );

    if (myVotesForThisPoll.isNotEmpty) {
      voted = true;
    }

    int findNumberOfVotesForOption(String option) {
      return votes.where((vote) => vote.option == option).length;
    }

    final votesForEachOption = <String, int>{};
    for (var option in poll.options) {
      votesForEachOption[option] = findNumberOfVotesForOption(option);
    }

    final totalVotes = votesForEachOption.values.fold(
      0,
      (sum, count) => sum + count,
    );

    Widget cardContent = Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin badge
            if (role == 'admin')
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Poll Question
            Text(
              poll.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            // Poll Options
            ...poll.options.map((option) {
              final votesForOption = votesForEachOption[option] ?? 0;
              final percentage =
                  totalVotes > 0
                      ? (votesForOption / totalVotes * 100).round()
                      : 0;
              final isSelected = myVotesForThisPoll.any(
                (vote) => vote.option == option,
              );

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (role == 'admin') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Admins cannot vote in polls'),
                          ),
                        );
                        return;
                      }

                      if (voted) {
                        onTap(option, poll, myVotesForThisPoll.first);
                      } else {
                        onTap(
                          option,
                          poll,
                          Vote(id: '', userId: '', option: '', pollId: ''),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.indigo[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.indigo : Colors.grey,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors.indigo[800]
                                            : Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value:
                                      totalVotes > 0
                                          ? votesForOption / totalVotes
                                          : 0,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isSelected ? Colors.indigo : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.indigo : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$votesForOption votes',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),

            const Divider(height: 24),

            // Comment Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed:
                    () => Navigator.of(
                      context,
                    ).pushNamed('/PollRoute', arguments: poll),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.comment, size: 18),
                label: const Text('View Comments'),
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap with Dismissible if admin
    if (role == 'admin') {
      return Dismissible(
        key: Key(poll.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 30),
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        confirmDismiss: (direction) async {
          await _confirmDelete(context);
          return false; // We handle the deletion in the dialog
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}
