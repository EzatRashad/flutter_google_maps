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
  Set<Polygon> polygons = {};

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
              geodesic: true,
            ),
          );

          polygons.add(
            Polygon(
              polygonId: PolygonId('area_polygon'),
              points: places.map((e) => e.latLng).toList(),
              strokeColor: Colors.red,
              strokeWidth: 3,
              fillColor: Colors.red.withOpacity(0.2),
              geodesic: true,
              holes: [
                [
                  LatLng(31.05013702065219, 31.37393775039115),
                  LatLng(31.050238127850847, 31.374372268234524),
                  LatLng(31.04995778489966, 31.374066496418816),
                ]
              ],
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
        polygons: polygons,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: true,
        cameraTargetBounds: CameraTargetBounds.unbounded,
      ),
    );
  }
}
