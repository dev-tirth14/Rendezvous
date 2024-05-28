import 'dart:ui';
import 'package:Event_Finder_App/Screens/home/mainDrawer.dart';
import 'package:Event_Finder_App/msc/theme.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:flutter/material.dart';
import 'package:Event_Finder_App/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../msc/designs.dart';
import 'package:Event_Finder_App/services/authentication.dart';
import 'package:flutter/rendering.dart';
import 'EditProfile.dart';
import '../../msc/imagePath.dart';

class profilePage extends StatefulWidget {
  AppUser userModel;
  String originalUsername;
  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  final formkey = GlobalKey<FormState>();

  AppUser userModel;
  FireStoreCloud _cloud;
  Authentication _auth;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
    _cloud = FireStoreCloud();
    _auth = Authentication();
    setAccountUserInstance();
  }

  setAccountUserInstance() async {
    DocumentReference userRef =
        await _cloud.getCurrentUserRef(_auth.firebaseAuth.currentUser.uid);
    AppUser userInstance = await _cloud.getAppUserFromRef(userRef);
    if (userInstance.biodata == null) {
      userInstance.biodata = "";
    }
    setState(() {
      userModel = userInstance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      drawer: mainDrawer(),
      key: _scaffoldKey,
      body: (userModel == null)
          ? LinearProgressIndicator()
          : Stack(
              children: [
                CustomPaint(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  painter: CurvedContainer(),
                ),
                Positioned(
                  top: 80,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('My Profile',
                              style: TextStyle(
                                  color: light,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      editProfileImg(),
                      info(),
                      editButton(),
                    ],
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 30,
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: dark,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // --- WIDGETS --- //

  //Returns edit profile button
  Widget editButton() {
    return Padding(
      padding: EdgeInsets.only(top: 50),
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
                // Navigator.pushNamed(context, '/editProfile');
                AppUser edittableUser = AppUser(
                    biodata: userModel.biodata,
                    userName: userModel.userName,
                    email: userModel.email,
                    phoneNumber: userModel.phoneNumber,
                    imagePath: userModel.imagePath);
                var editResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfileApp(edittableUser, userModel.userName)));
                if (editResult == true) {
                  _cloud.updateUser(userModel.reference, edittableUser);
                  setAccountUserInstance();
                }
              },
              child: Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  //Returns profile image container
  Widget editProfileImg() {
    return Container(
      //color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.3,
      child: Center(
        child: Stack(children: [
          //picture
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            child: CircleAvatar(
              backgroundColor: light,
              backgroundImage: getProfileImage(path: userModel.imagePath),
            ),
          ),
        ]),
      ),
    );
  }

  //Returns datatable with the given user infomation
  Widget info() {
    return Padding(
      padding: EdgeInsets.only(top: 60),
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 0.33,
        child: DataTable(
          columns: <DataColumn>[
            DataColumn(
              label: Text(
                '',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                '',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          //Rows of datatable
          rows: <DataRow>[
            DataRow(cells: <DataCell>[
              DataCell(
                ListTile(
                  title: Text(
                    'Biography',
                    style: TextStyle(
                      color: light,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  leading: Icon(
                    Icons.book,
                    color: lighterRed,
                  ),
                ),
              ),
              DataCell(
                Expanded(
                  child: Text(
                    userModel.biodata,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: light),
                  ),
                ),
              ),
            ]),
            DataRow(cells: <DataCell>[
              DataCell(
                ListTile(
                  title: Text(
                    'Username',
                    style: TextStyle(
                      color: light,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  leading: Icon(
                    Icons.person,
                    color: lighterRed,
                  ),
                ),
              ),
              DataCell(
                Expanded(
                  child: Text(
                    userModel.userName,
                    style: TextStyle(
                      color: light,
                    ),
                  ),
                ),
              ),
            ]),
            DataRow(cells: <DataCell>[
              DataCell(
                ListTile(
                  title: Text(
                    'Phone Number',
                    style: TextStyle(
                      color: light,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  leading: Icon(
                    Icons.phone,
                    color: lighterRed,
                  ),
                ),
              ),
              DataCell(
                Expanded(
                  child: Text(
                    userModel.phoneNumber,
                    style: TextStyle(
                      color: light,
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
