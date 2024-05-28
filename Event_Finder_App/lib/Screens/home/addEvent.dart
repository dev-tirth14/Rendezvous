import 'package:Event_Finder_App/msc/theme.dart';
import 'package:Event_Finder_App/services/firestoreCloud.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:Event_Finder_App/models/Event.dart';
import 'package:Event_Finder_App/services/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../models/Event.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../msc/utils.dart';

class addEvent extends StatefulWidget {
  @override
  _addEventState createState() => _addEventState();
  Event passedEvent;
  String
      pageTitle; //title is needed to use the same ui for both edit event and add events
  addEvent({Key key, @required this.passedEvent, this.pageTitle})
      : super(key: key);
}

class _addEventState extends State<addEvent> {
  final _formKey = GlobalKey<FormState>();
  final _cloud = FireStoreCloud();
  final textController = TextEditingController();
  DateTime _date; //must covert to string to store in db
  String _eventTitle;
  String _description = "Location Not Selected";
  String _location;
  String _firebaseError;
  ///////
  String _type = 'Event Type';
  //DateTime _dateTime;
  String _title = 'Rendezvous';
  String _body = 'Your Event is Now Live! Remind Your Friends.';
  String _payload = 'moreInfo1';
  final _notifications = Notifications();

  TimeOfDay _time;
  TimeOfDay picked;

  //image picker
  File imageFile;
  String _uploadedFileUrl;
  static const IconData celebration =
      IconData(0xe644, fontFamily: 'MaterialIcons');

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
            fit: BoxFit.fill,
          ),
        ),
      );
    }
  }

  _openGallery(BuildContext context) async {
    var pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      imageFile = File(pickedImage.path);
    });
  }

  _openCamera(BuildContext context) async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);

    setState(() {
      imageFile = File(pickedImage.path);
    });
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

  //date and time selector
  Future<Null> selectTime(BuildContext context) async {
    picked = await showTimePicker(context: context, initialTime: _time);
    if(picked!=null){
    setState(() {
      _time = picked;
    });}
  }

  //TODO READ ALL VALUES FROM PASSED EVENT.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _time = (widget.passedEvent.time == null
        ? TimeOfDay.now()
        : fromStringToTimeofDay(widget.passedEvent.time));

    _date = (widget.passedEvent.date == null
        ? DateTime.now()
        : DateTime.parse(widget.passedEvent.date));
        
    _description = (widget.passedEvent.description == null
        ? ""
        : widget.passedEvent.description);
    _eventTitle =
        (widget.passedEvent.title == null ? "" : widget.passedEvent.title);

    _type =
        (widget.passedEvent.type == null ? "Party" : widget.passedEvent.type);

    if (widget.passedEvent.location == null) {
      _location = null;
    } else {
      _location = widget.passedEvent.location;
    }
  }

  //Returns address at index [0] and postal code at [2]
  List<String> getDetailedLocation(String location) {
    return location.split(",");
  }

  @override
  Widget build(BuildContext context) {
    User _user = Provider.of<User>(context);
    _notifications.init();
    tz.initializeTimeZones();

    return Scaffold(
      backgroundColor: dark,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Form(
          key: _formKey,
          child: Padding(
              padding: EdgeInsets.only(top: 100, left: 0, right: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: light,
                      border: Border.all(
                        color: light,
                      )),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: GestureDetector(
                          onTap: () {
                            _showChoiceDialog(context);
                          },
                          child: imageView(),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.location_on,
                                color: lighterRed,
                              ),
                              onPressed: () async {
                                dynamic currentPosition;
                                String searchString;
                                if (_location == null ||
                                    _location == "Location not selected") {
                                  searchString = await getCurrentLocation();
                                  currentPosition =
                                      await Geolocator.getCurrentPosition(
                                          desiredAccuracy:
                                              LocationAccuracy.best);
                                } else {
                                  searchString = _location;
                                  List<Location> placesWithAddress =
                                      await locationFromAddress(_location);
                                  currentPosition = placesWithAddress[0];
                                }
                                PickResult result = await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => PlacePicker(
                                              apiKey:
                                                  "AIzaSyBqQMoPPv--RagMQ-m8An9sRkoiD0NfatQ",
                                              initialPosition: LatLng(
                                                  currentPosition.latitude,
                                                  currentPosition.longitude),
                                              useCurrentLocation: false,
                                              selectInitialPosition: true,
                                              enableMapTypeButton: false,
                                              searchForInitialValue: true,
                                              initialSearchString: searchString,
                                              enableMyLocationButton: true,

                                              //usePlaceDetailSearch: true,
                                              onPlacePicked: (result) {
                                                Navigator.pop(context, result);
                                              },
                                              /*"AIzaSyBqQMoPPv--RagMQ-m8An9sRkoiD0NfatQ",
                                            displayLocation: LatLng(currrentPosition.latitude,currrentPosition.longitude),*/
                                            )));

                                // Handle the result in your way
                                if(result!=null){
                                setState(() {
                                  _location = result.formattedAddress;
                                });
                                }
                              },
                            ),
                            (_location == null
                                ? Text("Location not selected")
                                : Text(
                                    '${getDetailedLocation(_location)[0]},${getDetailedLocation(_location)[2]}'))
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                        child: Row(
                          children: [
                            DropdownButton<String>(
                                hint: Text("Select Type of Party"),
                                value: _type,
                                onChanged: (String value) {
                                  setState(() {
                                    _type = value;
                                  });
                                },
                                items: <String>[
                                  "Conference",
                                  "Workshop",
                                  "Competition",
                                  "Party",
                                  "Other"
                                ].map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList()),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Event Name ',
                          ),
                          initialValue: _eventTitle,
                          onChanged: (String value) {
                            _eventTitle = value;
                          },
                          validator: (String value) {
                            //for now we only care about the title being longer then 5 characters
                            if (value.length < 5) {
                              return ("Event title must be longer then 5 characters");
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Description ',
                          ),
                          initialValue: _description,
                          onChanged: (String value) {
                            _description = value;
                          },
                          validator: (String value) {
                            //for now we only care about the title being longer then 5 characters
                            return null;
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              pickDateButton(),
                              pickTimeButton(),
                            ],
                          ),
                          Row(
                            children: [
                              
                              Text(toDateString(_date) + ", " + toTimeString( _time.hour.toString().padLeft(2, '0') +':' +_time.minute.toString().padLeft(2, '0'))),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ),
        showAlert(boxColor: light,),
        

          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lighterRed,
        child: Icon(Icons.save),
        onPressed: () async {
          if ((_formKey.currentState.validate()) && (_location != null)) {
            var answer = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: Text(
                    'Are you sure you want to create this event?',
                    textAlign: TextAlign.center,
                  ),
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SimpleDialogOption(
                          child: const Text('Yes!'),
                          onPressed: () async {
                            var when = tz.TZDateTime.now(tz.local)
                                .add(const Duration(seconds: 5));
                            await _notifications.sendNotificationLater(
                                _title, _body, when, _payload);
                            //_notifications.sendNotificationNow(_title, _body, _payload);
                            Navigator.pop(context, true);
                            //add snackbar to show event was added
                          },
                        ),
                        SimpleDialogOption(
                          child: const Text('Not sure'),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                      ],
                    )
                  ],
                );
              },
            );
            if (answer == true) {
              //if (answer != false) {
              String downloadUrl;
              //before sending it back to the other page add it to the cloud
              if (imageFile != null) {
                print("getting download url");
                downloadUrl = await _uploadToFireBaseStorage(
                    imageFile: imageFile, path: "events/pic/");
                print("downloadUrl: ${downloadUrl.toString()}");
              }
              print("downloadUrl (outside): ${downloadUrl.toString()}");
              Event newEvent = Event(
                type: _type,
                imagePath: (downloadUrl == null ? "" : downloadUrl),
                title: _eventTitle,
                location: _location,
                hostid: await _cloud.getCurrentUserRef(_user.uid),
                date: _date.toString(),
                time: _time.toString(),
                description: _description,
              );

              print("popping the event..");
              Navigator.of(context).pop(newEvent);
              //}
            }
          } else {
            if(_location == null){
              setState(() {
                _firebaseError = "You are missing location";
              });
            }
          }
        },
      ),
    );
  }

  //-- WIDGETS --//
  pickTimeButton() {
    return IconButton(
      icon: Icon(
        Icons.schedule,
        color: lighterRed,
      ),
      onPressed: () {
        selectTime(context);
      },
    );
  }

  pickDateButton() {
    return IconButton(
      icon: Icon(
        Icons.date_range,
        color: lighterRed,
      ),
      onPressed: () {
        showDatePicker(
                context: context,
                initialDate: _date == null ? DateTime.now() : _date,
                firstDate: DateTime.now(),
                lastDate: DateTime(2021))
            .then((value) {
            if(value!=null){
          setState(() {
            _date = value;
          });
            }
        });
      },
    );
  }

  //-- FUNCTIONS --//
  //convertions and formatting functions
  getCurrentLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    List<Placemark> realLocations = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);
    return '${realLocations[0].street}, ${realLocations[0].locality}, ${realLocations[0].administrativeArea}, ${realLocations[0].postalCode}, ${realLocations[0].country}';
  }

  getTime(String time) {
    // date time format 2020-01-02 03:04:05

    //We changed the format to a Datetime so now we can parse
    String newTime = '0000-00-00 ' + time.substring(10, 15) + ':00';
    DateTime newDateTime = DateTime.parse(newTime);
    String formattedTime = DateFormat.jm().format(newDateTime);
    return formattedTime;
  }

  toTimeString(String time) {
    // date time format 2020-01-02 03:04:05

    //We changed the format to a Datetime so now we can parse
    String newTime = '0000-00-00 ' + time + ':00';
    DateTime newDateTime = DateTime.parse(newTime);
    String formattedTime = DateFormat.jm().format(newDateTime);
    return formattedTime;
  }

  TimeOfDay fromStringToTimeofDay(String string) {
    String s = string.substring(10, 15);
    TimeOfDay _newTime = TimeOfDay(
        hour: int.parse(s.split(":")[0]), minute: int.parse(s.split(":")[1]));
    return _newTime;
  }

  //reorders list for drop down menu so it is always a drop down
  _reorderList(List<String> list, String val) {
    List<String> newlist = [];
    newlist.add(val);
    for (int i = 0; i < list.length; i++) {
      if (list[i] != val) {
        newlist.add(list[i]);
      }
    }
    return newlist;
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
}
