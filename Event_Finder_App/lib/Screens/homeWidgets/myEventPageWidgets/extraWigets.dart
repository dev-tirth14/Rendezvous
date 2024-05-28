import 'package:flutter/material.dart';
import '../../../msc/theme.dart';

//will need to change to the location,image
titleTile({String title}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 30.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    ],
  );
}

//builds location header for my events page
buildLocationHeader(
    {String imagePath, String title, BuildContext context}) {
  //LOCAL VAR
  double borderRadius = 30.0;
  return Stack(
    children: [
      Container(
        height: MediaQuery.of(context).size.height / 4.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(30.0),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0.0, 2.0),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius)),
          child: Image(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),

      //title for top image header
      Positioned(
        left: 20,
        bottom: 20,
        child: titleTile(title: title),
      ),
    ],
  );
}

//null event card for my event list view when there are no events
nullEventCard(
    {String title,
    String buttonText,
    String gifPath,
    String route,
    BuildContext context}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        height: 20,
        child: Text(
          title,
          style: TextStyle(
            color: light,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: Image.asset(gifPath),
      ),
      SizedBox(
        height: 2,
      ),
      SizedBox(
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: lighterRed,
          onPressed: () {
            Navigator.of(context).pushNamed(route);
          },
          child: Text(
            buttonText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )
    ],
  );
}
