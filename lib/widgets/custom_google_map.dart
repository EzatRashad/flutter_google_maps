import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  CameraPosition fallbackCameraPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 10,
  );

  late GoogleMapController _mapController;
  bool isMapCreated = false;
  bool isLocationLoaded = false;

  @override
  void initState() {
    super.initState();
    _setupLocation();
  }

  Future<void> _setupLocation() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition();

        if (isMapCreated) {
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14.0,
              ),
            ),
          );
        }

        setState(() {
          isLocationLoaded = true;
        });
      } catch (e) {
        setState(() {
          isLocationLoaded = true;
        });
      }
    } else {
      setState(() {
        isLocationLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: fallbackCameraPosition,
        onMapCreated: (controller) {
          _mapController = controller;
          isMapCreated = true;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
