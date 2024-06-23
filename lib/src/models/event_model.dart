import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String id;
  String title;
  String titleLowercase;
  String description;
  String imageUrl;
  String link;
  DateTime? registrationStartDate;
  DateTime? registrationEndDate;
  DateTime? startdate;
  DateTime? enddate;
  String location;
  List<String> tags;
  int clicks;
  double rating;
  int ratingsCount;
  String agePeriod;
  String yearRestriction;
  String modeOfEvent;
  List<String> skillsToBeAssessed;
  String courseRestriction;
  bool isTeamEvent;
  int teamSize;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.registrationStartDate,
    required this.registrationEndDate,
    required this.startdate,
    required this.enddate,
    required this.location,
    required this.tags,
    this.clicks = 0,
    this.rating = 0.0,
    this.ratingsCount = 0,
    String? titleLowercase,
    String? categoryLowercase,
    String? subcategoryLowercase,
    required this.agePeriod,
    required this.yearRestriction,
    required this.modeOfEvent,
    required this.skillsToBeAssessed,
    required this.courseRestriction,
    required this.isTeamEvent,
    required this.teamSize,
  })  : titleLowercase = titleLowercase ?? title.toLowerCase();

  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      titleLowercase: (data['title'] ?? '').toLowerCase(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      link: data['link'] ?? '',
      registrationStartDate: data['registrationStartDate'] != null
          ? (data['registrationStartDate'] as Timestamp).toDate()
          : null,
      registrationEndDate: data['registrationEndDate'] != null
          ? (data['registrationEndDate'] as Timestamp).toDate()
          : null,
      startdate: data['startdate'] != null
          ? (data['startdate'] is Timestamp
              ? (data['startdate'] as Timestamp).toDate()
              : DateTime.parse(data['startdate']))
          : null,
      enddate: data['enddate'] != null
          ? (data['enddate'] is Timestamp
              ? (data['enddate'] as Timestamp).toDate()
              : DateTime.parse(data['enddate']))
          : null,
      location: data['location'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      clicks: data['click'] ?? 0,
      rating: data['rating'] ?? 0.0,
      ratingsCount: data['ratingsCount'] ?? 0,
      agePeriod: data['agePeriod'] ?? '',
      yearRestriction: data['yearRestriction'] ?? '',
      modeOfEvent: data['modeOfEvent'] ?? '',
      skillsToBeAssessed: List<String>.from(data['skillsToBeAssessed'] ?? []),
      courseRestriction: data['courseRestriction'] ?? '',
      isTeamEvent: data['isTeamEvent'] ?? false,
      teamSize: data['teamSize'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'title_lowercase': titleLowercase,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
      'registrationStartDate': registrationStartDate != null
          ? Timestamp.fromDate(registrationStartDate!)
          : null,
      'registrationEndDate': registrationEndDate != null
          ? Timestamp.fromDate(registrationEndDate!)
          : null,
      'startdate': startdate,
      'enddate': enddate,
      'location': location,
      'tags': tags,
      'clicks': clicks,
      'ratingsCount': ratingsCount,
      'rating': rating,
      'agePeriod': agePeriod,
      'yearRestriction': yearRestriction,
      'modeOfEvent': modeOfEvent,
      'skillsToBeAssessed': skillsToBeAssessed,
      'courseRestriction': courseRestriction,
      'isTeamEvent': isTeamEvent,
      'teamSize': teamSize,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? link,
    DateTime? registrationStartDate,
    DateTime? registrationEndDate,
    DateTime? startdate,
    DateTime? enddate,
    String? location,
    List<String>? tags,
    int? clicks,
    String? titleLowercase,
    double? rating,
    int? ratingsCount,
    String? agePeriod,
    String? yearRestriction,
    String? modeOfEvent,
    List<String>? skillsToBeAssessed,
    String? courseRestriction,
    bool? isTeamEvent,
    int? teamSize,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      registrationStartDate: registrationStartDate ?? this.registrationStartDate,
      registrationEndDate: registrationEndDate ?? this.registrationEndDate,
      startdate: startdate ?? this.startdate,
      enddate: enddate ?? this.enddate,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      clicks: clicks ?? this.clicks,
      titleLowercase: titleLowercase ?? this.titleLowercase,
      rating: rating ?? this.rating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      agePeriod: agePeriod ?? this.agePeriod,
      yearRestriction: yearRestriction ?? this.yearRestriction,
      modeOfEvent: modeOfEvent ?? this.modeOfEvent,
      skillsToBeAssessed: skillsToBeAssessed ?? this.skillsToBeAssessed,
      courseRestriction: courseRestriction ?? this.courseRestriction,
      isTeamEvent: isTeamEvent ?? this.isTeamEvent,
      teamSize: teamSize ?? this.teamSize,
    );
  }

  double calculateAverageRating(double newRating) {
    ratingsCount++;
    rating = (rating * (ratingsCount - 1) + newRating) / ratingsCount;
    return rating;
  }
}
