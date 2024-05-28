import 'package:flutter/material.dart';
import '../../../models/Event.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/moreInfo.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import '../../../msc/imagePath.dart';
import '../../../msc/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//list view different cards
attendingEventCard({
  DocumentReference attendingEventRef,
  Event event,
  BuildContext context,
  double cardSize,
  Color mainCardColor,
  double cardImgSize,
}) {
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
                    maxLines: 1,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person_pin,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: Text(
                        'Host: ${event.hostid}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 5.0,
                  height: 10,
                ),

                //delete after this
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
                      child: Expanded(
                        child: Text(
                          getDate(event.date),
                          //'${event.date}',
                          style: TextStyle(
                            color: light,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
                      child: Expanded(
                        child: Text(
                          getTime(event.time),
                          //'${event.time}',
                          style: TextStyle(
                            color: light,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
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
      ],
    ),
  );
}
