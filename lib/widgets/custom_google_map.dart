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
  final CameraPosition _fallbackCameraPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 10,
  );

  late GoogleMapController _mapController;
  bool _isMapCreated = false;
  bool _isLocationLoaded = false;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Polygon> _polygons = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  Future<void> _setupMap() async {
    await _requestLocationPermission();
    await _loadMapAssets();
    if (_isMapCreated) {
      await _moveCameraToCurrentLocation();
      _addMarkers();
      _addPolylines();
      _addPolygons();
      _addCircles();
    }
    setState(() {
      _isLocationLoaded = true;
    });
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
  }

  Future<void> _loadMapAssets() async {
    // Load and apply map styles or assets if needed
    final darkMapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/dark_map_style/dark_map_style.json');
    _mapController.setMapStyle(darkMapStyle);
  }

  Future<void> _moveCameraToCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    await _mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  Future<void> _addMarkers() async {
    final pin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/images/pin.png',
    );

    for (final place in places) {
      _markers.add(
        Marker(
          markerId: MarkerId(place.id.toString()),
          position: place.latLng,
          icon: pin,
          infoWindow: InfoWindow(title: place.name),
        ),
      );
    }
  }

  void _addPolylines() {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('area'),
        points: places.map((e) => e.latLng).toList(),
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        geodesic: true,
      ),
    );
  }

  void _addPolygons() {
    _polygons.add(
      Polygon(
        polygonId: const PolygonId('area_polygon'),
        points: places.map((e) => e.latLng).toList(),
        strokeColor: Colors.red,
        strokeWidth: 3,
        fillColor: Colors.red.withOpacity(0.2),
        geodesic: true,
        holes: [
          [
            const LatLng(31.05013702065219, 31.37393775039115),
            const LatLng(31.050238127850847, 31.374372268234524),
            const LatLng(31.04995778489966, 31.374066496418816),
          ]
        ],
      ),
    );
  }

  Future<void> _addCircles() async {
    final position = await Geolocator.getCurrentPosition();
    _circles.add(
      Circle(
        circleId: const CircleId('my_circle'),
        center: LatLng(position.latitude, position.longitude),
        radius: 100, // in meters
        strokeColor: Colors.green,
        strokeWidth: 2,
        fillColor: Colors.green.withOpacity(0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _fallbackCameraPosition,
        onMapCreated: (controller) {
          _mapController = controller;
          _isMapCreated = true;
          _setupMap(); // Ensure setup runs after map is created
        },
        markers: _markers,
        polylines: _polylines,
        polygons: _polygons,
        circles: _circles,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: true,
        cameraTargetBounds: CameraTargetBounds.unbounded,
      ),
    );
  }
}
