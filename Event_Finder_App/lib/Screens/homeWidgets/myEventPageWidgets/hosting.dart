import 'package:flutter/material.dart';
import '../../../models/Event.dart';
import 'package:Event_Finder_App/Screens/home/addEvent.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/moreInfo.dart';
import '../../home/addEvent.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:flushbar/flushbar.dart';
import '../../../msc/imagePath.dart';
import '../../../msc/utils.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//defining hosting event card
hostingEventCard(
    {DocumentReference hostedEventRef,
    Event event,
    BuildContext context,
    double cardSize,
    double cardImgSize,
    Color mainCardColor,
    Function getHostedEvents,
    FireStoreCloud cloud}) {
  print(event.title);
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => moreInfo(
            currentEventRef: event.reference,
          ),
        ),
      );
    },
    child: Stack(
      children: [
        Container(
          height: cardSize,
          width: double.infinity, //take up the whole space
          margin: EdgeInsets.fromLTRB(40, 5, 20, 5),
          decoration: BoxDecoration(
            color: mainCardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(cardImgSize, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  child: Text(
                    '${event.title}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                  height: 10,
                ),
                Row(
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
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
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
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
          left: 20.0,
          top: 15.0,
          bottom: 15.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: Colors.grey[300],
              child: getImage(
                  eventType: event.type,
                  width: cardImgSize,
                  path: event.imagePath,
                  boxFit: BoxFit.fill),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 20,
          child: IconButton(
            icon: Icon(
              Icons.edit,
              color: lighterRed,
              size: 25,
            ),
            onPressed: () async {
              //REMOVE FROM ATTENDING EVENTS
              dynamic newEvent = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => addEvent(
                    passedEvent: event,
                    pageTitle: "Edit Event",
                  ),
                ),
              );

              if (newEvent != null) {
                newEvent.reference = event.reference;
                await cloud.updateEvent(newEvent);
                getHostedEvents();
              }
            },
          ),
        ),
        Positioned(
          bottom: 10,
          right: 20,
          child: Row(children: [
            //add this if you want it to say cancel
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.red,
                size: 25,
              ),
              onPressed: () async {
                var answer = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text(
                        'Are you sure you want to delete this event?',
                        textAlign: TextAlign.center,
                      ),
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SimpleDialogOption(
                              child: const Text('Yes'),
                              onPressed: () async {
                                Navigator.pop(context, true);
                                cloud.removeEvent(hostedEventRef, event);
                                //add snackbar to show event was added
                                Flushbar(
                                  message: "Event removed",
                                  duration: Duration(seconds: 3),
                                ).show(context);
                              },
                            ),
                            SimpleDialogOption(
                              child: const Text('Not sure'),
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                            ),
                          ],
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ]),
        )
      ],
    ),
  );
}
