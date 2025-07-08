import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<bool> checkLocationService() async {
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }
    return true;
  }

  Future<bool> checkLocationPermission() async {
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      return permissionGranted == PermissionStatus.granted;
    }

    return true;
  }
  void getLocation(void Function(LocationData)? onData) {
    location.onLocationChanged.listen(onData);
  }

 
}
