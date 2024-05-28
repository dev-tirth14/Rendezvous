import 'package:flutter/material.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:Event_Finder_App/services/authentication.dart';

import 'loginPage2.dart';

class registerConfirmPage extends StatefulWidget {
  @override
  _registerConfirmPageState createState() => _registerConfirmPageState();
}

class _registerConfirmPageState extends State<registerConfirmPage> {
  final Authentication _auth = Authentication();
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: dark,
          body: Form(
            key: _formKey,
            child: Stack(
              children: [
                backgroundDesign(lighterRed, 0.7, 1.0, 100, 100),
                backgroundDesign(dark, 0.75, 0.9, 120, 120),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    confirmBox(),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Widget backgroundDesign(Color color, double heightScalar, double widthScalar,
      double leftRadius, double rightRadius) {
    return Container(
      height: MediaQuery.of(context).size.height * heightScalar,
      width: MediaQuery.of(context).size.width * widthScalar,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(leftRadius),
            bottomRight: Radius.circular(rightRadius),
          ),
        ),
      ),
    );
  }

  Widget confirmBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.58,
            width: MediaQuery.of(context).size.height * 0.38,
            decoration: BoxDecoration(
                color: light,
                border: Border.all(
                  color: light,
                )),
            child: Column(
              //Change mainaxisalignment to .start if you want google/facebook connection under login
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Email Verification Sent',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  child: Image.asset('assets/gifs/ConfirmEmail.gif'),
                  width: MediaQuery.of(context).size.width * 2,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                goBack(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget goBack() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Go',
          style: TextStyle(
            color: dark,
            fontSize: 15,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            ' Back',
            style: TextStyle(
              color: lighterRed,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          ' to Login Page',
          style: TextStyle(
            color: dark,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  _clear() {
    _controller.clear();
  }
}
