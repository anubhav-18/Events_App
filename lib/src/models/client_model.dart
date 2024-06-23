import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String id;
  final String email;
  final String name;
  final String designation;
  final String phoneNo;
  final String role;

  ClientModel({
    required this.id,
    required this.email,
    required this.name,
    required this.designation,
    required this.phoneNo,
    required this.role,
  });

  factory ClientModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    Map<String, dynamic> data = doc.data()!;
    return ClientModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      designation: data['designation'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      role: data['role'] ?? 'client',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'designation': designation,
      'phoneNo': phoneNo,
      'role': role,
    };
  }
}
