import 'package:Event_Finder_App/services/authentication.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:flutter/material.dart';
import '../../models/Event.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mainDrawer.dart';
import 'package:Event_Finder_App/msc/theme.dart';

//refractored page imports
import '../homeWidgets/myEventPageWidgets/hosting.dart';
import '../homeWidgets/myEventPageWidgets/attending.dart';
import '../homeWidgets/myEventPageWidgets/extraWigets.dart';
import '../homeWidgets/myEventPageWidgets/extraWigets.dart';

class MyEventPage extends StatefulWidget {
  @override
  _MyEventPageState createState() => _MyEventPageState();
}

class _MyEventPageState extends State<MyEventPage> {
  List<Event> _hostedEvents = new List<Event>();
  FireStoreCloud _cloud;
  Authentication _auth;
  GlobalKey<RefreshIndicatorState> _refreshKey;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Defing card sizes and main colors
  double cardSize = 200.0;
  double cardImgSize = 150;
  Color mainCardColor = light;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshKey = GlobalKey();

    _cloud = FireStoreCloud();
    _auth = Authentication();
    getHostedEvents();
  }

  //get all hosted Event from cloud
  void getHostedEvents() async {
    List<Event> listEvents = new List<Event>();
    QuerySnapshot i = await _cloud.firestore
        .collection("users")
        .doc(_auth.firebaseAuth.currentUser.uid)
        .collection("eventsToHost")
        .get();
    print(i);
    List<DocumentSnapshot> k = await i.docs;
    print(k);
    for (int i = 0; i < k.length; i++) {
      var event = await k[i].data()['eventID'].get();
      Event e = new Event.fromMap(event.data(), reference: event.reference);
      listEvents.add(e);
    }
    setState(() {
      this._hostedEvents = listEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1, //By default Attending Events are shown
      length: 2,
      child: Scaffold(
        backgroundColor: dark,
        key: _scaffoldKey,
        drawer: mainDrawer(),
        body: Stack(children: [
          Column(
            children: [
              buildLocationHeader(
                  imagePath: 'assets/img/skylineBackground.jpg',
                  title: "Your Events",
                  context: context),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 90,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),

                  //defining app bar for main navigation
                  child: AppBar(
                    titleSpacing: 0.0,
                    flexibleSpace: Text(
                      'Events',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: mainCardColor,
                    elevation: 0.0,
                    bottom: TabBar(
                      isScrollable: true,
                      unselectedLabelColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: new BubbleTabIndicator(
                        indicatorHeight: 25.0,
                        indicatorColor: lighterRed,
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                      ),
                      //defining different tabs for tab bar
                      tabs: [
                        Tab(
                          text: 'Attending',
                        ),
                        Tab(
                          text: 'Hosting',
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Expanded(
                child: TabBarView(children: [
                  attendingEventsListView(),
                  hostingEventsListView()
                ]),
              ),
            ],
          ),
            IconButton(
              padding: EdgeInsets.only(top:30,left:30),
              icon: Icon(
                Icons.menu,
                color: lighterRed,
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
        
        ]),
      ),
    );
  }

  //list view for attending events
  attendingEventsListView() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: _cloud.firestore
              .collection("users")
              .doc(_auth.firebaseAuth.currentUser.uid)
              .collection("eventsToAttend")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator(
                backgroundColor: lighterRed,
              );
            }
            if (snapshot.data.docs.length == 0) {
              return nullEventCard(
                  title: "You Are Not Attending Any Events",
                  buttonText: "Go Back to Home",
                  gifPath: "assets/gifs/noEvents(dark).gif",
                  route: "/listEvents",
                  context: context);
            }
            return RefreshIndicator(
              key: _refreshKey,
              onRefresh: () async {
                setState(() {});
                dynamic i = await true;
                return i;
              },
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentReference attendingEventRef =
                        snapshot.data.docs[index].reference;
                    print(attendingEventRef);
                    return FutureBuilder(
                        future:
                            snapshot.data.docs[index].data()['eventID'].get(),
                        builder: (context, refSnapshot) {
                          if (!refSnapshot.hasData) {
                            return LinearProgressIndicator();
                          }
                          return attendingEventCard(
                              attendingEventRef: attendingEventRef,
                              event: Event.fromMap(refSnapshot.data.data(),
                                  reference: refSnapshot.data.reference),
                              context: context,
                              cardSize: cardSize,
                              mainCardColor: mainCardColor,
                              cardImgSize: cardImgSize);
                        });
                    /*Future<DocumentSnapshot> event =  snapshot.data.docs[index].data()['eventID'].get();
                  Event event = Event.fromMap(event.data);
                  return _attendingEventCard(event);*/
                  }),
            );
          }),
    );
  }

  //list view for hosting events
  hostingEventsListView() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: _cloud.firestore
              .collection("users")
              .doc(_auth.firebaseAuth.currentUser.uid)
              .collection("eventsToHost")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator(
                backgroundColor: lighterRed,
              );
            }
            if (snapshot.data.docs.length == 0) {
              return nullEventCard(
                  title: "You Are Not Hosting Any Events",
                  buttonText: "Go Back to Home",
                  gifPath: "assets/gifs/noHostEvents(dark).gif",
                  route: "/listEvents",
                  context: context);
            }
            return RefreshIndicator(
              key: _refreshKey,
              onRefresh: () async {
                setState(() {});
                dynamic i = await true;
                return i;
              },
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentReference hostedEventRef =
                        snapshot.data.docs[index].reference;
                    return FutureBuilder(
                        future:
                            snapshot.data.docs[index].data()['eventID'].get(),
                        builder: (context, refSnapshot) {
                          if (!refSnapshot.hasData) {
                            return LinearProgressIndicator();
                          }
                          return hostingEventCard(
                              hostedEventRef: hostedEventRef,
                              event: Event.fromMap(refSnapshot.data.data(),
                                  reference: refSnapshot.data.reference),
                              context: context,
                              cardSize: cardSize,
                              cardImgSize: cardImgSize,
                              mainCardColor: mainCardColor,
                              getHostedEvents: getHostedEvents,
                              cloud: _cloud);
                        });
                    /*Future<DocumentSnapshot> event =  snapshot.data.docs[index].data()['eventID'].get();
                  Event event = Event.fromMap(event.data);
                  return _attendingEventCard(event);*/
                  }),
            );
          }),
    );
  }
}
