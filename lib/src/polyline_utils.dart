import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_map_polyline/src/route_mode.dart';
import 'package:google_map_polyline/src/route_avoid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_polyline/src/polyline_request.dart';

class PolylineUtils {
  PolylineRequestData _data;
  PolylineUtils(this._data);

  Future<List<LatLng>> getCoordinates() async {
    List<LatLng> _coordinates;

    var qParam = {
      'mode': getMode(_data.mode),
      'avoid': getAvoid(_data.avoid),
      'key': _data.apiKey,
    };

    if (_data.locationText) {
      qParam['origin'] = _data.originText;
      qParam['destination'] = _data.destinationText;
    } else {
      qParam['origin'] =
          "${_data.originLoc.latitude},${_data.originLoc.longitude}";
      qParam['destination'] =
          "${_data.destinationLoc.latitude},${_data.destinationLoc.longitude}";
    }
    
    print("DEBUG: qParam=${jsonEncode(qParam)}");

    Response _response;
    Dio _dio = new Dio();
    _response = await _dio.get(
        "https://maps.googleapis.com/maps/api/directions/json",
        queryParameters: qParam);

    try {
      if (_response.statusCode == 200) {
        if (_response.data["status"] == "REQUEST_DENIED") {
          throw Exception(_response.data["error_message"]);
        }
        
        _coordinates = decodeEncodedPolyline(
            _response.data['routes'][0]['overview_polyline']['points']);
        
        print("DEBUG: data=${jsonEncode(_response.data)}");
      }
    } catch (e) {
      print('error!!!! $e');
      throw e;
    }

    return _coordinates;
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = new LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  String getMode(RouteMode _mode) {
    switch (_mode) {
      case RouteMode.driving:
        return 'driving';
      case RouteMode.walking:
        return 'walking';
      case RouteMode.bicycling:
        return 'bicycling';
      default:
        return null;
    }
  }
  
  String getAvoid(List<RouteAvoid> _avoid) {
    String avoidStr = '';
    
    int i = 1;
    _avoid.forEach((item) {
      if (item == RouteAvoid.tolls) {
        avoidStr = avoidStr + 'tolls';
      } else if (item == RouteAvoid.highways) {
        avoidStr = avoidStr + 'highways';
      } else if (item == RouteAvoid.ferries) {
        avoidStr = avoidStr + 'ferries';
      }
      
      if (i < _avoid.length) {
        avoidStr = avoidStr + '|';
      }
      
      i+=1;
    });
    
    print("DEBUG: avoidStr=$avoidStr");
    
    if (avoidStr == '')
      return null;
    
    return avoidStr;
  }
}
