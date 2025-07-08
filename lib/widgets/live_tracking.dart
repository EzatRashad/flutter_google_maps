import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps/utils/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
    setLocation();
  }

  Future<void> setLocation() async {
    await locationService.checkLocationService();
    bool hasPermission = await locationService.checkLocationPermission();

    if (hasPermission) {
      locationService.getLocation((currentLocation) {
        log("Current Location: ${currentLocation.latitude}, ${currentLocation.longitude}");
        var marker = Marker(
          markerId: const MarkerId("current_location"),
          position: LatLng(currentLocation.latitude ?? 0.0,
              currentLocation.longitude ?? 0.0),
          infoWindow: InfoWindow(title: "Current Location"),
        );
        markers.add(marker);
        setState(() {});
        mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(currentLocation.latitude ?? 0.0,
                currentLocation.longitude ?? 0.0),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: markers,
      initialCameraPosition: CameraPosition(
        target: LatLng(0, 0),
        zoom: 18,
      ),
      onMapCreated: (controller) {
        mapController = controller;
        setLocation();
      },
    );
  }
}
