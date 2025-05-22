class Announcement {
  String id;
  String title;
  String description;
  String? imageUrl;
  DateTime date;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
  });
}
