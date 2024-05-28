import 'package:Event_Finder_App/Screens/authenticate/loginPage2.dart';
import 'package:Event_Finder_App/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'Screens/authenticate/registerConfirmPage.dart';
import 'Screens/home/ListEvents.dart';
import 'Screens/home/addEvent.dart';
import 'Screens/wrapper.dart';
import 'Screens/home/moreInfo.dart';
import 'package:flutter/services.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print("Something went wrong");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          print("Main rerendered!");
          return StreamProvider<User>.value(
            value: Authentication().getAuthState(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Wrapper(),
              //CHNAGE BEFORE PUSH
              //home: Wrapper(),
              routes: {
                '/listEvents': (BuildContext context) => ListEvents(),
                '/addEvent': (BuildContext context) => addEvent(passedEvent: null),
                '/moreInfo': (BuildContext context) => moreInfo(currentEventRef: null,),
                '/login': (BuildContext context) => LoginPage2(),
                '/registerConfirmPage': (BuildContext context) =>
                    registerConfirmPage(),
              },
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}

class RegisterUser {}
