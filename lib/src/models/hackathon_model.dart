class Hackathon {
  final String id; // Add a unique ID for each hackathon
  final String name;
  final String organizer;
  final String? prize;
  final String status;
  final int daysLeft;
  final int registered;
  final List<String> categories;
  final String imageUrl; // Add an image URL for the hackathon

  Hackathon({
    required this.id,
    required this.name,
    required this.organizer,
    this.prize,
    required this.status, 
    required this.daysLeft,
    required this.registered,
    required this.categories,
    required this.imageUrl,
  });
}
