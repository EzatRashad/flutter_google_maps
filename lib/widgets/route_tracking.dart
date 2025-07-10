import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/location_service.dart';

class RouteTracking extends StatefulWidget {
  const RouteTracking({super.key});

  @override
  State<RouteTracking> createState() => _RouteTrackingState();
}

class _RouteTrackingState extends State<RouteTracking> {
  late LocationService locationService;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    locationService = LocationService();
    setLocation();
  }

  Future<void> setLocation() async {
    try {
      final currentLocation = await locationService.getCurrentLocation();

      log("Current Location: ${currentLocation.latitude}, ${currentLocation.longitude}");

      final lat = currentLocation.latitude ?? 0.0;
      final lng = currentLocation.longitude ?? 0.0;

      final marker = Marker(
        markerId: const MarkerId("current_location"),
        position: LatLng(lat, lng),
        infoWindow: const InfoWindow(title: "Current Location"),
      );

      setState(() {
        markers = {marker};  
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(lat, lng),
        ),
      );
    } catch (e) {
      log("Error getting current location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        markers: markers,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 10,
        ),
        onMapCreated: (controller) {
          mapController = controller;
          setLocation();
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
