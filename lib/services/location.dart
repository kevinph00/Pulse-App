import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<LocationData?> initAndGetLocation() async {
    if (!(await _location.serviceEnabled())) {
      await _location.requestService();
    }
    var perm = await _location.hasPermission();
    if (perm == PermissionStatus.denied) {
      await _location.requestPermission();
    }
    return await _location.getLocation();
  }

  Future<LocationData?> getLocation() async {
    return await _location.getLocation();
  }
}
