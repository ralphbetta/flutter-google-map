import 'package:flutter/material.dart';
import 'package:side_projects/homepage.dart';
//import 'package:side_projects/homescreen.dart';
// import 'package:side_projects/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MapWithDirection(),
    );
  }
}
