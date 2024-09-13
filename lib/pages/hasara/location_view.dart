import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationView extends StatefulWidget {
  const LocationView({super.key});

  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  Location _locationController = Location();
  // Initial camera position for GooglePlex
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  // Another location for Apple Park
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LatLng? _currentP;
  static const String _locationText = "Find Your Restaurant"; // Static text for AppBar

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text( // Make it a constant Text widget to prevent updates
          _locationText,
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color(0xFFF86A2E),
        iconTheme: const IconThemeData(color: Colors.white), // Optional: Set icon color to white
      ),
      body: Container(
        // Apply gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(126, 248, 100, 37), // Orange bar
              Colors.white, // White
            ],
          ),
        ),
        child: Center(
          child: _currentP == null
              ? const Center(child: Text("Loading..."))
              : Container(
                  height: 550, // Set the height for the map container
                  width: 500, // Set the width for the map container
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Optional rounded corners
                  ),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _pGooglePlex,
                      zoom: 13,
                    ),//add comment
                    markers: {
                      Marker(
                        markerId: const MarkerId("_currentLocation"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _currentP!,
                      ),
                      const Marker(
                        markerId: MarkerId("_sourceLocation"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _pGooglePlex,
                      ),
                      const Marker(
                        markerId: MarkerId("_destinationLocation"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _pApplePark,
                      ),
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if service is enabled
    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check for permission
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Listen to location changes
    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          // Update the current location without changing the AppBar text
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print(_currentP); // Log the current coordinates
        });
      }
    });
  }
}