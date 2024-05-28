import 'dart:async';
import 'dart:ui';
import 'package:Event_Finder_App/Screens/authenticate/loginPage2.dart';
import 'package:Event_Finder_App/Screens/home/myEventPage.dart';
import 'package:Event_Finder_App/Screens/home/newProfile.dart';
import 'package:Event_Finder_App/models/Event.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:Event_Finder_App/services/authentication.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'ListEvents.dart';

class mainDrawer extends StatefulWidget {
  @override
  _mainDrawerState createState() => _mainDrawerState();
}

class _mainDrawerState extends State<mainDrawer> {
  FireStoreCloud _cloudStore;
  Authentication _auth;
  List<Event> eventList = List<Event>();
  List<Marker> eventMarkers = List<Marker>();

  void initState() {
    super.initState();
    _auth = Authentication();
    _cloudStore = FireStoreCloud();
  }

  Future<Marker> getEventMarker(Event event) async {
    List<Location> closePlaces = await locationFromAddress(event.location);
    LatLng eventPlace =
        LatLng(closePlaces[0].latitude, closePlaces[0].longitude);
    Marker thisPlaceMarker = Marker(
        markerId: MarkerId(event.reference.toString()),
        draggable: false,
        position: eventPlace);
    return thisPlaceMarker;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(25), bottomRight: Radius.circular(25)),
      child: Drawer(
        child: Container(
          color: dark,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  padding: EdgeInsets.all(25),
                  color: light,
                  child: Image.asset(
                    'assets/img/logo2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(Icons.home, color: lighterRed),
                title: Text(
                  'Home',
                  style: TextStyle(fontSize: 20, color: light),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ListEvents()));
                },
              ),
              ListTile(
                leading: Icon(Icons.event, color: lighterRed),
                title: Text(
                  'My Events',
                  style: TextStyle(fontSize: 20, color: light),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyEventPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: lighterRed),
                title: Text(
                  'Profile',
                  style: TextStyle(fontSize: 20, color: light),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => profilePage()));
                },
              ),
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: Icon(Icons.arrow_back, color: lighterRed),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 20, color: light),
                  ),
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.popUntil(context, ModalRoute.withName("/"));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
