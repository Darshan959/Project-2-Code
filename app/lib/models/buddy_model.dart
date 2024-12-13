// buddy_model.dart
class Buddy {
  final String id;
  final String name;
  final List<String> interests;

  Buddy({
    required this.id,
    required this.name,
    required this.interests,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'interests': interests,
    };
  }

  static Buddy fromMap(String id, Map<String, dynamic> map) {
    return Buddy(
      id: id,
      name: map['name'],
      interests: List<String>.from(map['interests']),
    );
  }
}
