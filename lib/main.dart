import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:timelines/timelines.dart';

enum Categories {
  unitedStates,
  church,
}
enum Segment {
  summary,
  jan,
  feb,
  march,
  april,
  may,
  june,
  july,
  aug,
  sept,
  oct,
  nov,
  dec
}
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
  late List<Event> _events;
  late MapZoomPanBehavior _zoomPanBehavior;
  List<MapSublayer> _sublayers = [];
  double _year = 1800;
  late List<Marker> _markers;
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
                      child: SfMaps(
                        layers: [
                          MapShapeLayer(
                            //TODO: Stop highlight when hover
                            source: _states,
                            initialMarkersCount: _markers.length,
                            markerBuilder: (BuildContext context, int index) {
                              return MapMarker(
                                latitude: _markers[index].latitude,
                                longitude: _markers[index].longitude,
                                iconColor: _markers[index].color,
                                // iconType: MapIconType.triangle,
                                child: Tooltip(
                                  message: _markers[index].name,
                                  child: Icon(
                                    _markers[index].icon,
                                    size: 15,
                                  ),
                                ),
                              );
                            },
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
    setState(() {
      _markers = _getMarkers(_year);
      _events = _getEvents(_year);
    });
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
          padding: EdgeInsets.all(isHovering ? 4 : 3),
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
    return Container(
      padding: EdgeInsets.all(20),
      height: (MediaQuery.of(context).size.height) * .90,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('\n\n' + _year.toString() + '\n'),
            TimelineTile(
              node: TimelineNode(
                indicator: ContainerIndicator(
                  child: Container(
                    width: 15.0,
                    height: 15.0,
                    color: Colors.blue,
                  ),
                ),
                endConnector: SolidLineConnector(),
              ),
            ),
            for (TimelineTile tile in getYearTimelineTiles()) tile,
            TimelineTile(
              node: TimelineNode(
                indicator: ContainerIndicator(
                  child: Container(
                    width: 15.0,
                    height: 15.0,
                    color: Colors.blue,
                  ),
                ),
                startConnector: SolidLineConnector(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TimelineTile> getYearTimelineTiles() {
    List<TimelineTile> tiles = [];
    TimelineTile tile = TimelineTile(node: const Text("ERROR"));
    List<Event> summaryEvents = [];
    for (Event event in _events) {
      if (event.time == Segment.summary) {
        summaryEvents.add(event);
      } else if (event.category == Categories.unitedStates) {
        tile = TimelineTile(
          oppositeContents: Card(
            color: Colors.blueGrey.shade50,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: 125,
                child: Text(
                  event.summary,
                  maxLines: 30,
                ),
              ),
            ),
          ),
          node: const TimelineNode(
            indicator: DotIndicator(),
            startConnector: SolidLineConnector(),
            endConnector: SolidLineConnector(),
          ),
        );
        tiles.add(tile);
      } else if (event.category == Categories.church) {
        tile = TimelineTile(
          contents: Card(
            color: Colors.blueGrey.shade50,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: 125,
                child: Text(
                  event.summary,
                  maxLines: 30,
                ),
              ),
            ),
          ),
          node: const TimelineNode(
            indicator: DotIndicator(),
            startConnector: SolidLineConnector(),
            endConnector: SolidLineConnector(),
          ),
        );
        tiles.add(tile);
      }
    }
    if (summaryEvents.isNotEmpty) {
      List<String> usStrings = [];
      List<String> churchStrings = [];
      for (Event event in summaryEvents) {
        event.category == Categories.unitedStates
            ? usStrings.add(event.summary)
            : churchStrings.add(event.summary);
      }
      tile = TimelineTile(
        oppositeContents: Card(
          color: Colors.blue.shade50,
          child: Column(
            children: [
              for (String summary in usStrings)
                Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 125,
                    child: Text(
                      summary,
                      maxLines: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
        contents: Card(
          color: Colors.blue.shade50,
          child: Column(
            children: [
              for (String summary in churchStrings)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: 125,
                    child: Text(
                      summary,
                      maxLines: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
        node: const TimelineNode(
          indicator: DotIndicator(),
          startConnector: SolidLineConnector(),
          endConnector: SolidLineConnector(),
        ),
      );
      tiles.insert(0, tile);
    }
    return tiles;
  }
}

List<Event> _getEvents(double year) {
  Categories us = Categories.unitedStates;
  Categories church = Categories.church;

  List<Event> events = [
    Event(1800, us, "Dutch East India Company dissolves", Segment.jan),
    Event(1800, us, "251st pope is crowned", Segment.march),
    Event(1800, us, "First chemical battery presented", Segment.march),
    Event(1800, us, "Beethoven's Symphony No. 1 premieres", Segment.april),
    Event(1800, us, "U.S. Library of Congress founded", Segment.april),
    Event(1800, us, "President John Adams moves into the White House",
        Segment.nov),
    Event(
        1801,
        us,
        "Thomas Jefferson is sworn in as the third President of the United States",
        Segment.march),
    Event(1801, us, "First Census is held in Great Britain", Segment.march),
    Event(1801, us, "French Revolutionary Wars - Action of 6 May 1801",
        Segment.may),
    Event(1801, us, "Cairo falls to the British in the Siege of Cairo",
        Segment.june),
    Event(1801, church, "Brigham Young is born", Segment.june),
    Event(1801, church, "Heber C. Kimball is born", Segment.june),
    Event(
        1801,
        us,
        "First programmable loom exhibits in the National Exposition in Paris",
        Segment.sept),
    Event(1801, us, "First edition of of the New-York Post is printed",
        Segment.dec),
    Event(
        1804,
        us,
        "Introduction of the world's first steam railway locomotive",
        Segment.summary),
    Event(1801, us, "Ultraviolet radiation is discovered", Segment.dec),
    Event(1802, us, "The Rosetta Stone is presented to the British Museum",
        Segment.march),
    Event(
        1802,
        us,
        "The US Army is re-established and opens West Point Military Academy",
        Segment.march),
    Event(1802, us, "The US Patent and Trademark Office is established",
        Segment.june),
    Event(1802, us, "Alexadre Dumas is born", Segment.july),
    Event(
        1802,
        us,
        "The Port of New Oreans and the lower Mississippi River are closes to American traffic, threatening the economy in the western United States (prompting the need for the Louisiana Purchase)",
        Segment.june),
    Event(1803, us, "First \"practical\" steamboat introduction", Segment.jan),
    Event(1803, us, "(Retroactive) Ohio is admitted as the 17th U.S. state",
        Segment.march),
    Event(
        1803,
        us,
        "Louisiana Purchase is completed -- doubling the size of the United States (Mississippi to the Rockies",
        Segment.april),
    Event(1803, us, "Napoleonic Wars begin", Segment.april),
    Event(1803, us, "Ralph Waldo Emerson is born", Segment.may),
    Event(1803, us, "Louisiana Purchase is announced to the American people",
        Segment.july),
    Event(
        1803,
        us,
        "John Dalton begins using symbols to represent the atoms of different elements",
        Segment.sept),
    Event(
        1803,
        us,
        "The Balmis Expedition stats in Spain, with the aim of vaccinating millions against smallpox in Spanish America and the Philippines",
        Segment.nov),
    Event(
        1804,
        us,
        "Haiti gains independence from France (only sucessful slave revolt)",
        Segment.jan),
    Event(
        1804,
        us,
        "New Jersey becomes the last of the northern United States to abolish slavery",
        Segment.feb),
    Event(1804, us, "Lewis and Clark Expedition ", Segment.jan),
    Event(1804, church, "Eliza R. Snow is born ", Segment.jan),
    Event(1804, us, "Immanuel Kant dies", Segment.feb),
    Event(1804, church, "Willard Richards is born ", Segment.june),
    Event(1804, us, "Alexandar Hamilton Dies", Segment.july),
    Event(
        1804, us, "Coronation of Napoleon I as emperor of France", Segment.dec),
    Event(1804, us, "Thomas Jefferson wins reelection campaign", Segment.dec),
    Event(
        1804, us, "World population hits 1 billion milestone", Segment.summary),
    Event(1804, us, "New Holland is renamed Australia", Segment.summary),
    Event(1804, us, "Morphine is first isolated from opium poppy",
        Segment.summary),
    Event(1804, church, "Orson Hyde is born ", Segment.jan),
    Event(
        1805,
        us,
        "Thomas Jefferson is sworn in for a second term as President of the United States",
        Segment.march),
    Event(1804, us, "Hans Christian Andersen is born ", Segment.jan),
    Event(1805, us, "Napoleon is crowned King of Italy", Segment.dec),
    Event(
        1805,
        us,
        "Lewis and Clark Expedition reaches the Continental Divide of the Americas",
        Segment.aug),
    Event(1805, us, "Napoleonic Wars-- War of the Third Coalition occurs",
        Segment.oct),
    Event(1805, us, "Lewis and Clark Expedition arrives at the Pacific Ocean",
        Segment.dec),
    Event(1805, church, "Joseph Smith Born in Vermont", Segment.dec),
    Event(1805, us, "Napoleon orders his soldier to be vaccinated",
        Segment.summary),
    Event(1806, us, "Lewis and Clark Expedition starts their journey home",
        Segment.march),
    Event(
        1806,
        us,
        "Construction is authorized on the first United States federal highway",
        Segment.dec),
    Event(1805, us, "Augustus De Morgan (mathematician) is born", Segment.june),
    Event(1806, us, "Holy Roman Empire Ends after last Emperor abdicates",
        Segment.aug),
    Event(1806, us, "Lewis and Clark Expedition returns back to St. Louis",
        Segment.sept),
    Event(1805, church, "Oliver Cowdery is born", Segment.oct),
    Event(
        1806,
        us,
        "First Webster dictionary is published recording distinctive American spellings",
        Segment.summary),
    Event(1807, us, "Robert E. Lee is born", Segment.jan),
    Event(1807, us, "Slave Trade is abolished in the United Kingdom",
        Segment.feb),
    Event(1807, church, "Wilford Woodruff is born", Segment.jan),
    Event(1807, us, "Slave Trade is abolished in the United States",
        Segment.march),
    Event(1807, us, "Battle of Copenhagen (British v. Napoleon)", Segment.sept),
    Event(1807, us, "Rio de Janeiro becomes the Portuguese capital",
        Segment.sept),
    Event(
        1807,
        us,
        "US passes the Embargo Act (to maintain neutrality in the Napoleon wars",
        Segment.dec),
    Event(1808, us, "Denmark declares war on Sweden", Segment.march),
    Event(
        1808,
        us,
        "A volcano erupts, causing a worldwide drop in marine air temperatures for the following decade",
        Segment.summary),
    Event(
        1808,
        us,
        "Humphry Davy isolates calcium, boron, magnesium, potassium, and strontium",
        Segment.june),
    Event(1808, us, "Jefferson Davis is born (president of the confederacy)",
        Segment.june),
    Event(1808, us, "James Madison wins the US presidential elections",
        Segment.nov),
    Event(1808, us, "Mahmud II becomes sultan of the Ottoman Empire",
        Segment.nov),
    Event(
        1808,
        us,
        "Tsar Alexander I of Russia proclaims finland a part of Russia",
        Segment.dec),
    Event(1808, us, "Mahmud II becomes sultan of the Ottoman Empire",
        Segment.nov),
    Event(
        1808,
        us,
        "Beethoven conducts and plays piano in a marathon benefit concert consisting entirely of first public performances of works(including Symphony No. 5)",
        Segment.nov),
    Event(1809, us, "Edger Allan Poe is born", Segment.jan),
    Event(
        1809,
        us,
        "Illinois Territory is created from part of the Indiana Territory",
        Segment.feb),
    Event(1809, us, "Charles Darwin and Abraham Lincoln are born", Segment.feb),
    Event(
        1809,
        us,
        "US v. Peters (Supreme Court rules that the power of the federal government is greater than any individual state",
        Segment.feb),
    Event(
        1809,
        us,
        "James Madison is sworn in as fourth president of the United States",
        Segment.march),
    Event(1809, us, "Napoleonic Wars -- War of the Fifth Coalition",
        Segment.april),
    Event(
        1809,
        us,
        "Mary Kies becomes the first American woman to be awarded a patent",
        Segment.may),
    Event(1809, us, "Thomas Paine dies", Segment.march),
    Event(1810, us, "The marriage of Napoleon and Josephine is annulled",
        Segment.jan),
    Event(1810, us, "Frederic Chopin is born", Segment.march),
    Event(
        1810,
        us,
        "Napoleon decrees that Rome would become the second capital of the empire",
        Segment.feb),
    Event(1810, us, "Napoleon and Marie-Louise of Austria marry ", Segment.jan),
    Event(
        1810,
        us,
        "Venezuela is the first South American state to proclaim independence from Spain",
        Segment.april),
    Event(1810, us, "Beethoven composes Fur Elise", Segment.april),
    Event(1810, us, "Republic of West Florida declares independence from Spain",
        Segment.sept),
    Event(1810, us, "Beethoven composes Fur Elise", Segment.april),
    Event(
        1810, us, "The US annexes the Republic of West Florida", Segment.april),
    Event(1814, us, "Mexan War of Independence Starts", Segment.sept),
    Event(1810, us, "The first steamboat sails on the Ohio River",
        Segment.summary),
    Event(1811, us, "Paraguay declares independence from the spanish empire",
        Segment.may),
    Event(1811, us, "Harriet Beecher Stowe is born", Segment.june),
    Event(
        1811, us, "Washington is claimed for the United Kingdom", Segment.july),
    Event(
        1811,
        us,
        "Steam Powered Ferry Service between NYC and Hoboken, New Jersey is established",
        Segment.oct),
    Event(1811, us, "Paraguay declares independence from the spanish empire",
        Segment.april),
    Event(
        1811,
        us,
        "Battle of Tippecanoe (US v. Native American spiritual leader)",
        Segment.sept),
    Event(1811, church, "Orson Pratt is born", Segment.sept),
    Event(
        1811,
        us,
        "Earthquake reverses the course of the Mississippi River for awhile)",
        Segment.dec),
    Event(1812, us, "Napoleon authorizes the usage of the metric system",
        Segment.feb),
    Event(1812, us, "Charles Dickens is born", Segment.feb),
    Event(1812, us, "Louisiana is admitted as the 18th U.S. State",
        Segment.april),
    Event(
        1812,
        us,
        "British Prime Minister Spencer Perceval is assassinated in the lobby of the House of Commons",
        Segment.may),
    Event(
        1812,
        us,
        "U.S. President James Madison asks the Congress to declare war on the UK",
        Segment.april),
    Event(1812, us, "Louisiana territory renamed Missouri Territory",
        Segment.april),
    Event(1812, us, "War of 1812 begins between U.S, Canada, and the UK",
        Segment.april),
    Event(1812, us, "Napoleonic War - Battle of Borodino (bloodiest battle)",
        Segment.sept),
    Event(1812, us, "Napoleon begins his retreat from Moscow", Segment.oct),
    Event(1812, us, "James Madison is re-elected", Segment.nov),
    Event(
        1812,
        us,
        "First Volumne of Grimms' Fairy Tales is published in Germany",
        Segment.dec),
    Event(
        1813, us, "Pride and Prejudice is anonymously published", Segment.jan),
    Event(
        1813,
        us,
        "James Madison is sworn in for a second term as President of the US",
        Segment.march),
    Event(1813, us, "Independent government is restored in the Netherlands",
        Segment.nov),
    Event(1813, us, "War of 1812 -- British soldiers burn Buffalo, NY",
        Segment.april),
    Event(
        1814, us, "Napoleonic War -- War of the Sixth Coalition", Segment.feb),
    Event(
        1814, us, "London Great Stock Exchange Fraud is exposed", Segment.feb),
    Event(1814, church, "Lorenzo Snow is born", Segment.april),
    Event(1814, us, "Thomas Coke dies (first American Methodist Bishop)",
        Segment.april),
    Event(
        1814,
        us,
        "War of 1812 -- Treaty of Greenville is signed between the U.S. government and Native American tribes",
        Segment.july),
    Event(1814, us, "The first locomotive test is successful", Segment.july),
    Event(1814, us, "Swedish-Norwegian War begins (Swedish attack)",
        Segment.july),
    Event(1814, us, "Swedish-Norwegian War ends (Norwegian victory)",
        Segment.aug),
    Event(1814, us, "War of 1812 -- Burning of Washington(DC)", Segment.july),
    Event(
        1814,
        us,
        "War of 1812 -- Battle of Baltimore (turning point and inspiration for the star spangled banner)",
        Segment.july),
    Event(1814, us, "War of 1812 -- Burning of Washington(DC)", Segment.july),
    Event(
        1814,
        us,
        "World's first complex machine mass-produced from interchangeable parts (clock) comes off the production lien in Plymouth, Connecticut",
        Segment.summary),
    Event(1815, us, "First commercial cheese factory is founded in Switzerland",
        Segment.feb),
    Event(1815, us, "New Jersey grants the first American railroad charter",
        Segment.feb),
    Event(1815, us, "The War of 1812 officially ends", Segment.feb),
    Event(1815, us, "Mount Tambora erupts causing a volcanic winter ",
        Segment.feb),
    Event(1815, us, "Napoleonic Wars -- Battle of Waterloo", Segment.june),
    Event(
        1815,
        us,
        "Napoleonic Wars -- Napoleon abdicates again and Napoleon II (age 4) rules for 2 weeks",
        Segment.june),
    Event(
        1815,
        us,
        "Napoleonic Wars -- Napoleon restores himself as King of France and subsequently surrenders to the Royal Navy ",
        Segment.feb),
    Event(
        1815,
        us,
        "Napoleonic Wars -- Napoleon is exiled to a remote island in the South Atlantic Ocean ",
        Segment.feb),
    Event(1815, us, "The first hurricane in 180 years strikes New England ",
        Segment.sept),
    Event(
        1815,
        us,
        "Napoleonic Wars -- Napoleon restores himself as King of France and subsequently surrenders to the Royal Navy ",
        Segment.sept),
    Event(1815, us, "Ada Lovelace is born (first computer programmer)",
        Segment.nov),
    Event(1815, us, "Emma by Jane Austen is published ", Segment.dec),
    Event(
        1815,
        us,
        "The second wave of Amish immigration to North America begins ",
        Segment.summary),
    Event(1816, us, "The Year Without a Summer", Segment.summary),
    Event(1816, us, "The Second Bank of the US obtains its charter ",
        Segment.feb),
    Event(
        1815,
        us,
        "Divorce is abolished in France after having been ermitted follwin gthe French Revolution",
        Segment.may),
    Event(1815, us, "Mary Shelley writes Frankenstein", Segment.july),
    Event(
        1815,
        us,
        "Argentina, Uruguay, Bolivia and southern Brazil (United Provinces of South America) declare independence from Spain",
        Segment.feb),
    Event(1815, us, "James Monroe wins the Presidential election", Segment.nov),
    Event(1815, us, "Indiana is admitted as the 19th U.S. state", Segment.dec),
    Event(
        1815,
        us,
        "The American Colonization Society is established to support the emigration of free African Americans to Africa",
        Segment.feb),
    Event(1815, us, "The stethoscope is invented", Segment.summary),
    Event(
        1815,
        us,
        "A rail capable of supporting a heavy locomotive is developed",
        Segment.summary),

    Event(1816, church, "Smith Family Moves to Palmyra", Segment.dec), // Winter
  ];
  List<Event> currentEvents = [];
  for (Event event in events) {
    if (event.year == year) {
      currentEvents.add(event);
    }
  }
  return currentEvents;
}

List<Marker> _getMarkers(double year) {
  List<Marker> markers = [
    Marker("Church of Jesus Christ is founded", 1830, Colors.black, 43.5, -77,
        Icons.church),
    Marker("Nauvoo Temple", 1846, Colors.green, 40.5, -77, Icons.church),
  ];

  List<Marker> currentMarkers = [];
  for (Marker marker in markers) {
    if (marker.year <= year) {
      print(marker.name);
      currentMarkers.add(marker);
    }
  }
  return currentMarkers;
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

class Marker {
  Marker(this.name, this.year, this.color, this.latitude, this.longitude,
      this.icon);
  final String name;
  final int year;
  final Color color;
  final double latitude;
  final double longitude;
  final IconData icon;
}

class Event {
  Event(this.year, this.category, this.summary, this.time);
  final int year;
  final Segment time;
  final Categories category;
  final String summary;
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
