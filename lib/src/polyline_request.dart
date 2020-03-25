import 'package:google_map_polyline/src/route_mode.dart';
import 'package:google_map_polyline/src/route_avoid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineRequestData {
  LatLng originLoc;
  LatLng destinationLoc;
  String originText;
  String destinationText;
  RouteMode mode;
  RouteAvoid avoid;
  bool locationText;
  String apiKey;

  PolylineRequestData({
    this.originLoc,
    this.destinationLoc,
    this.originText,
    this.destinationText,
    this.mode,
    this.avoid,
    this.locationText,
    this.apiKey,
  });
}
