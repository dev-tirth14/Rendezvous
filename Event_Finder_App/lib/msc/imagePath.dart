import 'package:flutter/material.dart';

//get correct image asset based off eventType
String getEventImagePath({String eventType}) {
  if (eventType == "Conference") {
    return 'assets/img/confrence.png';
  }

  if (eventType == "Workshop") {
    return 'assets/img/workshop.png';
  }

  if (eventType == "Competition") {
    return 'assets/img/competition.png';
  }

  if (eventType == "Party") {
    return 'assets/img/party.png';
  }

  //defaul value for other
  return 'assets/img/other.png';
}

getImage({String path, String eventType, double width, BoxFit boxFit}) {
  if (path == "") {
    return Image.asset(
      getEventImagePath(eventType: eventType),
      width: width,
      fit: boxFit,
    );
  } else {
    return Image.network(path, width: width, fit: boxFit);
  }
}

getProfileImage({String path, double width, BoxFit boxFit}) {
  print(path);
  if (path == "") {
    return AssetImage('assets/img/profile.png');
  } else {
    return NetworkImage(path);
  }
}
