import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;

  final LatLng latLng;

  PlaceModel({
    required this.id,
    required this.name,
    required this.latLng,
  });
}

List<PlaceModel> places = [
  PlaceModel(
    id: 1,
    name: 'المعدية',
    latLng: LatLng(31.049869732112764, 31.373341014586636),
  ),
  PlaceModel(
    id: 2,
    name: 'مستشفى طلخا المركزي',
    latLng: LatLng(31.050173054238382, 31.37215011383072),
  ),
  PlaceModel(
    id: 3,
    name: 'مسجد البازات',
    latLng: LatLng(31.05051264246873, 31.375148676868946),
  ),
];
