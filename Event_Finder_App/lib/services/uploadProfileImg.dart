//not sure how to call on it so currently not in use

// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:Event_Finder_App/services/uploadProfileImg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as Path;


// class uploadProfileImg extends StatefulWidget {
//   @override
//   _uploadProfileImgState createState() => _uploadProfileImgState();
// }

// class _uploadProfileImgState extends State<uploadProfileImg> {
//   File imageFile;    
//   String _uploadedFileURL;  

//   imageView() {
//     if (imageFile == null) {
//       return Icon(Icons.photo_camera, size: 35);
//     } else {
//       return Image.file(imageFile, width: 200, height: 200, fit: BoxFit.cover);
//     }
//   }

//   _openGallery(BuildContext context) async {
//     File image = await ImagePicker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       imageFile = image;
//     });
//     Navigator.of(context).pop(); //closes dialog
//   }

//   _openCamera(BuildContext context) async {
//     File image = await ImagePicker.pickImage(source: ImageSource.camera);
//     setState(() {
//       imageFile = image;
//     });
//     Navigator.of(context).pop(); //closes dialog
//   }

//   _uploadToFireBaseStorage(File imageFile, String path) {
//     print('uploading to cloud');
//     String fileName = '${Path.basename(imageFile.path)}}';
//     //String reference = 'events/pic/${fileName}';
//     String reference = path + fileName;
//     FirebaseStorage storage = FirebaseStorage.instance;
//     Reference ref = storage
//         .ref()
//         .child(reference); //change the value inside the {} to EventId
//     UploadTask uploadTask = ref.putFile(imageFile);
//     //this return the string url link
//     uploadTask.then((res) {
//       res.ref.getDownloadURL();
//     });
//   }

//   Future<void> _showChoiceDialog(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: Text(
//             "Choose an image from:",
//             textAlign: TextAlign.center,
//             style:
//                 TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//           ),
//           content: SingleChildScrollView(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 GestureDetector(
//                   child: Text('Gallery ', style: TextStyle(color: Colors.cyan)),
//                   onTap: () {_openGallery(context);},
//                 ),
//                 GestureDetector(
//                   child: Text('Camera ', style: TextStyle(color: Colors.cyan)),
//                   onTap: () {_openCamera(context);},
//                 ),
//               ],
//             ),
//           )
//         );
//       }
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       //future: _initialization,
//       builder: (context, snapshot) {
//         _showChoiceDialog(context),
//       }
//     );
//   }
// }