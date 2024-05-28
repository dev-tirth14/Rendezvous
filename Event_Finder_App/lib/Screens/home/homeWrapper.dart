import 'package:Event_Finder_App/Screens/home/ListEvents.dart';
import 'package:Event_Finder_App/Screens/home/userInfoRegistration.dart';
import 'package:Event_Finder_App/models/UserModel.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class homeWrapper extends StatefulWidget {
  String uid;
  homeWrapper(this.uid,{ Key key}) : super(key: key);
  @override
  _homeWrapperState createState() => _homeWrapperState();
}

class _homeWrapperState extends State<homeWrapper> {
  void callback(){
    setState(() {
      
    });
  }
  @override
  Widget build(BuildContext context) {
     return FutureBuilder(
      future: FireStoreCloud().firestore.collection("users").doc(this.widget.uid).get(),
      builder: (context, snapshot){
        print(snapshot.connectionState);
        if(snapshot.connectionState==ConnectionState.done){
          if(snapshot.data.data()==null){
            return userInfoRegistrationPage(callback);
          }else{
            return ListEvents();
          }
          

        }
        
        return Scaffold(body: LinearProgressIndicator(),);
      }
      
    );
  }
}

