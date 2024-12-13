// nearby_attractions_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class NearbyAttractionsScreen extends StatefulWidget {
  const NearbyAttractionsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyAttractionsScreen> createState() =>
      _NearbyAttractionsScreenState();
}

class _NearbyAttractionsScreenState extends State<NearbyAttractionsScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _defaultPosition =
      LatLng(37.7749, -122.4194); // Default location: San Francisco
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // Fetch user's current location using Geolocator
  Future<void> _fetchCurrentLocation() async {
    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
          setState(() {
            _currentPosition = _defaultPosition;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        setState(() {
          _currentPosition = _defaultPosition;
        });
        return;
      }

      // Fetch current location
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Fetched location: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Fetch nearby attractions
      _fetchNearbyAttractions(_currentPosition!);
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _currentPosition = _defaultPosition;
      });
    }
  }

  // Fetch nearby attractions using Google Places API
  Future<void> _fetchNearbyAttractions(LatLng position) async {
    const apiKey = 'AIzaSyALOy_XHqDVD3WRCJey3I8lvccFy3vs594';
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=1500&type=tourist_attraction&key=$apiKey';

    try {
      print('Fetching nearby attractions...');
      final response = await http.get(Uri.parse(url));
      print('API response: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        setState(() {
          _markers = results.map((place) {
            final LatLng markerPosition = LatLng(
              place['geometry']['location']['lat'],
              place['geometry']['location']['lng'],
            );

            return Marker(
              markerId: MarkerId(place['place_id']),
              position: markerPosition,
              infoWindow: InfoWindow(
                title: place['name'],
                snippet: place['vicinity'],
              ),
            );
          }).toSet();
        });
      } else {
        print('Failed to fetch nearby attractions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching nearby attractions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Attractions')),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
            ),
    );
  }
}
