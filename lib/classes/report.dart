class Report {
  String id;
  String content;
  String userId;
  String imageUrl;
  String location;
  String status;

  Report({
    required this.id,
    required this.content,
    required this.userId,
    required this.imageUrl,
    required this.location,
    required this.status,
  });

  factory Report.fromJson(String id, Map<String, dynamic> json) {
    return Report(
      id: id,
      content: json['content'],
      userId: json['userId'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      
      'content': content,
      'userId': userId,
      'imageUrl': imageUrl,
      'location': location,
      'status': status,
    };
  }
}
