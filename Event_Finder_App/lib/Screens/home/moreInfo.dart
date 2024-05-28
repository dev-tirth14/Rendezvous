import 'package:Event_Finder_App/models/UserModel.dart';
import 'package:Event_Finder_App/msc/imagePath.dart';
import 'package:Event_Finder_App/services/notifications.dart';
import 'package:flutter/material.dart';
import '../../models/Event.dart';
import 'package:Event_Finder_App/models/Event.dart';
import 'package:Event_Finder_App/services/authentication.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:date_format/date_format.dart';
import 'package:flushbar/flushbar.dart';
import '../../msc/imagePath.dart';
import '../../msc/utils.dart';

class moreInfo extends StatefulWidget {
  @override
  _moreInfoState createState() => _moreInfoState();
  DocumentReference currentEventRef;
  Function refreshCallback;
  //recieves data from the first screen as a pramater
  moreInfo({Key key, @required this.currentEventRef, this.refreshCallback})
      : super(key: key);
}

class _moreInfoState extends State<moreInfo> {
  Authentication _auth;
  FireStoreCloud _cloudStore;
  Event _eventData;
  List<AppUser> _rsvpList;
  GlobalKey<RefreshIndicatorState> refreshKey;
  DocumentReference isAttending;
  DocumentReference _userRef;
  bool isRefPresent = true;

  //notfiication
  String _title = 'Rendezvous';
  String _body = 'An Event Your Attending is Starting Now!';
  String _payload = 'eventStart';
  final _notifications = Notifications();

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay picked;

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey();
    _auth = Authentication();
    _cloudStore = FireStoreCloud();
    getEventInfo();
  }

  //Gets Event info from cloud
  getEventInfo() async {
    Event eventData = await _cloudStore.getEventFromRef(widget.currentEventRef);
    if (eventData == null) {
      setState(() {
        isRefPresent = false;
      });
      return;
    }
    List<AppUser> rsvpList =
        await _cloudStore.getRSVPListFromEventRef(widget.currentEventRef);
    DocumentReference userRef =
        await _cloudStore.getCurrentUserRef(_auth.firebaseAuth.currentUser.uid);
    DocumentReference attending =
        await _cloudStore.isRSVPForUser(userRef, eventData);
    setState(() {
      _eventData = eventData;
      _rsvpList = rsvpList;
      isAttending = attending;
      _userRef = userRef;
    });
  }

  //convert string to date type
  DateTime convertDateFromString(String strDate) {
    DateTime todayDate = DateTime.parse(strDate);
    print(todayDate);
    print(formatDate(todayDate,
        [yyyy, '/', mm, '/', dd, ' ', hh, ':', nn, ':', ss, ' ', am]));
  }

  @override
  Widget build(BuildContext context) {
    _notifications.init();
    tz.initializeTimeZones();
    return WillPopScope(
      child: Scaffold(
        backgroundColor: dark,
        body: isRefPresent
            ? _eventData == null
                ? LinearProgressIndicator()
                : RefreshIndicator(
                    key: refreshKey,
                    onRefresh: () {
                      Future status = getEventInfo();
                      return status;
                    },
                    child: Stack(
                      children: <Widget>[
                        //Container that the background image gets placed into
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            width: 400,
                            height: 600,
                            child: getImage(
                                path: _eventData.imagePath,
                                eventType: _eventData.type,
                                boxFit: BoxFit.contain),
                          ),
                        ),
                        //Positioning the type of Event at the upper left corner
                        Positioned(
                          //Event Type
                          child: Text(
                            _eventData.title,
                            style: TextStyle(
                                color: light,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          top: 50,
                          left: 20,
                        ),

                        //Scrollsheet that comes up from the bottom of the screen
                        DraggableScrollableSheet(
                          //Changes the starting and end points of the scrollable sheet
                          //Set to min size to not move
                          maxChildSize: 0.85,
                          //no less than 0.45
                          minChildSize: 0.45,
                          initialChildSize: 0.45,
                          builder: (BuildContext context,
                              ScrollController scrollController) {
                            return Stack(
                              overflow: Overflow.visible,
                              children: [
                                Column(
                                  children: [
                                    //Transparent container to place button, to allow each area of button to be pressed
                                    Container(
                                      height: 30,
                                      color: Colors.transparent,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: light,
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(35),
                                              topLeft: Radius.circular(35)),
                                        ),
                                        //Fills out the scrollable sheet with custom widget infoBox()
                                        child: ListView.builder(
                                          itemBuilder: (context, index) {
                                            return infoBox();
                                          },
                                          controller: scrollController,
                                          itemCount: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                //Button placement right at the cusp of the scrollable sheet
                                Positioned(
                                  child: FloatingActionButton(
                                    child: isAttending != null
                                        ? Icon(Icons.clear, color: Colors.white)
                                        : Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          ),
                                    backgroundColor: lighterRed,
                                    onPressed: () async {
                                      var checkRefStatusResult =
                                          await widget.currentEventRef.get();
                                      if (checkRefStatusResult.data() != null) {
                                        if (isAttending != null) {
                                          Flushbar(
                                            message:
                                                "You are no longer attending this event",
                                            duration: Duration(seconds: 3),
                                          ).show(context);
                                          print('Removed Attending');
                                          _cloudStore.removeRSVP(_userRef,
                                              isAttending, _eventData);
                                          setState(() {
                                            isAttending = null;
                                          });
                                          //_notifications.cancelNotification(_payload);
                                        } else {
                                          await attendingFunctionality(
                                              widget.currentEventRef);
                                          DocumentReference eventToAttendRef =
                                              await _cloudStore.isRSVPForUser(
                                                  _userRef, _eventData);
                                          setState(() {
                                            isAttending = eventToAttendRef;
                                          });
                                          print(eventToAttendRef);
                                          print('added attending');

                                          Flushbar(
                                            message:
                                                "You are now attending this event",
                                            duration: Duration(seconds: 3),
                                          ).show(context);
                                          _notifications.sendNotificationLater(
                                              _title,
                                              _body,
                                              convertDateFromString(
                                                  _eventData.date),
                                              _payload);
                                        }
                                      } else {
                                        setState(() {
                                          isRefPresent = false;
                                        });
                                      }
                                    },
                                  ),
                                  right: 30,
                                )
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "This event was removed.",
                      style: TextStyle(
                        color: light,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Please return back to home.",
                      style: TextStyle(
                        color: light,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
      ),
      onWillPop: () async {
        if (widget.refreshCallback != null) {
          widget.refreshCallback();
        }
        return true;
      },
    );
  }

  //Returns a column of infoRows filled with information from cloud
  Widget infoBox() {
    return Column(
      children: [
        infoRow(_eventData.location, Icons.place, subtitle: null),
        Divider(),
        infoRow(
            (toDateString(DateTime.parse(_eventData.date))), Icons.access_time,
            subtitle: getTime(_eventData.time)),
        Divider(),
        infoRow(_eventData.type, Icons.event, subtitle: null),
        Divider(),
        infoRow(_eventData.hostData.userName, Icons.person_pin,
            subtitle: _eventData.hostData.phoneNumber),
        Divider(),
        description('Description:',
            _eventData.description != null ? _eventData.description : ''),
        attendingRow()
      ],
    );
  }

  //Generalized Widget to make quick info rows, takes arguments title, subtitle and which icon that will be trailing
  Widget infoRow(String title, IconData icon, {String subtitle}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: dark,
        ),
      ),
      trailing: Icon(
        icon,
        color: lighterRed,
      ),
      subtitle: (subtitle != null)
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            )
          : null,
    );
  }

  //Description widget, to display the description of a given event in the infoBox
  Widget description(String title, String description) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: dark,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Horizontal list view for all of the users that are attending the event
  Widget attendingRow() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.only(left: 15, top: 10),
        child: Text(
          'Others Attending:',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 20,
            color: dark,
          ),
        ),
      ),
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: _rsvpList.length,
          itemBuilder: (BuildContext context, int index) {
            return attendingPerson(_rsvpList[index]);
          },
          scrollDirection: Axis.horizontal,
        ),
      ),
    ]);
  }

  //A singular person attending
  Widget attendingPerson(AppUser user) {
    print(user.imagePath);
    return Padding(
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Column(
        children: [
          Container(
            child: CircleAvatar(
              backgroundImage: getProfileImage(path: user.imagePath),
              backgroundColor: lighterRed,
            ),
          ),
          Text(
            user.userName,
            style: TextStyle(
              color: dark,
            ),
          ),
        ],
      ),
    );
  }

  //Function that has the functionality of the attending button on the moreInfo page
  attendingFunctionality(DocumentReference event) async {
    DocumentSnapshot userSnap = await _cloudStore.firestore
        .collection("users")
        .doc(_auth.firebaseAuth.currentUser.uid)
        .get();
    DocumentReference userRef = await userSnap.reference;
    await event.collection("RSVP").add({'uid': userRef});
    await _cloudStore.firestore
        .collection("users")
        .doc(_auth.firebaseAuth.currentUser.uid)
        .collection('eventsToAttend')
        .add({"eventID": event});
    return true;
  }
}
