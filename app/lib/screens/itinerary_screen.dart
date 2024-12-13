// itinerary_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _activityDescriptionController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void saveItinerary() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinerary name cannot be empty')),
      );
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      print('No user is logged in. Cannot save itinerary.');
      return;
    }

    try {
      await _firestore.collection('itineraries').add({
        'title': _titleController.text.trim(),
        'activities': [],
        'timestamp': FieldValue.serverTimestamp(),
        'uid': user.uid, // Associate the itinerary with the current user
      });
      _titleController.clear();
      Navigator.pop(context);
      print('Itinerary saved for UID: ${user.uid}');
    } catch (e) {
      print('Error saving itinerary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save itinerary')),
      );
    }
  }

  Future<void> deleteItinerary(String itineraryId) async {
    try {
      await _firestore.collection('itineraries').doc(itineraryId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinerary deleted!')),
      );
    } catch (e) {
      print('Error deleting itinerary: $e');
    }
  }

  Future<void> addActivity(String itineraryId) async {
    if (_activityNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity name cannot be empty')),
      );
      return;
    }

    try {
      final itineraryDoc =
          _firestore.collection('itineraries').doc(itineraryId);
      final snapshot = await itineraryDoc.get();
      if (snapshot.exists) {
        final activities =
            List<Map<String, String>>.from(snapshot.data()!['activities']);
        activities.add({
          'name': _activityNameController.text.trim(),
          'description': _activityDescriptionController.text.trim(),
        });

        await itineraryDoc.update({'activities': activities});

        _activityNameController.clear();
        _activityDescriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity added!')),
        );
      }
    } catch (e) {
      print('Error adding activity: $e');
    }
  }

  Future<void> deleteActivity(String itineraryId, int activityIndex) async {
    try {
      final itineraryDoc =
          _firestore.collection('itineraries').doc(itineraryId);
      final snapshot = await itineraryDoc.get();

      if (snapshot.exists) {
        final activities =
            List<Map<String, dynamic>>.from(snapshot.data()!['activities']);

        if (activityIndex >= 0 && activityIndex < activities.length) {
          activities.removeAt(activityIndex);
          await itineraryDoc.update({'activities': activities});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity deleted!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid activity index')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Itinerary not found')),
        );
      }
    } catch (e) {
      print('Error deleting activity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete activity')),
      );
    }
  }

  void openAddItineraryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Itinerary'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Itinerary Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: saveItinerary,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void openAddActivityDialog(String itineraryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _activityNameController,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _activityDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Activity Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              addActivity(itineraryId);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Itineraries')),
        body:
            const Center(child: Text('Please log in to see your itineraries.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Itineraries')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('itineraries')
            .where('uid', isEqualTo: user.uid)
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading itineraries.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No itineraries found.'));
          }

          final itineraries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: itineraries.length,
            itemBuilder: (context, index) {
              final itinerary = itineraries[index];
              final List activities = itinerary['activities'] ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(itinerary['title']),
                  subtitle: Text(
                    'Created on: ${itinerary['timestamp'].toDate()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteItinerary(itinerary.id),
                  ),
                  children: [
                    ...activities.asMap().entries.map((entry) {
                      final activityIndex = entry.key;
                      final activity = entry.value;
                      return ListTile(
                        title: Text(activity['name']),
                        subtitle:
                            Text(activity['description'] ?? 'No description'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              deleteActivity(itinerary.id, activityIndex),
                        ),
                      );
                    }),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add Activity'),
                      onTap: () => openAddActivityDialog(itinerary.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddItineraryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
