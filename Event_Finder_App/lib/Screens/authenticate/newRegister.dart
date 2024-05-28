import 'package:flutter/material.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:Event_Finder_App/services/authentication.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewRegister extends StatefulWidget {
  @override
  _NewRegisterState createState() => _NewRegisterState();
}

class _NewRegisterState extends State<NewRegister> {
  final Authentication _auth = Authentication();
  final _formKey = GlobalKey<FormState>();

  String _id; //this is the email that is used to sign up
  String _password;

  var _controller = TextEditingController();

  String _reEnteredPassword;
  bool _confirmationIsHidden = false;
  bool _passwordIsHidden = false;

  String _firebaseError;

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
                    registerBox(),
                    filler(),
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

  //Needed for background design
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

  // ---- WIDGETS ---//
  Widget filler() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        ' ',
        style: TextStyle(
          color: light,
          fontSize: 20,
        ),
      )
    ]);
  }

  //Card with all the textfeilds
  Widget registerBox() {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30, bottom: 10),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                emailBox(),
                passwordBox(),
                confirmPasswordBox(),
                registerButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //email text feild box
  Widget emailBox() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        onChanged: (String value) {
          _id = value;
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

  //password textfeild validate password with correct regex
  Widget passwordBox() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        obscureText: !_passwordIsHidden,
        onChanged: (String value) {
          _password = value;
        },
        validator: (String value) {
          if (value.isEmpty) {
            return 'Password is required!';
          }
          if (validateStructure(value) == false) {
            return ('Must: special character, upper & lower case & number');
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
                !_passwordIsHidden ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordIsHidden = !_passwordIsHidden;
              });
            },
          ),
          hintText: "Password",
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  //check if re-entered password matches
  Widget confirmPasswordBox() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        obscureText: !_confirmationIsHidden,
        onChanged: (String value) {
          _reEnteredPassword = value;
        },
        validator: (String value) {
          if (value.isEmpty) {
            return 'Re-enter Password';
          }
          if (value != _password) {
            return "Passwords don't match";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          prefixIcon: Icon(
            Icons.lock,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              (!_confirmationIsHidden
                  ? Icons.visibility
                  : Icons.visibility_off),
            ),
            onPressed: () {
              setState(() {
                _confirmationIsHidden = !_confirmationIsHidden;
              });
            },
          ),
        ),
      ),
    );
  }

  //validate form and register the user credentials
  Widget registerButton() {
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
                  print("Authenticating!!");

                  dynamic error =
                      await _auth.registerWithEmailPass(_id, _password);

                  if (!(error is User)) {
                    String newCode;
                    if (error.code == "invalid-email") {
                      newCode = "Please enter your email correctly";
                    }
                    if (error.code == "email-already-in-use") {
                      newCode =
                          "This email is already in use,try resetting password";
                    }
                    if (error.code == "weak-password") {
                      newCode =
                          "Password must be at least 6 characters long contain a number, special character, and an uppercase letter.";
                    }
                    print(error);
                    setState(() {
                      _firebaseError = newCode;
                    });
                  } else {
                    //wait for the page then pop this page and return back to the original page
                    await Navigator.pushNamed(context, '/registerConfirmPage');
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  //app logo
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

  // ---- FUNCTIONS ---//

  //firebase error popup for register user with email
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

  //regex functions for password
  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{4,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  //clear the text feild
  _clear() {
    _controller.clear();
  }
}
