import 'dart:ui';

import 'package:Event_Finder_App/msc/theme.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:flutter/material.dart';
import 'package:Event_Finder_App/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../msc/designs.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../msc/imagePath.dart';

class ProfileApp extends StatefulWidget {
  AppUser userModel;
  String originalUsername;

  ProfileApp(this.userModel, this.originalUsername, {Key key})
      : super(key: key);
  @override
  _ProfileAppState createState() => _ProfileAppState();
}

class _ProfileAppState extends State<ProfileApp> {
  final formkey = GlobalKey<FormState>();
  FireStoreCloud _cloud = FireStoreCloud();
  double spaceBetween = 15;
  String _firebaseError;
  File imageFile;
  String _uploadedFileUrl;

  // -- IMAGE PICKER -- //
  imageView() {
    if (imageFile == null) {
      return SizedBox(
          height: MediaQuery.of(context).size.height / 3 - 20,
          width: MediaQuery.of(context).size.width - 80,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: lighterRed,
            ),
            child: Icon(
              Icons.add_a_photo,
              size: 65,
            ),
          ));
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 3 - 20,
        width: MediaQuery.of(context).size.width - 80,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: lighterRed,
            border: Border.all(color: lighterRed),
          ),
          child: Image.file(
            imageFile,
            /* width: 200,
            height: 200, */
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  _openGallery(BuildContext context) async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    final File pickedImageFile = File(pickedImage.path);

    setState(() {
      imageFile = pickedImageFile;
    });
    Navigator.of(context).pop(); //closes dialog
  }

  _openCamera(BuildContext context) async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    final File pickedImageFile = File(pickedImage.path);

    setState(() {
      imageFile = pickedImageFile;
    });
    Navigator.of(context).pop(); //closes dialog
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Choose an image from:"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    child: Text('Gallery'),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: GestureDetector(
                      child: Text('Camera'),
                      onTap: () {
                        _openCamera(context);
                      },
                    ),
                  ),
                ],
              ),
            ));
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      body: SingleChildScrollView(
        child: Stack(
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
                  SizedBox(
                    height: 20,
                  ),
                  infoCard(),
                ],
              ),
            ),
            Positioned(
              top: 30,
              left: 30,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: dark,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            showAlert(textColor: dark,
                      boxColor: light,
                      iconCloseColor: lighterRed,
                      iconErrorColor: dark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lighterRed,
        child: Icon(Icons.save),
        onPressed: () async {
          if (formkey.currentState.validate()) {
            String downloadUrl = (widget.userModel.imagePath == null
                ? ""
                : widget.userModel.imagePath);
            //before sending it back to the other page add it to the cloud

            if (imageFile != null) {
              print("getting download url");
              downloadUrl = await _uploadToFireBaseStorage(
                  imageFile: imageFile, path: "events/pic/");
              print("downloadUrl: ${downloadUrl.toString()}");
            }

            print("downloadUrl (outside): ${downloadUrl.toString()}");

            widget.userModel.imagePath = downloadUrl;

            if (widget.userModel.userName != widget.originalUsername) {
              QuerySnapshot g = await _cloud.firestore
                  .collection("users")
                  .where("userName", isEqualTo: widget.userModel.userName)
                  .get();
              if (g.docs.length > 0) {
                print(g.docs);
                print("username in use");
                setState(() {
                  _firebaseError = "Username in use";
                });
                return;
              }
            }

            formkey.currentState.save();
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
  }

  //-- WIDGETS --//

  //widget that display the user image and edit button
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
              backgroundImage: (imageFile == null
                  ? getProfileImage(path: widget.userModel.imagePath)
                  : FileImage(imageFile)),
            ),
          ),
          //icon button
          Positioned(
            top: 75,
            left: 70,
            child: Container(
              height: 40,
              width: 40,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: lighterRed),
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: dark,
                ),
                onPressed: () {
                  _showChoiceDialog(context);
                },
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget infoCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
                color: light,
                border: Border.all(
                  color: light,
                )),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  SizedBox(
                    height: spaceBetween,
                  ),
                  userNameBox(),
                  SizedBox(
                    height: spaceBetween,
                  ),
                  phoneNumberBox(),
                  SizedBox(
                    height: spaceBetween,
                  ),
                  bioBox(),
                  SizedBox(
                    height: spaceBetween,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget userNameBox() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        onChanged: (String value) {
          widget.userModel.userName = value;
        },
        initialValue: widget.userModel.userName,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Username can not be empty';
          }
          return null;
        },
        decoration: InputDecoration(
            labelText: 'User Name',
            prefixIcon: Icon(
              Icons.person,
              color: lighterRed,
            )),
      ),
    );
  }

  Widget phoneNumberBox() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        onChanged: (String value) {
          widget.userModel.phoneNumber = value;
        },
        initialValue: widget.userModel.phoneNumber,
        validator: (String value) {
          validateMobile(value);
        },
        decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(
              Icons.phone,
              color: lighterRed,
            )),
      ),
    );
  }

  Widget bioBox() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        onChanged: (String value) {
          widget.userModel.biodata = value;
        },
        initialValue: widget.userModel.biodata,
        validator: (String value) {
          return null;
        },
        decoration: InputDecoration(
            labelText: 'My Bio',
            prefixIcon: Icon(
              Icons.book,
              color: lighterRed,
            )),
      ),
    );
  }

  //Displays firebase errors
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

  //mobile from regex
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
