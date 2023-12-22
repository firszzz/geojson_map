import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:polylabel/polylabel.dart';

import 'module/custom_geojson_parser.dart';

class GeoJsonMap extends StatefulWidget {
  const GeoJsonMap({Key? key}) : super(key: key);

  @override
  State<GeoJsonMap> createState() => _GeoJsonMapState();
}

class _GeoJsonMapState extends State<GeoJsonMap> {
  /// geoJson initialization

  String testGeoJson = '''
    {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "properties": {
          "main": "true",
          "label": "jopa"
        },
        "geometry": {
          "coordinates": [
            [
              [
                131.89201117618842,
                43.02297360964346
              ],
              [
                131.89195206861632,
                43.022836662115225
              ],
              [
                131.89190175477,
                43.022696798147734
              ],
              [
                131.89185632572895,
                43.02270351500741
              ],
              [
                131.89182745494628,
                43.0226734380272
              ],
              [
                131.8918009813184,
                43.02262107464483
              ],
              [
                131.89179479292966,
                43.02257713754716
              ],
              [
                131.89180627583391,
                43.022522291906085
              ],
              [
                131.8918495936869,
                43.02251801015777
              ],
              [
                131.89182626893268,
                43.022399876745766
              ],
              [
                131.89179864731818,
                43.022217786260796
              ],
              [
                131.89178618843744,
                43.0220466597051
              ],
              [
                131.89178499215717,
                43.02186032554323
              ],
              [
                131.89179750296364,
                43.02169813525944
              ],
              [
                131.89182732043912,
                43.02151124058821
              ],
              [
                131.8918544315734,
                43.021388185154336
              ],
              [
                131.89179496444171,
                43.02137812933992
              ],
              [
                131.8917957139014,
                43.02130436018345
              ],
              [
                131.89180765427506,
                43.02123332733996
              ],
              [
                131.89182332697368,
                43.021202762545215
              ],
              [
                131.89187296702391,
                43.02112327365609
              ],
              [
                131.89193040885283,
                43.02113743911906
              ],
              [
                131.8920179273323,
                43.02092487319672
              ],
              [
                131.89215659246543,
                43.02066494545872
              ],
              [
                131.8925186348888,
                43.02078460954385
              ],
              [
                131.89237343365164,
                43.02105589656341
              ],
              [
                131.8922914084563,
                43.02126242590458
              ],
              [
                131.89222691708494,
                43.021497347450264
              ],
              [
                131.89218520802427,
                43.02176619091804
              ],
              [
                131.89217878122804,
                43.02199524699398
              ],
              [
                131.89219101866553,
                43.022169148207865
              ],
              [
                131.89223268855193,
                43.02244311348292
              ],
              [
                131.8922866601842,
                43.02263179433649
              ],
              [
                131.89232690805352,
                43.022741164862
              ],
              [
                131.8923847800342,
                43.02288230808318
              ],
              [
                131.89201117618842,
                43.02297360964346
              ]
            ]
          ],
          "type": "Polygon"
        },
        "id": 0
      },
      {
        "type": "Feature",
        "properties": {
          "roomId": 1
        },
        "geometry": {
          "coordinates": [
            [
              [
                131.8921420913142,
                43.022575872904014
              ],
              [
                131.89201116418553,
                43.02258074952124
              ],
              [
                131.8919719862027,
                43.02231322808896
              ],
              [
                131.89210374619807,
                43.02230791727672
              ],
              [
                131.8921420913142,
                43.022575872904014
              ]
            ]
          ],
          "type": "Polygon"
        },
        "id": 1
      },
      {
        "type": "Feature",
        "properties": {
          "roomId": 2
        },
        "geometry": {
          "coordinates": [
            [
              [
                131.89189054123847,
                43.022091935962834
              ],
              [
                131.89186410323873,
                43.02189137113311
              ],
              [
                131.8919623118968,
                43.021798200598596
              ],
              [
                131.8920731240184,
                43.02183725407423
              ],
              [
                131.89189054123847,
                43.022091935962834
              ]
            ]
          ],
          "type": "Polygon"
        },
        "id": 2
      },
      {
        "type": "Feature",
        "properties": {
          "roomId": 3
        },
        "geometry": {
          "coordinates": [
            [
              [
                131.89200384731572,
                43.0214790982302
              ],
              [
                131.89208780553912,
                43.02107605475359
              ],
              [
                131.8922607846216,
                43.02108988020663
              ],
              [
                131.8921479758783,
                43.021509014050565
              ],
              [
                131.89200384731572,
                43.0214790982302
              ]
            ]
          ],
          "type": "Polygon"
        },
        "id": 3
      }
    ]
  }
  ''';

  CustomGeoJsonParser parser = CustomGeoJsonParser(
    defaultPolygonFillColor: Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.65),
  );

  bool loadingData = false;

  Future<void> processData() async {
    parser.parseGeoJsonAsString(testGeoJson);
  }

  bool myFilterFunction(Map<String, dynamic> properties) {
    if (properties['main'].toString().contains('true')) {
      return true;
    } else {
      return true;
    }
  }

  /// geoJson initialization

  final markers = <Marker>[];

  double zoomLevel = 15.0;

  late MapController controller;

  @override
  void initState() {
    controller = MapController();
    
    loadingData = true;
    parser.filterFunction = myFilterFunction;
    processData().then((_) {
      setState(() {
        loadingData = false;
      });
    });

    /*parser.polygonsWithProperties.forEach((polygon) {
      if (polygon.properties['main'].toString().contains('true')) {
        print('true');
      } else {
        print('ne true');
      }
    });*/
    // ignore: forEach
    parser.polygonsWithProperties.forEach((polygon) {
      if (!polygon.properties['main'].toString().contains('true')) {
        List<Point> centerOfPolygon = [];

        polygon.polygon.points.forEach((point) {
          centerOfPolygon.add(Point(point.latitude, point.longitude));
        });

        markers.add(
          Marker(
            point: LatLng(polylabel([centerOfPolygon]).point.x.toDouble(), polylabel([centerOfPolygon]).point.y.toDouble()),
            width: 100, height: 80,
            child: Text('влажность = ${Random().nextInt(3)}\nтемпература = ${Random().nextInt(25)}.6'),
          ),
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: controller,
        options: MapOptions(
            onTap: (_, ll) {
              debugPrint(ll.toString());
            },
            initialZoom: zoomLevel,
            maxZoom: 27,
            initialCenter: const LatLng(43.024963, 131.892528),
            onPositionChanged: (position, hasGesture) {
              setState(() {
                if (position.zoom != null) {
                  zoomLevel = position.zoom!;
                }
              });
            }
        ),
        children: [
          TileLayer(
            maxNativeZoom: 18,
            maxZoom: 25,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          loadingData ? const Center(child: CircularProgressIndicator(),)
            : PolygonLayer(
              polygons: zoomLevel >= 20 ? parser.polygonsWithProperties.map((polygon) => polygon.polygon).toList() : []
          ),
          MarkerLayer(
            markers: zoomLevel >= 20 ? markers : []
          ),
        ],
      ),
    );
  }
}