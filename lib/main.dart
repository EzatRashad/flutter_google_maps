import 'package:flutter/material.dart';
import 'package:google_maps/widgets/live_tracking.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       
      home: const LiveTracking(),
    );
  }
}
