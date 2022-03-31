import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MapShapeSource _states;
  late MapShapeSource _counties;
  late List<MapModel> _mapData;
  late MapZoomPanBehavior _zoomPanBehavior;
  @override
  void initState() {
    _mapData = _getMapData();
    _states = MapShapeSource.asset(
      'maps/states.json',
      shapeDataField: 'NAME',
      // dataCount: _mapData.length,
      // primaryValueMapper: (int index) => _mapData[index].state,
      // shapeColorValueMapper: (int index) => _mapData[index].color,
    );
    _counties =
        MapShapeSource.asset('maps/counties.json', shapeDataField: 'NAME');
    _zoomPanBehavior = MapZoomPanBehavior(
      zoomLevel: 6,
      focalLatLng: const MapLatLng(10, -96),
      minZoomLevel: 3,
      maxZoomLevel: 10,
      enableDoubleTapZooming: true,
    );
    print("Init State Done");
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
              Container(
                width: MediaQuery.of(context).size.width / 2,
                child: SfMaps(
                  layers: [
                    MapShapeLayer(
                      source: _states,
                      // showDataLabels: true,
                      // legend: MapLegend(MapElement.shape),
                      shapeTooltipBuilder: (BuildContext context, int index) {
                        return Padding(
                            padding: EdgeInsets.all(7),
                            child: Text(_mapData[index].stateCode,
                                style: TextStyle(color: Colors.white)));
                      },
                      tooltipSettings: MapTooltipSettings(color: Colors.blue),
                      zoomPanBehavior: _zoomPanBehavior,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text("TEST"),
                  Text("TEST"),
                  Text("TEST"),
                  Text("TEST"),
                  Text("TEST"),
                ],
              ),
              Column(
                children: [
                  Text("TEST"),
                  Text("TEST"),
                  Text("TEST"),
                  Text("TEST"),
                  Text("TEST"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<MapModel> _getMapData() {
  return <MapModel>[
    MapModel('Maine', 'Maine', Colors.amber),
    MapModel('Michigan', 'Michigan', Colors.cyan),
    MapModel('Georgia', 'Georgia', Colors.green),
    MapModel('Texas', 'Texas', Colors.cyan),
  ];
}

class MapModel {
  MapModel(this.state, this.stateCode, this.color);

  final String state;
  final String stateCode;
  final Color color;
}
