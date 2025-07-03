import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LiveTracking extends StatefulWidget {
  const LiveTracking({super.key});

  @override
  State<LiveTracking> createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  late Location location;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    location = Location();
    setLocation();
  }

  Future<void> checkLocationService() async {
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
  }

  Future<bool> checkLocationPermission() async {
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.deniedForever) {
      return true;
    }
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      } else if (permissionGranted == PermissionStatus.deniedForever) {
        return true;
      }
    }

    return true;
  }

  getLocation() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      log("Current Location: ${currentLocation.latitude}, ${currentLocation.longitude}");
      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentLocation.latitude ?? 0.0,
              currentLocation.longitude ?? 0.0),
        ),
      );
    });
  }

  Future<void> setLocation() async {
    await checkLocationService();
    bool hasPermission = await checkLocationPermission();

    if (hasPermission) {
      getLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(0, 0),
        zoom: 10,
      ),
      onMapCreated: (controller) {
        mapController = controller;
        setLocation();
      },
    );
  }
}
