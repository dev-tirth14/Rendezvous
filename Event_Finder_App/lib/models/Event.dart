import 'package:Event_Finder_App/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String title;
  String description;
  String location;
  String type;
  DocumentReference hostid;
  String date;
  String time;
  //String imagePath = 'assets/img/party.jpg';
  String imagePath;
  DocumentReference reference;
  AppUser hostData;

  Event({
    this.title,
    this.location,
    this.hostid,
    this.date,
    this.time,
    this.description,
    this.type,
    this.imagePath,
  });
  Map<String, dynamic> toMap() {
    return {
      'title': this.title,
      'description': this.description,
      'location': this.location,
      'hostid': this.hostid,
      'date': this.date,
      'time': this.time,
      'imagePath': this.imagePath,
      'type': this.type,
    };
  }

  Event.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.title = map['title'];
    this.location = map['location'];
    this.hostid = map['hostid'];
    this.date = map['date'];
    this.time = map['time'];
    this.description = map['description'];
    this.imagePath = map['imagePath'];
    this.type = map['type'];
  }
  void setHostData(AppUser hostData) {
    this.hostData = hostData;
  }

  String toString() {
    return ('${this.title} ${this.location} ${this.time} ${this.date} ${this.description}');

    /*print(
        '${this.title} ${this.description} ${this.location} ${this.hostid} ${this.date} ${this.time} ');*/
  }
}
