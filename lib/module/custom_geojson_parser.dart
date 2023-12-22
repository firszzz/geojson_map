import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

typedef MarkerCreationCallback = Marker Function(
    LatLng point, Map<String, dynamic> properties);
typedef CircleMarkerCreationCallback = CircleMarker Function(
    LatLng point, Map<String, dynamic> properties);
typedef PolylineCreationCallback = Polyline Function(
    List<LatLng> points, Map<String, dynamic> properties);
typedef PolygonCreationCallback = Polygon Function(List<LatLng> points,
    List<List<LatLng>>? holePointsList, Map<String, dynamic> properties, Color? color);
typedef FilterFunction = bool Function(Map<String, dynamic> properties);

class PolygonWithProperties {
  final Polygon polygon;
  Map<String, dynamic> properties;

  PolygonWithProperties(this.polygon, this.properties);
}

class CustomGeoJsonParser {
  final List<Marker> markers = [];

  final List<Polyline> polylines = [];

  final List<Polygon> polygons = [];

  final List<CircleMarker> circles = [];

  ///

  final List<PolygonWithProperties> polygonsWithProperties = [];

  ///

  MarkerCreationCallback? markerCreationCallback;

  PolylineCreationCallback? polyLineCreationCallback;

  PolygonCreationCallback? polygonCreationCallback;

  CircleMarkerCreationCallback? circleMarkerCreationCallback;

  Color? defaultMarkerColor;

  IconData? defaultMarkerIcon;

  Color? defaultPolylineColor;

  double? defaultPolylineStroke;

  Color? defaultPolygonBorderColor;

  Color? defaultPolygonFillColor;

  double? defaultPolygonBorderStroke;

  bool? defaultPolygonIsFilled;

  /// default [CircleMarker] border color
  Color? defaultCircleMarkerColor;

  /// default [CircleMarker] border stroke
  Color? defaultCircleMarkerBorderColor;

  /// default flag if [CircleMarker] is filled (default is true)
  bool? defaultCircleMarkerIsFilled;

  /// user defined callback function called when the [Marker] is tapped
  void Function(Map<String, dynamic>)? onMarkerTapCallback;

  /// user defined callback function called when the [CircleMarker] is tapped
  void Function(Map<String, dynamic>)? onCircleMarkerTapCallback;

  /// user defined callback function called during parse for filtering
  FilterFunction? filterFunction;

  /// default constructor - all parameters are optional and can be set later with setters
  CustomGeoJsonParser({
    this.markerCreationCallback,
    this.polyLineCreationCallback,
    this.polygonCreationCallback,
    this.circleMarkerCreationCallback,
    this.filterFunction,
    this.defaultMarkerColor,
    this.defaultMarkerIcon,
    this.onMarkerTapCallback,
    this.defaultPolylineColor,
    this.defaultPolylineStroke,
    this.defaultPolygonBorderColor,
    this.defaultPolygonFillColor,
    this.defaultPolygonBorderStroke,
    this.defaultPolygonIsFilled,
    this.defaultCircleMarkerColor,
    this.defaultCircleMarkerBorderColor,
    this.defaultCircleMarkerIsFilled,
    this.onCircleMarkerTapCallback,
  });

  /// parse GeJson in [String] format
  void parseGeoJsonAsString(String g) {
    return parseGeoJson(jsonDecode(g) as Map<String, dynamic>);
  }

  /// set default [Marker] color
  set setDefaultMarkerColor(Color color) {
    defaultMarkerColor = color;
  }

  /// set default [Marker] icon
  set setDefaultMarkerIcon(IconData ic) {
    defaultMarkerIcon = ic;
  }

  /// set default [Marker] tap callback function
  void setDefaultMarkerTapCallback(
      Function(Map<String, dynamic> f) onTapFunction) {
    onMarkerTapCallback = onTapFunction;
  }

  /// set default [CircleMarker] color
  set setDefaultCircleMarkerColor(Color color) {
    defaultCircleMarkerColor = color;
  }

  /// set default [CircleMarker] tap callback function
  void setDefaultCircleMarkerTapCallback(
      Function(Map<String, dynamic> f) onTapFunction) {
    onCircleMarkerTapCallback = onTapFunction;
  }

  /// set default [Polyline] color
  set setDefaultPolylineColor(Color color) {
    defaultPolylineColor = color;
  }

  /// set default [Polyline] stroke
  set setDefaultPolylineStroke(double stroke) {
    defaultPolylineStroke = stroke;
  }

  /// set default [Polygon] fill color
  set setDefaultPolygonFillColor(Color color) {
    defaultPolygonFillColor = color;
  }

  /// set default [Polygon] border stroke
  set setDefaultPolygonBorderStroke(double stroke) {
    defaultPolygonBorderStroke = stroke;
  }

  /// set default [Polygon] border color
  set setDefaultPolygonBorderColorStroke(Color color) {
    defaultPolygonBorderColor = color;
  }

  /// set default [Polygon] setting whether polygon is filled
  set setDefaultPolygonIsFilled(bool filled) {
    defaultPolygonIsFilled = filled;
  }

  /// main GeoJson parsing function
  void parseGeoJson(Map<String, dynamic> g) {
    // set default values if they are not specified by constructor
    markerCreationCallback ??= createDefaultMarker;
    circleMarkerCreationCallback ??= createDefaultCircleMarker;
    polyLineCreationCallback ??= createDefaultPolyline;
    polygonCreationCallback ??= createDefaultPolygon;
    filterFunction ??= defaultFilterFunction;
    defaultMarkerColor ??= Colors.red.withOpacity(0.8);
    defaultMarkerIcon ??= Icons.location_pin;
    defaultPolylineColor ??= Colors.blue.withOpacity(0.8);
    defaultPolylineStroke ??= 3.0;
    defaultPolygonBorderColor ??= Colors.black.withOpacity(0.8);
    defaultPolygonFillColor ??= Colors.black.withOpacity(0.1);
    defaultPolygonIsFilled ??= true;
    defaultPolygonBorderStroke ??= 1.0;
    defaultCircleMarkerColor ??= Colors.blue.withOpacity(0.25);
    defaultCircleMarkerBorderColor ??= Colors.black.withOpacity(0.8);
    defaultCircleMarkerIsFilled ??= true;

    // loop through the GeoJson Map and parse it
    for (Map f in g['features'] as List) {
      String geometryType = f['geometry']['type'].toString();
      // check if this spatial object passes the filter function
      if (!filterFunction!(f['properties'] as Map<String, dynamic>)) {
        continue;
      }
      switch (geometryType) {
        case 'Point':
          {
            markers.add(
              markerCreationCallback!(
                  LatLng(f['geometry']['coordinates'][1] as double,
                      f['geometry']['coordinates'][0] as double),
                  f['properties'] as Map<String, dynamic>),
            );
          }
          break;
        case 'Circle':
          {
            circles.add(
              circleMarkerCreationCallback!(
                  LatLng(f['geometry']['coordinates'][1] as double,
                      f['geometry']['coordinates'][0] as double),
                  f['properties'] as Map<String, dynamic>),
            );
          }
          break;
        case 'MultiPoint':
          {
            for (final point in f['geometry']['coordinates'] as List) {
              markers.add(
                markerCreationCallback!(
                    LatLng(point[1] as double, point[0] as double),
                    f['properties'] as Map<String, dynamic>),
              );
            }
          }
          break;
        case 'LineString':
          {
            final List<LatLng> lineString = [];
            for (final coords in f['geometry']['coordinates'] as List) {
              lineString.add(LatLng(coords[1] as double, coords[0] as double));
            }
            polylines.add(polyLineCreationCallback!(
                lineString, f['properties'] as Map<String, dynamic>));
          }
          break;
        case 'MultiLineString':
          {
            for (final line in f['geometry']['coordinates'] as List) {
              final List<LatLng> lineString = [];
              for (final coords in line as List) {
                lineString
                    .add(LatLng(coords[1] as double, coords[0] as double));
              }
              polylines.add(polyLineCreationCallback!(
                  lineString, f['properties'] as Map<String, dynamic>));
            }
          }
          break;
        case 'Polygon':
          {
            ///
            final List<LatLng> outerRing = [];
            final List<List<LatLng>> holesList = [];
            int pathIndex = 0;
            for (final path in f['geometry']['coordinates'] as List) {
              final List<LatLng> hole = [];
              for (final coords in path as List<dynamic>) {
                if (pathIndex == 0) {
                  // add to polygon's outer ring
                  outerRing
                      .add(LatLng(coords[1] as double, coords[0] as double));
                } else {
                  // add it to current hole
                  hole.add(LatLng(coords[1] as double, coords[0] as double));
                }
              }
              if (pathIndex > 0) {
                // add hole to the polygon's list of holes
                holesList.add(hole);
              }
              pathIndex++;
            }
            if (f['properties']['main'].toString().contains('true')) {
              polygonsWithProperties.add(PolygonWithProperties(polygonCreationCallback!(
                  outerRing, holesList, f['properties'] as Map<String, dynamic>, Colors.white), f['properties'] as Map<String, dynamic>,));
            }
            else {
              polygonsWithProperties.add(PolygonWithProperties(polygonCreationCallback!(
                  outerRing, holesList, f['properties'] as Map<String, dynamic>, defaultPolygonFillColor), f['properties'] as Map<String, dynamic>));
            }
          }
          break;
        case 'MultiPolygon':
          {
            for (final polygon in f['geometry']['coordinates'] as List) {
              final List<LatLng> outerRing = [];
              final List<List<LatLng>> holesList = [];
              int pathIndex = 0;
              for (final path in polygon as List) {
                List<LatLng> hole = [];
                for (final coords in path as List<dynamic>) {
                  if (pathIndex == 0) {
                    // add to polygon's outer ring
                    outerRing
                        .add(LatLng(coords[1] as double, coords[0] as double));
                  } else {
                    // add it to a hole
                    hole.add(LatLng(coords[1] as double, coords[0] as double));
                  }
                }
                if (pathIndex > 0) {
                  // add to polygon's list of holes
                  holesList.add(hole);
                }
                pathIndex++;
              }
              if (f['properties']['main'].toString().contains('true')) {
                polygons.add(polygonCreationCallback!(outerRing, holesList,
                    f['properties'] as Map<String, dynamic>, Colors.white));
              }
              else {
                polygons.add(polygonCreationCallback!(outerRing, holesList,
                    f['properties'] as Map<String, dynamic>, defaultPolygonFillColor));
              }
            }
          }
          break;
      }
    }
    return;
  }

  /// default function for creating tappable [Marker]
  Widget defaultTappableMarker(Map<String, dynamic> properties,
      void Function(Map<String, dynamic>) onMarkerTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onMarkerTap(properties);
        },
        child: Icon(defaultMarkerIcon, color: defaultMarkerColor),
      ),
    );
  }

  /// default callback function for creating [Marker]
  Marker createDefaultMarker(LatLng point, Map<String, dynamic> properties) {
    return Marker(
      point: point,
      child: defaultTappableMarker(properties, markerTapped),
    );
  }

  // /// default callback function for creating [Marker]
  // Marker createDefaultMarker(LatLng point, Map<String, dynamic> properties) {
  //   return Marker(
  //     point: point,
  //     child: MouseRegion(
  //       cursor: SystemMouseCursors.click,
  //       child: GestureDetector(
  //         onTap: () {
  //           markerTapped(properties);
  //         },
  //         child: Icon(defaultMarkerIcon, color: defaultMarkerColor),
  //       ),
  //     ),
  //     width: 60,
  //     height: 60,
  //   );
  // }

  /// default callback function for creating [Polygon]
  CircleMarker createDefaultCircleMarker(
      LatLng point, Map<String, dynamic> properties) {
    return CircleMarker(
      point: point,
      radius: properties["radius"].toDouble(),
      useRadiusInMeter: true,
      color: defaultCircleMarkerColor!,
      borderColor: defaultCircleMarkerBorderColor!,
    );
  }

  /// default callback function for creating [Polyline]
  Polyline createDefaultPolyline(
      List<LatLng> points, Map<String, dynamic> properties) {
    return Polyline(
        points: points,
        color: defaultPolylineColor!,
        strokeWidth: defaultPolylineStroke!);
  }

  /// default callback function for creating [Polygon]
  Polygon createDefaultPolygon(List<LatLng> outerRing,
      List<List<LatLng>>? holesList, Map<String, dynamic> properties, Color? color) {
    return Polygon(
      points: outerRing,
      holePointsList: holesList,
      borderColor: defaultPolygonBorderColor!,
      color: color ?? defaultPolygonFillColor!,
      isFilled: defaultPolygonIsFilled!,
      borderStrokeWidth: defaultPolygonBorderStroke!,
    );
  }

  /// the default filter function returns always true - therefore no filtering
  bool defaultFilterFunction(Map<String, dynamic> properties) {
    return true;
  }

  /// default callback function called when tappable [Marker] is tapped
  void markerTapped(Map<String, dynamic> map) {
    if (onMarkerTapCallback != null) {
      onMarkerTapCallback!(map);
    }
  }
}
