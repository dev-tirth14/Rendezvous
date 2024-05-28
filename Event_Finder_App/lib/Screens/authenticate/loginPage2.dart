import 'package:flutter/material.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:Event_Finder_App/services/authentication.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'newRegister.dart';

class LoginPage2 extends StatefulWidget {
  @override
  _LoginPage2State createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  final Authentication _auth = Authentication();
  final _formKey = GlobalKey<FormState>();

  //local variables needed for the form
  String _email;
  String _password;
  String _firebaseError;
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    logo(),
                    loginBox(),
                    signUp(),
                  ],
                ),
                showAlert(
                    textColor: dark,
                    boxColor: light,
                    iconCloseColor: dark,
                    iconErrorColor: lighterRed),
              ],
            ),
          )),
    );
  }

  // ---- WIDGETS ---//
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

  //all text feilds needed for login
  Widget loginBox() {
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
                Padding(
                  padding: EdgeInsets.only(left: 30, bottom: 20),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                //all text feilds needed for the login process
                emailBox(),
                passwordBox(),
                loginButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //text feild need to get the email needed for the account
  Widget emailBox() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: TextFormField(
        onChanged: (String value) {
          _email = value;
        },
        validator: (String value) {
          if (value.isEmpty) {
            return 'E-mail is required!';
          }
          return null;
        },
        decoration: InputDecoration(
            labelText: 'E-mail',
            prefixIcon: Icon(
              Icons.email,
              color: Colors.grey,
            )),
      ),
    );
  }

  //this is password textfeild needed for the first password
  Widget passwordBox() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextFormField(
        controller: _controller,
        obscureText: true,
        onChanged: (String value) {
          _password = value;
        },
        validator: (String value) {
          if (value.isEmpty) {
            return 'Password is required!';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(
            Icons.lock,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.grey,
            ),
            onPressed: _clear,
          ),
        ),
      ),
    );
  }

  //this button let the user login if they have correct credentials
  Widget loginButton() {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 15,
            width: MediaQuery.of(context).size.height / 2.9,
            child: RaisedButton(
              elevation: 10,
              color: lighterRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  //go to page
                  //Navigator.pushNamed(context, '/listEvents');

                  //Get firebase error
                  dynamic error =
                      await _auth.signInWithEmailPass(_email, _password);

                  //Making firebase errors more user friendly
                  if (!(error == User)) {
                    String newCode;

                    if (error.code == "invalid-email") {
                      newCode =
                          "Please check if you typed in the correct email.";
                    }

                    if (error.code == "too-many-requests") {
                      newCode = "too-many-requests";
                    }

                    if (error.code == "user-not-found" ||
                        error.code == "wrong-password") {
                      newCode = "Incorrect e-mail or password";
                    }

                    setState(() {
                      _firebaseError = newCode;
                    });
                  }
                  //check if the user can login with current credentials
                  await _auth.signInWithEmailPass(_email, _password);
                }
              },
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  //sign up button navigates to register page
  Widget signUp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Not a member?',
          style: TextStyle(
            color: light,
            fontSize: 20,
          ),
        ),
        InkWell(
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => NewRegister()));
          },
          child: Text(
            ' Register',
            style: TextStyle(
              color: lighterRed,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Image.asset(
            'assets/img/logo1.PNG',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  _clear() {
    _controller.clear();
  }

  //this is a pop alert for firebase errors with auth sign in with error
  showAlert(
      {Color textColor,
      Color boxColor,
      Color iconCloseColor,
      Color iconErrorColor}) {
    if (_firebaseError != null) {
      return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
          decoration: BoxDecoration(
              color: boxColor, borderRadius: BorderRadius.circular(40)),
          //color: boxColor,
          width: double.infinity,
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.error_outline,
                  color: iconErrorColor,
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  _firebaseError,
                  maxLines: 3,
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w900),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: iconCloseColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _firebaseError = null;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
