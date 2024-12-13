// itinerary_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryModel {
  final String id;
  final String title;
  final String details;
  final DateTime timestamp;

  ItineraryModel({
    required this.id,
    required this.title,
    required this.details,
    required this.timestamp,
  });

  factory ItineraryModel.fromMap(String id, Map<String, dynamic> map) {
    return ItineraryModel(
      id: id,
      title: map['title'] as String,
      details: map['details'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'details': details,
      'timestamp': timestamp,
    };
  }
}
