import 'package:Event_Finder_App/Screens/home/ListEvents.dart';
import 'package:Event_Finder_App/Screens/home/introductionScreen.dart';
import 'package:Event_Finder_App/models/UserModel.dart';
import 'package:Event_Finder_App/services/authentication.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:Event_Finder_App/services/notifications.dart';
import 'dart:io';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:auto_size_text/auto_size_text.dart';

class userInfoRegistrationPage extends StatefulWidget {
  Function callback;
  userInfoRegistrationPage(this.callback, {Key key}) : super(key: key);
  @override
  _userInfoRegistrationPageState createState() =>
      _userInfoRegistrationPageState();
}

class _userInfoRegistrationPageState extends State<userInfoRegistrationPage> {
  FireStoreCloud _cloud;
  Authentication _authUser;
  final _formKey = GlobalKey<FormState>();
  String _userName = "";
  String _phoneNumber = "";
  String _firebaseError;
  var _controller = TextEditingController();
  bool isIntroductionShowing=false;

  //notification values
  String _title = 'Rendezvous';
  String _body = 'Thanks for joining the Rendezvous team!';
  String _payload = 'welcome';
  final _notifications = Notifications();

  //upload image
  File imageFile;
  String _uploadedFileURL;

  imageView() {
    if (imageFile == null) {
      return Icon(
        Icons.add_a_photo,
        size: 35,
        color: dark,
      );
    } else {
      return CircleAvatar(
        backgroundImage: FileImage(imageFile),
        radius: 50,
      );
    }
  }

  _openGallery(BuildContext context) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = image;
    });
    Navigator.of(context).pop(); //closes dialog
  }

  _openCamera(BuildContext context) async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      imageFile = image;
    });
    Navigator.of(context).pop(); //closes dialog
  }

  Future<String> _uploadToFireBaseStorage({File imageFile, String path}) async {
    String url;
    print('uploading to cloud');
    String fileName = '${Path.basename(imageFile.path)}';
    //String reference = 'events/pic/${fileName}';
    String reference = path + fileName;
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = await storage
        .ref()
        .child(reference); //change the value inside the {} to EventId
    //UploadTask uploadTask = ref.putFile(imageFile);

    var snapshot = await ref.putFile(imageFile);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    print("download url (inside _upload func) ${downloadUrl}");
    return downloadUrl;
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "Choose an image from:",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: Text('Gallery ', style: TextStyle(color: dark)),
                      onTap: () {
                        _openGallery(context);
                      },
                    ),
                    GestureDetector(
                      child: Text('Camera ', style: TextStyle(color: dark)),
                      onTap: () {
                        _openCamera(context);
                      },
                    ),
                  ],
                ),
              ));
        });
  }

  @override
  void initState() {
    super.initState();
    _cloud = FireStoreCloud();
    _authUser = Authentication();
  }

  @override
  Widget build(BuildContext context) {
    _notifications.init();
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: dark,
          body: isIntroductionShowing?IntroScreen(callback: this.widget.callback): Stack(children: [
            Form(
              key: _formKey,
              child: Stack(
                children: [
                  backgroundDesign(lighterRed, 0.7, 1.0, 100, 100),
                  backgroundDesign(dark, 0.75, 0.9, 120, 120),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      title(),
                      loginBox(),
                    ],
                  )
                ],
              ),
            ),
            showAlert(
                textColor: dark,
                boxColor: light,
                iconCloseColor: dark,
                iconErrorColor: lighterRed)
          ])),
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

  Widget loginBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            width: MediaQuery.of(context).size.height * 0.40,
            decoration: BoxDecoration(
                color: light,
                border: Border.all(
                  color: light,
                )),
            child: Column(
              //Change mainaxisalignment to .start if you want google/facebook connection under login
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                profileImage(),
                nameBox(),
                phoneNumberBox(),
                registerButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget profileImage() {
    return GestureDetector(
      child: Center(
        child: CircleAvatar(
          backgroundColor: Colors.red[200],
          child: imageView(),
          radius: 50,
        ),
      ),
      onTap: () {
        _showChoiceDialog(context);
      },
    );
  }

  Widget nameBox() {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      child: TextFormField(
        onChanged: (String value) {
          setState(() {
            _userName = value;
          });
        },
        validator: (String value) {
          if (value.length < 5 || value.contains(" ")) {
            return "The username should be at least 8 characters long (without spaces)";
          }
          return null;
        },
        decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(
              Icons.person_outline,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget phoneNumberBox() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: _controller,
        onChanged: (String value) {
          setState(() {
            _phoneNumber = value;
          });
        },
        validator: (String value) {
          validateMobile(value);
        },
        decoration: InputDecoration(
          labelText: 'Phone Number',
          prefixIcon: Icon(
            Icons.call,
          ),
        ),
      ),
    );
  }

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
                  //tirth code goes here
                  QuerySnapshot g = await _cloud.firestore
                      .collection("users")
                      .where("userName", isEqualTo: _userName)
                      .get();
                  if (g.docs.length > 0) {
                    String result = "Username in use";
                    print(result);
                    setState(() {
                      _firebaseError = result;
                    });

                    return;
                  }
                  var answer = await _showTerms(context);

                  if (answer != false) {
                    await _notifications.sendNotificationNow(
                        _title, _body, _payload);

                    String downloadUrl;
                    //before sending it back to the other page add it to the cloud

                    if (imageFile != null) {
                      print("getting download url");
                      downloadUrl = await _uploadToFireBaseStorage(
                          imageFile: imageFile, path: "events/pic/");
                      print("downloadUrl: ${downloadUrl.toString()}");
                    }

                    print("downloadUrl (outside): ${downloadUrl.toString()}");

                    await _authUser.firebaseAuth.currentUser
                        .updateProfile(displayName: _userName);

                    AppUser user = AppUser(
                        userName: _userName,
                        phoneNumber: _phoneNumber,
                        imagePath: (downloadUrl == null ? "" : downloadUrl),
                        email: _authUser.firebaseAuth.currentUser.email);
                    _cloud.firestore
                        .collection('users')
                        .doc(_authUser.firebaseAuth.currentUser.uid)
                        .set(user.toMap());
                  }
                }
              },
              child: Text(
                'Join',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Create Profile',
          style: TextStyle(
            fontSize: 40,
            color: lighterRed,
          ),
        ),
      ],
    );
  }

  _showTerms(BuildContext context) async{
    bool answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        //_showTerms(context);
        return SimpleDialog(
          title: Text('Terms of Service',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          children: <Widget>[
            Column(
              children: [
                Text(
                  'Do you agree to the\nTerms and Conditions?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SimpleDialogOption(
                        child: const Text('Accept',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        padding: EdgeInsets.all(10.0),
                        onPressed: () async {
                          //TO BE CHANGED: add all the variables you want to store, and where you want
                          //to store in firebase when you want to merge
                          //_uploadToFireBaseStorage(imageFile, "profile/pic/");
                          //Navigator.pushNamed(context, '/listEvents');

                          Navigator.pop(context, true);

                          //tirth code goes here
                          /* QuerySnapshot g = await _cloud.firestore
                              .collection("users")
                              .where("userName", isEqualTo: _userName)
                              .get();
                          if (g.docs.length > 0) {
                            String result = "Username in use";
                            print(result);
                            setState(() {
                              _firebaseError = result;
                            });

                            return;
                          } */
                        }),
                    SimpleDialogOption(
                      child: const Text('Decline',
                          style: TextStyle(
                            color: Colors.grey,
                          )),
                      padding: EdgeInsets.all(10.0),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
    if(answer==true){
      setState(() {
        isIntroductionShowing=true;
      });

    }
  }

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

  String validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }
}
