import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String userName='';
  String biodata='';
  String email='';
  String phoneNumber='';
  String imagePath = 'assets/img/party.jpg';
  DocumentReference reference;

  AppUser(
      {this.userName,
      this.biodata,
      this.email,
      this.phoneNumber,
      this.imagePath,
      });
  Map<String,dynamic> toMap(){
    return {
      'userName':this.userName,
      'biodata':this.biodata,
      'email':this.email,
      'phoneNumber':this.phoneNumber,
      'imagePath':this.imagePath,
    };
  }
  AppUser.fromMap(Map<String,dynamic> map,{this.reference}){
    this.userName=map['userName'];
    this.biodata=map['biodata'];
    this.email=map['email'];
    this.phoneNumber=map['phoneNumber'];
    this.imagePath=map['imagePath'];
  }
  /*String toString() {
    return(
        '${this.userName} ${this.description} ${this.location} ${this.hostid} ${this.date} ${this.time} ');

  }*/

}
