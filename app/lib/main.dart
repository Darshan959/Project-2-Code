// main.dart
import 'package:app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/buddy_match_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/nearby_attractions_screen.dart';
import 'screens/currency_conversion_screen.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TravelBuddyApp());
}

class TravelBuddyApp extends StatelessWidget {
  const TravelBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'Travel Buddy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/itinerary': (context) => const ItineraryScreen(),
          '/buddy_match': (context) => const BuddyMatchScreen(),
          '/nearby_attractions': (context) => const NearbyAttractionsScreen(),
          '/currency_conversion': (context) => const CurrencyConversionScreen(),
          '/profile': (context) => const ProfileScreen(
                userId: '',
              )
        },
        onGenerateRoute: (settings) {
          // Dynamically handle the ChatScreen route with required parameters
          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                buddyUid: args['buddyUid'],
                buddyName: args['buddyName'],
                chatRoomId: args['chatRoomId'], // Pass the chatRoomId
              ),
            );
          }
          return null; // Return null for unhandled routes
        },
      ),
    );
  }
}
