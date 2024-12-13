// home_screen.dart
import 'package:flutter/material.dart';
import 'package:app/screens/profile_screen.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Buddy Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await firebaseService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              icon: Icons.calendar_today,
              title: 'Itineraries',
              subtitle: 'Plan your trips',
              routeName: '/itinerary',
            ),
            _buildFeatureCard(
              context,
              icon: Icons.people,
              title: 'Buddy Match',
              subtitle: 'Find travel buddies',
              routeName: '/buddy_match',
            ),
            _buildFeatureCard(
              context,
              icon: Icons.place,
              title: 'Nearby Attractions',
              subtitle: 'Explore places',
              routeName: '/nearby_attractions',
            ),
            _buildFeatureCard(
              context,
              icon: Icons.attach_money,
              title: 'Currency Converter',
              subtitle: 'Manage your budget',
              routeName: '/currency_conversion',
            ),
            _buildFeatureCard(
              context,
              icon: Icons.person,
              title: 'Profile',
              subtitle: 'Manage your profile',
              routeName: '/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
