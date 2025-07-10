import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<void> checkLocationService() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw LocationServiceException('Location services are disabled');
        }
      }
    } catch (e) {
      throw LocationServiceException('Failed to check location services: $e');
    }
  }

  Future<void> checkLocationPermission() async {
    try {
      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.deniedForever) {
        throw LocationServicePermissionException(
            'Location permission denied forever');
      }
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          throw LocationServicePermissionException(
              'Location permission denied');
        }
      }
    } catch (e) {
      throw LocationServicePermissionException(
          'Failed to check/request location permission: $e');
    }
  }

  void getLocation(void Function(LocationData)? onData,
      {Function(Exception)? onError}) async {
    try {
      await checkLocationService();
      await checkLocationPermission();

      location.onLocationChanged.listen(
        onData,
        onError: (e) {
          if (onError != null) {
            onError(LocationServiceException(
                'Error receiving location updates: $e'));
          }
        },
      );
    } catch (e) {
      if (onError != null) {
        onError(
            LocationServiceException('Failed to start location updates: $e'));
      }
    }
  }

  Future<LocationData> getCurrentLocation() async {
    try {
      await checkLocationService();
      await checkLocationPermission();

      return await location.getLocation();
    } catch (e) {
      throw LocationServiceException('Failed to get current location: $e');
    }
  }
}

class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() {
    return 'LocationServiceException: $message';
  }
}

class LocationServicePermissionException implements Exception {
  final String message;

  LocationServicePermissionException(this.message);

  @override
  String toString() {
    return 'LocationServicePermissionException: $message';
  }
}
