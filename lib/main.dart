// ignore_for_file: empty_catches

import 'package:demomediaplayer/homePage.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try
  {
    runApp(mainWidget(const HomePage()));
  }catch(error)
  {

  }
}
Widget mainWidget(dynamic activePage){
  return MaterialApp(
          title: 'Demo Media Player',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: activePage
      );
}