import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadFile extends StatefulWidget {
  UploadFile() : super();

  final String title = "Flutter upload image";

  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File sampleImage;
  String JPG='jpg';
  String downloadImagelink=null;

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }
  Future getImageLink(StorageUploadTask task) async {

    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      downloadImagelink= 'Firestore url: '+downloadUrl;
    });

  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Image upload to firebase'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            sampleImage == null ? Text('Select an image') :  Image.file(sampleImage, height: 300.0, width: 300.0),
            RaisedButton(
              child: Text("Select Image from Gallery"),
              onPressed: () {
                setState(() {
                  downloadImagelink=null;
                });
                getImage();
              },
            ),
            RaisedButton(
              child: Text("Upload file"),
              onPressed: () async {
                setState(() {
                  downloadImagelink= 'file uploading...';
                });
                final String fileName = Random().nextInt(10000).toString() +'.$JPG';
                final StorageReference firebaseStorageRef =
                FirebaseStorage.instance.ref().child(fileName);
                final StorageUploadTask task =
                firebaseStorageRef.putFile(sampleImage);
                getImageLink(task);
              },
            ),
            downloadImagelink == null ? Text('File link ') :  Text(downloadImagelink),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }



}