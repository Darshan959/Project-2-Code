// firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Registration
  Future<User?> register(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': '',
        'interests': [],
        'travelDates': [],
      });
      return userCredential.user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // User Login
  Future<User?> login(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // User Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Save Itinerary
  Future<void> saveItinerary(
      String title, List<Map<String, String>> activities, String userId) async {
    try {
      await _firestore.collection('itineraries').add({
        'title': title,
        'activities': activities,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving itinerary: $e');
    }
  }

  // Fetch Itineraries for a User
  Future<List<Map<String, dynamic>>> fetchItineraries(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('itineraries')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp')
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'],
          'activities': List<Map<String, String>>.from(data['activities']),
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching itineraries: $e');
      return [];
    }
  }

  // Fetch All Users
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Fetch a Single User by ID
  Future<Map<String, dynamic>?> fetchUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Update User Profile (e.g., Name and Interests)
  Future<void> updateUserProfile(
      String userId, String name, List<String> interests) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'interests': interests,
      });
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  // Add Buddy Match
  Future<void> addBuddyMatch(String user1, String user2) async {
    try {
      await _firestore.collection('buddy_matches').add({
        'user1': user1,
        'user2': user2,
        'matchedOn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding buddy match: $e');
    }
  }

  // Fetch Buddy Matches for a User
  Future<List<Map<String, dynamic>>> fetchBuddyMatches(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('buddy_matches')
          .where('user1', isEqualTo: userId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching buddy matches: $e');
      return [];
    }
  }

  // Find Matching Buddies Based on Interests
  Future<List<Map<String, dynamic>>> findMatchingBuddies(String userId) async {
    try {
      final currentUser = await fetchUser(userId);
      if (currentUser == null) return [];

      final List<String> currentUserInterests =
          List<String>.from(currentUser['interests'] ?? []);
      if (currentUserInterests.isEmpty) return [];

      final users = await fetchAllUsers();
      final matches = users.where((user) {
        if (user['uid'] == userId) return false; // Skip self
        final List<String> userInterests =
            List<String>.from(user['interests'] ?? []);
        final sharedInterests = userInterests
            .where((interest) => currentUserInterests.contains(interest))
            .toList();
        return sharedInterests.isNotEmpty;
      }).toList();

      return matches.map((user) {
        final List<String> userInterests =
            List<String>.from(user['interests'] ?? []);
        final sharedInterests = userInterests
            .where((interest) => currentUserInterests.contains(interest))
            .toList();
        return {
          'user': user,
          'sharedInterests': sharedInterests,
        };
      }).toList();
    } catch (e) {
      print('Error finding matching buddies: $e');
      return [];
    }
  }
}
