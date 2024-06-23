import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  String? phoneNo;
  String? gender;
  DateTime? dateOfBirth;
  final List<String> interests;
  String role;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNo,
    this.gender,
    this.dateOfBirth,
    required this.interests,
    this.role = 'user',
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNo: data['phoneNo'],
      gender: data['gender'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      interests: List<String>.from(data['interests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNo': phoneNo,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'interests' : interests,
    };
  }
}
