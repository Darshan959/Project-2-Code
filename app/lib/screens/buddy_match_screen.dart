// buddy_match_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class BuddyMatchScreen extends StatefulWidget {
  const BuddyMatchScreen({super.key});

  @override
  State<BuddyMatchScreen> createState() => _BuddyMatchScreenState();
}

class _BuddyMatchScreenState extends State<BuddyMatchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _currentUser;
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    fetchUserAndMatches();
  }

  Future<void> fetchUserAndMatches() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      print('No user is logged in.');
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        print('Current user not found in Firestore.');
        return;
      }

      final currentUserData = userDoc.data()!;
      print('Current user data: $currentUserData');
      setState(() {
        _currentUser = currentUserData;
      });

      final allUsersQuery = await _firestore.collection('users').get();
      final allUsers = allUsersQuery.docs.map((doc) => doc.data()).toList();

      findMatches(allUsers, currentUserData);
    } catch (e) {
      print('Error fetching user or matches: $e');
    }
  }

  void findMatches(List<Map<String, dynamic>> allUsers,
      Map<String, dynamic> currentUserData) {
    final List<Map<String, dynamic>> matches = [];
    final List<String> currentUserInterests =
        List<String>.from(currentUserData['interests'] ?? []);

    for (var user in allUsers) {
      if (user['uid'] == currentUserData['uid']) {
        continue; // Exclude the current user
      }

      final List<String> userInterests =
          List<String>.from(user['interests'] ?? []);
      final sharedInterests = userInterests
          .where((interest) => currentUserInterests.contains(interest))
          .toList();

      if (sharedInterests.isNotEmpty) {
        matches.add({
          'user': user,
          'sharedInterests': sharedInterests,
        });
      }
    }

    print('Found matches: $matches');
    setState(() {
      _matches = matches;
    });
  }

  void navigateToChatScreen(Map<String, dynamic> buddy) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) return;

    try {
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final currentUserData = currentUserDoc.data();

      if (currentUserData != null) {
        final currentUserUid = currentUserData['uid'];
        final buddyUid = buddy['uid'];

        final chatRoomId = _generateChatRoomId(currentUserUid, buddyUid);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              buddyUid: buddyUid,
              buddyName: buddy['name'],
              chatRoomId: chatRoomId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error navigating to chat screen: $e');
    }
  }

  String _generateChatRoomId(String user1, String user2) {
    return user1.compareTo(user2) < 0 ? '${user1}_$user2' : '${user2}_$user1';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buddy Match')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _matches.isEmpty
            ? const Center(
                child: Text(
                  'No matches found',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: _matches.length,
                itemBuilder: (context, index) {
                  final match = _matches[index];
                  final user = match['user'];
                  final sharedInterests = match['sharedInterests'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          user['name']?[0] ?? '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user['name'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      subtitle: Text(
                        'Shared Interests: ${sharedInterests.join(', ')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => navigateToChatScreen(user),
                        child: const Text('Chat'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
