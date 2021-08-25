import 'dart:io';
import '../services/crud.dart';
import 'package:e_waste_app/blog/services/crud.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateBlog extends StatefulWidget {
  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  String authorName = "", title = "", desc = "";

  File selectedImage;
  bool _isLoading = false;
  CrudMethods crudMethods = new CrudMethods();

  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile image = await _picker.pickImage(source: ImageSource.gallery);
    try {
      if (image != null)
        setState(() {
          selectedImage = File(image.path);
          if (selectedImage.existsSync()) print("uploded");
        });
    } catch (e) {
      print(e);
    }
  }

  uploadBlog() async {
    if (selectedImage.existsSync()) {
      setState(() {
        _isLoading = true;
      });
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(9)}.jpg");

      // await firebaseStorageRef.putFile(selectedImage).whenComplete(() => null);
      // final downloadUrl = await firebaseStorageRef.getDownloadURL();
      // print("url = $downloadUrl");

      final UploadTask task = firebaseStorageRef.putFile(selectedImage);

      var downloadUrl = await (await task).ref.getDownloadURL();
      print("url = $downloadUrl");

      Map<String, String> blogMap = {
        "imageUrl": downloadUrl,
        "authorName": authorName,
        "title": title,
        "desc": desc
      };
      crudMethods.addData(blogMap).then((value) {
        Navigator.pop(context);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Create Blog", style: TextStyle(fontSize: 22)),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                uploadBlog();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Icon(Icons.upload),
              ),
            )
          ],
        ),
        body: _isLoading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        height: 150,
                        decoration: BoxDecoration(
                            image: selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(selectedImage),
                                    fit: BoxFit.cover)
                                : null,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        width: MediaQuery.of(context).size.width,
                        child: Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration:
                                InputDecoration(hintText: "Author name"),
                            onChanged: (val) {
                              authorName = val;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(hintText: "Title"),
                            onChanged: (val) {
                              title = val;
                            },
                          ),
                          TextField(
                            decoration:
                                InputDecoration(hintText: "Description"),
                            onChanged: (val) {
                              desc = val;
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ));
  }
}
