import 'dart:async';
import 'dart:math';
import 'package:Event_Finder_App/models/Event.dart';
import 'package:Event_Finder_App/models/EventInRadius.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:Event_Finder_App/services/authentication.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../home/moreInfo.dart';
import 'addEvent.dart';
import '../../models/Filter.dart';
import '../../models/FilterModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:Event_Finder_App/msc/utils.dart';
import 'mainDrawer.dart';
import 'package:flushbar/flushbar.dart';
import '../../msc/imagePath.dart';

class ListEvents extends StatefulWidget {
  @override
  _ListEventsState createState() => _ListEventsState();
}

//List Events page, also known as the Home Page
class _ListEventsState extends State<ListEvents> {
  @override
  Authentication _auth;
  FireStoreCloud _cloudStore;
  List<Event> eventList = List<Event>();
  List<Marker> eventMarkers = List<Marker>();
  bool infoLoaded = false;
  ItemScrollController itemScrollController;
  ItemPositionsListener itemPositionsListener;

  static CameraPosition _initialMapPosition;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  List<Filter> filterList = List<Filter>();
  FilterModel _model = FilterModel();
  //Store the radius to filter by and event type needed for local storage
  String currentFilterTypeVal = "";
  List<String> filterTypeOptions = [
    "Conference",
    "Workshop",
    "Competition",
    "Party",
    "All"
  ];
  String currentRadiusVal = "";
  List<String> radiusOptions = ["5", "20", "50", "100", "All"];
  PageController pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _auth = Authentication();
    _cloudStore = FireStoreCloud();
    pageController = PageController(viewportFraction: 0.7);
    //local storage
    getEventsInfo();
  }

  // --- FUTURE FUNCTIONS --- //

  //Returns the current location of the users phone as currentPosition of type Position
  Future<Position> getCurrentLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _initialMapPosition = CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 14);
    });
    return currentPosition;
  }

  //Returns Latitude and Longitude of a given string location
  Future<LatLng> getLatLngForLocation(String location) async {
    List<Location> closePlaces = await locationFromAddress(location);
    LatLng eventPlace =
        LatLng(closePlaces[0].latitude, closePlaces[0].longitude);
    return eventPlace;
  }

  //Animates camera to a given String location
  Future<void> gotoLocation(String location, int index) async {
    final togoLocation = await getLatLngForLocation(location);
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: togoLocation, zoom: 16)));
    mapController.showMarkerInfoWindow(eventMarkers[index].markerId);
  }

  //Checks if a given location is in a certain radius around your current LatLng
  Future<EventInRadius> isInRadius(
      String location, LatLng currentLatLng) async {
    LatLng eventLatLng = await getLatLngForLocation(location);
    if (filterList[1].value == "All") {
      return EventInRadius(true, eventLatLng);
    }
    double result = getDistance(currentLatLng, eventLatLng);
    return EventInRadius(
        result <= double.parse(filterList[1].value), eventLatLng);
  }

  Future<bool> _reload() async {
    var result = await _model.getAllFilter();

    //empty database we have to initilize it
    if (result.length == 0) {
      Filter eventFilter = Filter(filterType: "event type", value: "All");
      Filter radiusFilter = Filter(filterType: "radius", value: "All");

      //add default filter then fetch again
      _addFilter(newFilter: eventFilter);
      _addFilter(newFilter: radiusFilter);

      //fetch values again after adding new values
      result = await _model.getAllFilter();
      setState(() {
        filterList = result;
      });
    } else {
      setState(() {
        filterList = result;
      });
    }
    setState(() {
      currentRadiusVal = filterList[1].value;
      currentFilterTypeVal = filterList[0].value;
    });
    print("FilterList: $filterList");
    return true;
  }

  // --- FUNCTIONS --- //

  //filterType can be either be radius,event type
  _editFilter({String filterType, String newVal}) async {
    print('EDIT PRESSED');
    var edittedFilter = Filter(filterType: filterType, value: newVal);
    if (edittedFilter != null) {
      var index = await _model.editFilter(edittedFilter);
      print(index);
    }
    await _reload();
  }

  _deleteFilter({String filterType}) {
    print('DELETE PRESSED');
    var deletedGrade = _model.deleteFilterByFilterType(filterType);
    print(deletedGrade);
    _reload();
  }

  _addFilter({Filter newFilter}) async {
    if (newFilter != null) {
      var index = await _model.insertFilter(newFilter);
      print(index);
    }
    _reload();
  }

  _reorderList(List<String> list, String val) {
    List<String> newlist = [];
    newlist.add(val);
    for (int i = 0; i < list.length; i++) {
      if (list[i] != val) {
        newlist.add(list[i]);
      }
    }
    return newlist;
  }

  //Reloads all information needed for home page
  getEventsInfo() async {
    Position currentPosition = await getCurrentLocation();
    await _reload();
    await getListofEvents(
        LatLng(currentPosition.latitude, currentPosition.longitude));
    setState(() {
      infoLoaded = true;
    });
  }

  //Animate the camera to the current location of the user
  showCurrent() async {
    Position location = await getCurrentLocation();
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude), zoom: 16)));
  }

  //Gets list of events
  getListofEvents(LatLng currentPosition) async {
    List<Event> events = await _cloudStore.getListOfAllEvents(filterList[0]);
    List<Event> filteredEvents = List<Event>();
    List<Marker> markers = List<Marker>();

    for (int i = 0; i < events.length; i++) {
      EventInRadius result =
          await isInRadius(events[i].location, currentPosition);
      if (result.isInRadius) {
        filteredEvents.add(events[i]);
        markers.add(getEventMarker(events[i], result.eventLatLng, i));
      }
    }
    await setState(() {
      eventList = filteredEvents;
      eventMarkers = markers;
    });
    return true;
  }

  //
  Marker getEventMarker(Event event, LatLng eventLatLng, int i) {
    Marker thisPlaceMarker = Marker(
        markerId: MarkerId(event.reference.toString()),
        infoWindow:
            InfoWindow(title: event.title, snippet: event.type, onTap: () {}),
        draggable: false,
        onTap: () {
          if (pageController.hasClients) {
            pageController.animateToPage(i,
                duration: Duration(seconds: 1), curve: Curves.ease);
          }
        },
        position: eventLatLng);
    return thisPlaceMarker;
  }

  //Returns the distance between the users current location and the events location
  double getDistance(LatLng currentLatLng, LatLng eventLatLng) {
    var r = 6371;
    var dLat = ToRadians(eventLatLng.latitude - currentLatLng.latitude);
    var dLon = ToRadians(eventLatLng.longitude - currentLatLng.longitude);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(ToRadians(currentLatLng.latitude)) *
            cos(ToRadians(eventLatLng.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = r * c;
    return d;
  }

  double ToRadians(double deg) {
    return deg * (pi / 180);
  }

  List<Filter> getFilterList() {
    return this.filterList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: dark,
      drawer: mainDrawer(),
      body: Stack(
        children: [
          //Whenver infoLoaded changes, reload the entire Google Map
          (!infoLoaded
              ? LinearProgressIndicator()
              : GoogleMap(
                  //Properties of Google Maps map customized to our needs
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  initialCameraPosition: _initialMapPosition,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _controller.complete(controller);
                    controller.setMapStyle(Utils.mapStyle);
                  },
                  zoomGesturesEnabled: true,
                  markers: eventMarkers.toSet(),
                  circles: (filterList.length == 0)
                      ? null
                      : (filterList[1].value == "All")
                          ? null
                          : [
                              Circle(
                                  circleId: CircleId("mainRadius"),
                                  fillColor: Colors.blue.withAlpha(50),
                                  strokeWidth: 0,
                                  center: LatLng(
                                      _initialMapPosition.target.latitude,
                                      _initialMapPosition.target.longitude),
                                  radius:
                                      1000 * double.parse(filterList[1].value))
                            ].toSet(),
                  zoomControlsEnabled: false,
                )),

          //Builds the top filter bar
          buildEventsBar(),
          Column(children: [
            Padding(
              padding: EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: lighterRed,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                  ),

                  gpsButton(),
                  //refreshButton(),
                  _buildEventTypeButton(),
                  _buildRadiusButton(),
                ],
              ),
            )
          ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: light,
        ),
        backgroundColor: lighterRed,
        onPressed: () async {
          Event nullEvent = Event();
          dynamic newEvent = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => addEvent(
                passedEvent: nullEvent,
                pageTitle: "Add Event",
              ),
            ),
          );
          if (newEvent != null) {
            //Saves to cloud and display
            DocumentReference eventRef = await _cloudStore.addEvent(newEvent);
            await _cloudStore.firestore
                .collection("users")
                .doc(_auth.firebaseAuth.currentUser.uid)
                .collection('eventsToHost')
                .add({"eventID": eventRef});
            if (filterList.length != 0) {
              await getEventsInfo();
            }
            //snackbar
            Flushbar(
              message: "New Event Created",
              duration: Duration(seconds: 3),
            ).show(context);
          }
        },
      ),
    );
  }

  // --- BUILD WIDGETS --- //

  //onClick centers camera to users location
  Widget gpsButton() {
    return IconButton(
      icon: Icon(Icons.gps_fixed, color: lighterRed),
      onPressed: () {
        showCurrent();
      },
    );
  }

  //Refreshes the main page
  Widget refreshButton() {
    return IconButton(
      icon: Icon(Icons.refresh, color: lighterRed),
      onPressed: () {
        getEventsInfo();
      },
    );
  }

  //Builds bottom horizontal list view
  Widget snapHorizontalBuilder() {
    return PageView.builder(
      itemCount: eventList.length,
      controller: pageController,
      itemBuilder: (BuildContext context, int index) {
        return eventCard(eventList[index], index);
      },
      onPageChanged: (index) {},
    );
  }

  //Builds events bar
  Widget buildEventsBar() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.all(1),
        height: 200,
        child: snapHorizontalBuilder(),
      ),
    );
  }

  //Widget for event card
  Widget eventCard(Event event, int index) {
    return GestureDetector(
      onTap: () {
        gotoLocation(event.location, index);
      },
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => moreInfo(
              currentEventRef: event.reference,
              refreshCallback: getEventsInfo,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: new FittedBox(
            child: Material(
          color: light,
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.40,
                height: MediaQuery.of(context).size.height * 0.25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                      color: Colors.grey[300],
                      child: getImage(
                          path: event.imagePath,
                          eventType: event.type,
                          boxFit: BoxFit.fill)),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: information(event),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  //Widget for information container that goes within the event card
  Widget information(Event event) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.24,
      width: MediaQuery.of(context).size.width * 0.45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              child: Column(children: [
                Text(
                  '${event.title}',
                  style: TextStyle(
                    color: dark,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  child: Text(
                    '${event.type}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ]),
            ),
          ),
          Container(
              child: Text(
            getDetailedLocation(event.location)[0] +
                '\n' +
                getDetailedLocation(event.location)[2],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
            ),
          )),
          dateTimeRow(event),
        ],
      ),
    );
  }

  //Returns a row with the date and time bubbles spaced evenly
  Widget dateTimeRow(Event event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: EdgeInsets.all(5.0),
          //width: 110.0, //maybe restrict the width
          decoration: BoxDecoration(
            color: lighterRed,
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: Alignment.center,
          child: Text(
            getDate(event.date),
            style: TextStyle(
              color: light,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          //width: 110.0, //maybe restrict the width
          decoration: BoxDecoration(
            color: lighterRed,
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: Alignment.center,
          child: Text(
            getTime(event.time),
            style: TextStyle(
              color: light,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  //Returns the event type drop down button
  Widget _buildEventTypeButton() {
    return Container(
      width: MediaQuery.of(context).size.width / 2.8,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        //border: Border.all(),
        color: lighterRed,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentFilterTypeVal,
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          dropdownColor: lighterRed,
          style: TextStyle(color: Colors.black),
          underline: Container(
            height: 2,
            color: Colors.blueAccent,
          ),
          onChanged: (String newValue) {
            setState(() async {
              //currentFilterTypeVal = newValue;
              //update local
              await _editFilter(filterType: "event type", newVal: newValue);
              setState(() {
                infoLoaded = false;
                _controller = Completer();
              });
              await getEventsInfo();
            });
          },
          items: _reorderList(filterTypeOptions, currentFilterTypeVal)
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: light,fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  //Returns radius drop down button
  Widget _buildRadiusButton() {
    return Container(
      width: MediaQuery.of(context).size.width / 4.6,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        //border: Border.all(),
        color: lighterRed,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRadiusVal,
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          dropdownColor: lighterRed,
          style: TextStyle(color: Colors.black),
          underline: Container(
            height: 2,
            color: Colors.blueAccent,
          ),
          onChanged: (String newValue) {
            setState(() async {
              //currentRadiusVal = newValue;
              //upldate local storage with new value
              await _editFilter(filterType: "radius", newVal: newValue);
              setState(() {
                infoLoaded = false;
                _controller = Completer();
              });
              await getEventsInfo();
            });
          },
          items: _reorderList(radiusOptions, currentRadiusVal)
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: light,fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<String> getDetailedLocation(String location) {
    return location.split(",");
  }
}
