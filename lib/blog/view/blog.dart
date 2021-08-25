import 'package:flutter/material.dart';
import '../services/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPage extends StatefulWidget {
  final String imgUrl, title, description, authorName;
  BlogPage({
    @required this.imgUrl,
    @required this.title,
    @required this.description,
    @required this.authorName,
  });

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  CrudMethods crudMethods = new CrudMethods();
  QuerySnapshot blogSnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blog", style: TextStyle(fontSize: 22)),
      ),
      body: BlogData(
        imgUrl: widget.imgUrl,
        title: widget.title,
        description: widget.description,
        authorName: widget.authorName,
      ),
    );
  }
}

class BlogData extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String description;
  final String authorName;
  BlogData({
    @required this.imgUrl,
    @required this.title,
    @required this.description,
    @required this.authorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Image.network(
            imgUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 150,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  authorName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
