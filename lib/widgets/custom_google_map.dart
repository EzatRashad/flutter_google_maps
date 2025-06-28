import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/models/place_model.dart';
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
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    initMapStyle();
    _setupLocation();
  }

  Future<void> initMapStyle() async {}

  Future<void> _setupLocation() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition();

        if (isMapCreated) {
          _mapController.animateCamera(
            CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude)),
          );
          String darkMapStyle = await DefaultAssetBundle.of(context)
              .loadString('assets/dark_map_style/dark_map_style.json');
          String nightMapStyle = await DefaultAssetBundle.of(context)
              .loadString('assets/night_map_style/night_map_style.json');
          _mapController.setMapStyle(darkMapStyle);
          final pin = await BitmapDescriptor.asset(
            const ImageConfiguration(size: Size(30, 30)),
            'assets/images/pin.png',
          );

          places
              .map((e) => {
                    markers.add(
                      Marker(
                        icon: pin,
                        markerId: MarkerId(e.id.toString()),
                        position: e.latLng,
                        infoWindow: InfoWindow(title: e.name),
                      ),
                    )
                  })
              .toList();

          // Create a polyline for the area
          polylines.add(
            Polyline(
              polylineId: PolylineId('area'),
              points: places.map((e) => e.latLng).toList(),
              color: Colors.blue,
              width: 5,
              patterns: [PatternItem.dash(20), PatternItem.gap(10)],
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,

              geodesic: true
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
        markers: markers,
        polylines: polylines,
        // myLocationEnabled: true,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: true,
        cameraTargetBounds: CameraTargetBounds.unbounded,
      ),
    );
  }
}
