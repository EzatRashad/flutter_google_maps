import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps/utils/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTracking extends StatefulWidget {
  const LiveTracking({super.key});

  @override
  State<LiveTracking> createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  late LocationService locationService;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    locationService = LocationService();
    startLocationTracking();
  }

  void startLocationTracking() {
    locationService.getLocation(
      (currentLocation) {
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
      },
      onError: (e) {
        log("Location error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        markers: markers,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 18,
        ),
        onMapCreated: (controller) {
          mapController = controller;
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
