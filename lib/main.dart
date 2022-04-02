import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:timelines/timelines.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapAndTimeline(),
    );
  }
}

class MapAndTimeline extends StatefulWidget {
  const MapAndTimeline({Key? key}) : super(key: key);

  @override
  State<MapAndTimeline> createState() => _MapAndTimelineState();
}

class _MapAndTimelineState extends State<MapAndTimeline> {
  late MapShapeSource _states;
  late List<MapModel> _mapData;
  late MapZoomPanBehavior _zoomPanBehavior;
  List<MapSublayer> _sublayers = [];
  double _year = 1800;
  // bool _paused = true;
  @override
  void initState() {
    update_map();
    _zoomPanBehavior = MapZoomPanBehavior(
      zoomLevel: 6,
      focalLatLng: const MapLatLng(40, -96),
      minZoomLevel: 3,
      maxZoomLevel: 10,
      enableDoubleTapZooming: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaInfo = MediaQuery.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // MapShapeLayer(source: _counties),
              Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: SfMaps(
                        layers: [
                          MapShapeLayer(
                            source: _states,
                            // showDataLabels: true,
                            // legend: MapLegend(MapElement.shape),
                            shapeTooltipBuilder:
                                (BuildContext context, int index) {
                              return Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Text(_mapData[index].stateCode,
                                      style: TextStyle(color: Colors.white)));
                            },
                            tooltipSettings:
                                MapTooltipSettings(color: Colors.blue),
                            zoomPanBehavior: _zoomPanBehavior,
                            sublayers: _sublayers,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.fast_rewind),
                          onPressed: () {
                            setState(
                              () {
                                if (_year > 1800 && _year < 1950) {
                                  _year -= 5;
                                  update_map();
                                }
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.fast_rewind_outlined),
                          onPressed: () {
                            setState(
                              () {
                                if (_year > 1800 && _year < 1950) {
                                  _year--;
                                  update_map();
                                }
                              },
                            );
                          },
                        ),
                        // IconButton(
                        //   icon: _paused
                        //       ? const Icon(Icons.play_arrow)
                        //       : const Icon(Icons.pause),
                        //   onPressed: () {
                        //     setState(
                        //       () {
                        //         _paused ? _paused = false : _paused = true;
                        //         if (_paused == false) {
                        //           _year++;
                        //           if (_year == 1950) {
                        //             _year = 1800;
                        //           }
                        //         }
                        //       },
                        //     );
                        //   },
                        // ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Slider(
                            value: _year,
                            min: 1800,
                            max: 1950,
                            divisions: 150,
                            label: _year.round().toString(),
                            onChanged: (double value) {
                              setState(
                                () {
                                  _year = value;
                                  update_map();
                                },
                              );
                            },
                          ),
                        ),
                        Text(_year.toString()),
                        IconButton(
                          icon: const Icon(Icons.fast_forward_outlined),
                          onPressed: () {
                            setState(
                              () {
                                if (_year >= 1800 && _year < 1950) {
                                  _year += 1;
                                  update_map();
                                }
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.fast_forward),
                          onPressed: () {
                            setState(
                              () {
                                if (_year >= 1800 && _year < 1950) {
                                  _year += 5;
                                  update_map();
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: getTimeline(),
                  ),
                ),
              ),
              // child: TimelineTile(
              //   oppositeContents: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Text('opposite\ncontents'),
              //   ),
              //   contents: Card(
              //     child: Container(
              //       padding: EdgeInsets.all(8.0),
              //       child: Text('contents'),
              //     ),
              //   ),
              //   node: TimelineNode(
              //     indicator: DotIndicator(),
              //     startConnector: SolidLineConnector(),
              //     endConnector: SolidLineConnector(),
              //   ),
              // ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void update_map() {
    _mapData = _getMapData(_year);
    _states = MapShapeSource.asset(
      'maps/states.json',
      shapeDataField: 'NAME',
      dataCount: _mapData.length,
      primaryValueMapper: (int index) => _mapData[index].stateCode,
      shapeColorValueMapper: (int index) => _mapData[index].color,
    );
  }

  Widget getCard() {
    bool isHovering = false;
    String text = "Hello";
    return Container(
      child: InkWell(
        onTap: () => null,
        onHover: (hovering) {
          print("Hovering" + hovering.toString());
          setState(() {
            isHovering = hovering;
            int newYork = _mapData
                .indexWhere((element) => element.stateCode == 'New York');
            _mapData[newYork];
            _sublayers = [getStateInvert(_mapData[newYork])];
            isHovering
                ? _sublayers = [getStateInvert(_mapData[newYork])]
                : _sublayers = [];
            isHovering ? text = "hi" : text = "hello";
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
          padding: EdgeInsets.all(isHovering ? 45 : 30),
          decoration: BoxDecoration(
            color: isHovering ? Colors.indigoAccent : Colors.green,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 9, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget getTimeline() {
    return FixedTimeline.tileBuilder(
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.after,
        itemCount: 1,
        contentsBuilder: (_, index) {
          return Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  getCard(),
                ],
              ));
        },
        indicatorBuilder: (_, index) {
          return const OutlinedDotIndicator(
            borderWidth: 2.5,
          );
        },
        connectorBuilder: (_, index, __) => const SolidLineConnector(
          color: Colors.red,
        ),
      ),
    );
  }
}

List<MapModel> _getMapData(double year) {
  Color stateColor = Colors.blueAccent;
  List<String> confederateStates = [
    'South Carolina',
    'Mississippi',
    'Florida',
    'Alabama',
    'Georgia',
    'Louisiana',
    'Texas',
    'Virginia',
    'Arkansas',
    'Tennessee',
    'North Carolina'
  ];
  List<MapModel> states = [
    MapModel(1787, 'Delaware', stateColor),
    MapModel(1787, 'Pennsylvania', stateColor),
    MapModel(1788, 'New Jersey', stateColor),
    MapModel(1788, 'Georgia', stateColor),
    MapModel(1788, 'Connecticut', stateColor),
    MapModel(1788, 'Massachusetts', stateColor),
    MapModel(1788, 'Maryland', stateColor),
    MapModel(1788, 'South Carolina', stateColor),
    MapModel(1788, 'New Hampshire', stateColor),
    MapModel(1788, 'Virginia', stateColor),
    MapModel(1788, 'New York', stateColor),
    MapModel(1788, 'North Carolina', stateColor),
    MapModel(1790, 'Rhode Island', stateColor),
    MapModel(1791, 'Vermont', stateColor),
    MapModel(1792, 'Kentucky', stateColor),
    MapModel(1796, 'Tennessee', stateColor),
    MapModel(1803, 'Ohio', stateColor),
    MapModel(1812, 'Louisiana', stateColor),
    MapModel(1816, 'Indiana', stateColor),
    MapModel(1817, 'Mississippi', stateColor),
    MapModel(1818, 'Illinois', stateColor),
    MapModel(1819, 'Alabama', stateColor),
    MapModel(1820, 'Maine', stateColor),
    MapModel(1821, 'Missouri', stateColor),
    MapModel(1836, 'Arkansas', stateColor),
    MapModel(1837, 'Michigan', stateColor),
    MapModel(1845, 'Florida', stateColor),
    MapModel(1845, 'Texas', stateColor),
    MapModel(1846, 'Iowa', stateColor),
    MapModel(1848, 'Wisconsin', stateColor),
    MapModel(1850, 'California', stateColor),
    MapModel(1858, 'Minnesota', stateColor),
    MapModel(1859, 'Oregon', stateColor),
    MapModel(1861, 'Kansas', stateColor),
    MapModel(1788, 'West Virginia',
        year < 1863 ? Colors.lightBlueAccent : stateColor),
    MapModel(1864, 'Nevada', stateColor),
    MapModel(1867, 'Nebraska', stateColor),
    MapModel(1876, 'Colorado', stateColor),
    MapModel(1889, 'North Dakota', stateColor),
    MapModel(1889, 'South Dakota', stateColor),
    MapModel(1889, 'Montana', stateColor),
    MapModel(1889, 'Washington', stateColor),
    MapModel(1889, 'Idaho', stateColor),
    MapModel(1890, 'Wyoming', stateColor),
    MapModel(1896, 'Utah', stateColor),
    MapModel(1907, 'Oklahoma', stateColor),
    MapModel(1912, 'New Mexico', stateColor),
    MapModel(1912, 'Arizona', stateColor),
    MapModel(1959, 'Alaska', stateColor),
    MapModel(1956, 'Hawaii', stateColor),
  ];
  List<MapModel> currentStates = [];
  for (MapModel state in states) {
    if (state.year < year) {
      if (year >= 1861 && year <= 1865) {
        if (confederateStates.contains(state.stateCode)) {
          state.color = Colors.deepPurpleAccent;
        }
      }
      currentStates.add(state);
    }
  }
  return currentStates;
}

class MapModel {
  MapModel(this.year, this.stateCode, this.color);
  final int year;
  final String stateCode;
  Color color;
}

MapShapeSublayer getStateInvert(MapModel state) {
  MapShapeSource _sublayerSource = MapShapeSource.asset(
    'maps/states.json',
    shapeDataField: 'NAME',
    dataCount: 1,
    primaryValueMapper: (int index) => state.stateCode,
    shapeColorValueMapper: (int index) => Colors.pink,
  );
  return MapShapeSublayer(source: _sublayerSource);
}
