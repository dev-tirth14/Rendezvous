import 'package:Event_Finder_App/Screens/authenticate/loginPage2.dart';
import 'package:Event_Finder_App/Screens/home/homeWrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("this is before");
    User _user=Provider.of<User>(context);
    print("this is after");
    if(_user==null || _user.emailVerified==false){
      print('AUTHENTICATE WAS EXECUTED');
      if(_user==null){
        print('NULL USER');
      }else if(_user.emailVerified==false){
        print('FALSE VERIFICATION');
      }
      return LoginPage2();
    }else{
      return homeWrapper(_user.uid);
    }
    
  }
}